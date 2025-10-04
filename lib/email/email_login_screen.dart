import 'dart:convert';
import 'dart:io';

import 'package:app_02/Widgets/snackbar.dart';
import 'package:app_02/home_page/my_home_screen.dart';
import 'package:app_02/Widgets/my_button.dart';
import 'package:app_02/email/email_signup_screen.dart';
import 'package:app_02/email/email_forgot_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_02/service/email_auth_service.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; //vòng tròn quay loading
  bool isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy ID thiết bị và có mã hóa (Android/iOS/Web)
  String? verificationId;
  String? deviceId;

  /// ✅ Trả về SHA-1 hash của DeviceId (Web + Android + iOS)
  static Future<String> getHashedDeviceId() async {
    String rawId = "unknown_device";
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        // 👉 Web không hỗ trợ Platform, nên dùng WebBrowserInfo
        final webInfo = await deviceInfo.webBrowserInfo;
        rawId =
            "${webInfo.vendor ?? "web"}-${webInfo.userAgent ?? "unknown"}-${webInfo.hardwareConcurrency ?? 0}";
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        rawId = "${androidInfo.id ?? androidInfo.device}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        rawId = iosInfo.identifierForVendor ?? "unknown_ios";
      } else if (Platform.isWindows) {
        final winInfo = await deviceInfo.windowsInfo;
        rawId = winInfo.deviceId;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        rawId = linuxInfo.machineId ?? "unknown_linux";
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        rawId = macInfo.systemGUID ?? "unknown_macos";
      }
    } catch (e) {
      rawId = "error_${e.toString()}";
    }

    // Hash SHA-1 để ngắn gọn và an toàn
    final bytes = utf8.encode(rawId);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// Xử lý đăng nhập thành công + Device Binding
  // Future<void> handleLoginSuccess(String email) async {
  //   //await initDeviceId();
  //   await getHashedDeviceId();
  //   final uid = _auth.currentUser!.uid;
  //   final userDoc = _firestore.collection("userLogin").doc(uid);
  //   final snapshot = await userDoc.get();
  //
  //   if (snapshot.exists) {
  //     // user đã có trong database
  //     final List<dynamic> devices = snapshot['deviceIds'] ?? [];
  //     if (!devices.contains(deviceId)) {
  //       // Thiết bị mới
  //       await userDoc.update({
  //         "deviceIds": FieldValue.arrayUnion([deviceId]),
  //       });
  //     }
  //   } else {
  //     // Tạo user mới
  //     await userDoc.set({
  //       "email": emailController.text,
  //       "deviceIds": [deviceId],
  //     });
  //   }
  // }

  /// Xử lý đăng nhập thành công + Device Binding
  Future<void> handleLoginSuccess(String email) async {
    // Lấy hashed device ID
    final hashedDeviceId = await getHashedDeviceId();
    deviceId = hashedDeviceId; //Đảm bảo deviceId có giá trị trước khi dùng

    final uid = _auth.currentUser!.uid;
    final userDoc = _firestore.collection("userLogin").doc(uid);
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      // user đã có trong database
      final data = snapshot.data() ?? {}; //Lấy map dữ liệu, tránh lỗi khi field chưa tồn tại
      final List<dynamic> devices =
      (data['deviceIds'] is List) ? List.from(data['deviceIds']) : [];
      // Thiết bị mới
      if (!devices.contains(deviceId)) {
        await userDoc.set({
          "deviceIds": FieldValue.arrayUnion([deviceId]), //Tự động thêm phần tử vào mảng, không bị trùng
        }, SetOptions(merge: true)); //Giúp không ghi đè các field khác của user
      }
    } else {
      // user mới -> tạo document
      await userDoc.set({
        "email": emailController.text.trim(),
        "deviceIds": [deviceId],
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }


  void _login() async {
    setState(() {
      isLoading = true;
    });
    final result = await _authService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    if ((result == "Thành công") & (_formKey.currentState!.validate())) {
      setState(() {
        isLoading = false;
      });
      await handleLoginSuccess(emailController.text);
      showSnackBAR(context, "Đăng nhập thành công!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPage()),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // Thông báo đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập $result"),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("img/logocand.png"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PHÒNG THAM MƯU",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                //Tạo hàng đăng nhập email
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "abc@gmail",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Nhập Email";
                          }
                          final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return "Email không hợp lệ";
                          }
                          return null;
                        },
                      ),

                      //Tạo hàng đăng nhập mật khẩu
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          hintText: "Nhập mật khẩu của bạn",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty || v.length < 6) {
                            return "Mật khẩu không đúng";
                          }
                          return null;
                        },
                        obscureText: isPasswordHidden,
                        obscuringCharacter: '*',
                      ),
                      //tạo một vòng tròn xoay loading
                      const SizedBox(height: 50),
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                          //Tạo nút button đăng nhập
                          : SizedBox(
                            width: double.infinity,
                            child: MyButton(
                              onTap: _login,
                              buttontext: "Đăng nhập",
                            ),
                          ),
                      SizedBox(height: 20),
                      const EmailForgotPasswordScreen(),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Bạn chưa có tài khoản?",
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            child: Text(
                              " Đăng ký",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: -1,
                              ),
                            ),
                            onTap: () {
                              //xử lý khi click vào chữ đăng ký, sẽ ra form đăng ký
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailSignupScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
