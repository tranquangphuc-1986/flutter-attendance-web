// ignore: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:io' show Platform;
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
   String? deviceId;
  // ✅ Tạo ID duy nhất cho thiết bị (Web + Android + iOS + Desktop)
  static const _uuid = Uuid();
  /// ✅ Hàm lấy DeviceId duy nhất (Web + Android + iOS + Desktop)
  ///   - Tự động lưu cache vào SharedPreferences để tái sử dụng.
  ///   - Dùng SHA-1 để rút gọn và ẩn thông tin thiết bị.
  ///   - Cho kết quả ổn định trên cùng thiết bị (kể cả Web đa trình duyệt).
  // static Future<String> getHashedDeviceId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   // 🔹 Nếu có ID đã lưu → trả về luôn
  //   final cachedId = prefs.getString('cached_device_id');
  //   if (cachedId != null && cachedId.isNotEmpty) {
  //     return cachedId;
  //   }
  //
  //   String rawId = "unknown_device";
  //   final deviceInfo = DeviceInfoPlugin();
  //   try {
  //     if (kIsWeb) {
  //       final webInfo = await deviceInfo.webBrowserInfo;
  //       // 🧠 Dùng localStorage để đồng bộ Safari & Chrome cùng 1 ID
  //       String? browserKey = html.window.localStorage['device_uuid'];
  //       if (browserKey == null) {
  //         browserKey = _uuid.v4();
  //         html.window.localStorage['device_uuid'] = browserKey;
  //       }
  //       // 🧩 Tạo fingerprint ổn định giữa các trình duyệt trên cùng thiết bị
  //       final width = html.window.screen?.width ?? 0; //Lấy độ phân giải màn hình (theo pixel) của thiết bị
  //       final height = html.window.screen?.height ?? 0; //Lấy độ phân giải màn hình (theo pixel) của thiết bị
  //       final pixelRatio = html.window.devicePixelRatio; //Lấy tỷ lệ mật độ điểm ảnh (device pixel ratio)
  //       //Ghép lại tạp thành ID riêng
  //       //rawId = "web_${webInfo.platform ?? 'web'}_${webInfo.hardwareConcurrency ?? 0}_${webInfo.maxTouchPoints ?? 0}_${width}x${height}_${pixelRatio.toStringAsFixed(1)}";
  //       rawId = "web_${webInfo.platform}_${webInfo.vendor}_${width}x${height}_${pixelRatio.toStringAsFixed(1)}_$browserKey";
  //     } else if (Platform.isAndroid) {
  //       final info = await deviceInfo.androidInfo;
  //       String? deviceUuid = prefs.getString('android_device_uuid');
  //       deviceUuid ??= _uuid.v4();
  //       await prefs.setString('android_device_uuid', deviceUuid);
  //       rawId ="android_${info.model}_${info.device}_${info.manufacturer}_$deviceUuid";
  //       // final androidInfo = await deviceInfo.androidInfo;
  //       // rawId = "${androidInfo.id}_${androidInfo.model}_${androidInfo.device}_${androidInfo.manufacturer}_${androidInfo.serialNumber ?? ''}";
  //        } else if (Platform.isIOS) {
  //       final info = await deviceInfo.iosInfo;
  //       String? deviceUuid = prefs.getString('ios_device_uuid');
  //       deviceUuid ??= _uuid.v4();
  //       await prefs.setString('ios_device_uuid', deviceUuid);
  //       rawId = "ios_${info.identifierForVendor}_${info.model}_$deviceUuid";
  //       //final iosInfo = await deviceInfo.iosInfo;
  //      // rawId = "${iosInfo.identifierForVendor}_${iosInfo.model}_${iosInfo.systemName}";
  //     } else if (Platform.isWindows) {
  //       final winInfo = await deviceInfo.windowsInfo;
  //       rawId =
  //       "${winInfo.deviceId}|${winInfo.computerName}|${winInfo.numberOfCores}";
  //     } else if (Platform.isMacOS) {
  //       final macInfo = await deviceInfo.macOsInfo;
  //       rawId =
  //       "${macInfo.systemGUID ?? 'mac_unknown'}|${macInfo.computerName}|${macInfo.arch}";
  //     } else if (Platform.isLinux) {
  //       final linuxInfo = await deviceInfo.linuxInfo;
  //       rawId =
  //       "${linuxInfo.machineId ?? 'linux_unknown'}|${linuxInfo.name}|${linuxInfo.version}";
  //     }
  //   } catch (e) {
  //     rawId = "error_${e.toString()}";
  //   }
  //
  //   // 🔐 Hash SHA-1 → an toàn & ngắn gọn
  //   final bytes = utf8.encode(rawId);
  //   final digest = sha1.convert(bytes);
  //   final hashedId = digest.toString();
  //
  //   // 💾 Lưu lại vào local cache để tái sử dụng lần sau
  //   await prefs.setString('cached_device_id', hashedId);
  //   return hashedId;
  // }
  //
  // /// 🔄 Xóa ID thiết bị khi đăng xuất / reset
  // Future<void> resetDeviceId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('cached_device_id');
  //   if (kIsWeb) {
  //     html.window.localStorage.remove('device_key');
  //   }
  // }

  // /// Xử lý đăng nhập thành công + Giới hạn 1 tài khoản / 1 thiết bị
  // Future<void> handleLoginSuccess(String email) async {
  //   final hashedDeviceId = await getHashedDeviceId();
  //   deviceId = hashedDeviceId;
  //
  //   final uid = _auth.currentUser!.uid;
  //   final userDoc = _firestore.collection("userLogin").doc(uid);
  //   final snapshot = await userDoc.get();
  //
  //   // 🔍 Kiểm tra xem deviceId này đã tồn tại ở tài khoản khác chưa
  //   final existingDevice = await _firestore
  //       .collection("userLogin")
  //       .where("deviceIds", arrayContains: deviceId)
  //       .get();
  //
  //   if (existingDevice.docs.isNotEmpty) {
  //     final otherUserId = existingDevice.docs.first.id;
  //     if (otherUserId != uid) {
  //       // ❌ Thiết bị này đã đăng nhập tài khoản khác
  //       showSnackBAR(
  //           context,
  //           "Thiết bị này đã được sử dụng để đăng nhập tài khoản khác. "
  //               "Vui lòng đăng xuất tài khoản đó trước khi tiếp tục.");
  //       await _auth.signOut();
  //       return;
  //     }
  //   }
  //
  //   // ✅ Kiểm tra tài khoản này có đăng nhập trên thiết bị khác không
  //   if (snapshot.exists) {
  //     final data = snapshot.data() ?? {};
  //     final List<dynamic> devices =
  //     (data['deviceIds'] is List) ? List.from(data['deviceIds']) : [];
  //
  //     if (devices.isNotEmpty && !devices.contains(deviceId)) {
  //       showSnackBAR(context,
  //           "Tài khoản này đã đăng nhập trên thiết bị khác.\nVui lòng đăng xuất thiết bị cũ trước.");
  //       await _auth.signOut();
  //       return;
  //     }
  //
  //     // Nếu chưa có deviceId hoặc cùng thiết bị → cho phép login
  //     if (!devices.contains(deviceId)) {
  //       await userDoc.set({
  //         "deviceIds": FieldValue.arrayUnion([deviceId]),
  //       }, SetOptions(merge: true));
  //     }
  //   } else {
  //     // 🔰 User mới → tạo mới
  //     await userDoc.set({
  //       "email": emailController.text.trim(),
  //       "deviceIds": [deviceId],
  //       "createdAt": FieldValue.serverTimestamp(),
  //     });
  //   }
  //   // 👉 Nếu hợp lệ thì cho vào trang chính
  //   showSnackBAR(context, "Đăng nhập thành công!");
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => MyPage()),
  //   );
  // }

//.......
  /// ✅ Lấy Device ID duy nhất và hash SHA-1 (ổn định, không tiết lộ thông tin cá nhân)
  static Future<String> getHashedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔄 Dùng cache để giảm gọi thiết bị nhiều lần
    final cachedId = prefs.getString('cached_device_id');
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;

    final deviceInfo = DeviceInfoPlugin();
    String rawId = "unknown_device";

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        //Ghép fingerprint dựa trên userAgent và độ phân giải
        final userAgent = webInfo.userAgent??'unknown';
        final width = html.window.screen?.width ?? 0;
        final height = html.window.screen?.height ?? 0;
        final pixelRatio = html.window.devicePixelRatio;

        // Hash fingerprint -> ổn định trên mọi trình duyệt cùng máy
        final fingerprint =
        sha1.convert(utf8.encode("$userAgent-$width-$height-$pixelRatio")).toString();

        // Dùng localStorage để giữ ID cố định giữa các lần đăng nhập
        // Dùng LocalStorage để giữ nguyên ID giữa các lần mở
        String? browserKey = html.window.localStorage['device_uuid'];
        browserKey ??= fingerprint.substring(0, 20); // cắt ngắn ID
        html.window.localStorage['device_uuid'] = browserKey;

        // String? browserKey = html.window.localStorage['device_uuid'];
        // if (browserKey == null) {
        //   // Ưu tiên fingerprint, nếu fingerprint null hoặc lỗi → tạo UUID
        //   if (fingerprint.isNotEmpty) {
        //     browserKey = fingerprint.substring(0, 20);
        //   } else {
        //     browserKey = _uuid.v4();
        //   }
        //   html.window.localStorage['device_uuid'] = browserKey;
        // }

        // fingerprint cơ bản nhưng ổn định (ẩn thông tin cá nhân)
        rawId =
        "web_${webInfo.platform}_${width}x${height}_${pixelRatio.toStringAsFixed(1)}_$browserKey";

      } else if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        String? deviceUuid = prefs.getString('android_device_uuid');
        deviceUuid ??= _uuid.v4();
        await prefs.setString('android_device_uuid', deviceUuid);
        rawId =
        "android_${info.model}_${info.manufacturer}_${info.device}_$deviceUuid";

      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        String? deviceUuid = prefs.getString('ios_device_uuid');
        deviceUuid ??= _uuid.v4();
        await prefs.setString('ios_device_uuid', deviceUuid);
        rawId =
        "ios_${info.model}_${info.systemName}_${info.systemVersion}_$deviceUuid";

      } else {
        // Desktop (Windows, macOS, Linux)
        String? desktopUuid = prefs.getString('desktop_device_uuid');
        desktopUuid ??= _uuid.v4();
        await prefs.setString('desktop_device_uuid', desktopUuid);
        rawId = "desktop_$desktopUuid";
      }
    } catch (e) {
      rawId = "error_${e.hashCode}";
    }

    // Mã hóa SHA-1 → ngắn gọn, không thể truy ngược
    final hashedId = sha1.convert(utf8.encode(rawId)).toString();
    await prefs.setString('cached_device_id', hashedId);

    return hashedId;
  }

  /// 🔄 Reset device ID khi đăng xuất
  static Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_device_id');
    await prefs.remove('android_device_uuid');
    await prefs.remove('ios_device_uuid');
    await prefs.remove('desktop_device_uuid');
    if (kIsWeb) html.window.localStorage.remove('device_uuid');
  }
  /// ✅ Xử lý khi đăng nhập thành công — ràng buộc tài khoản ↔ thiết bị
  Future<void> handleLoginSuccess(String email) async {
    try {
      final hashedDeviceId = await getHashedDeviceId();
      final user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy người dùng. Vui lòng đăng nhập lại."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final uid = user.uid;
      final userDoc = _firestore.collection("userLogin").doc(uid);
      final snapshot = await userDoc.get();

      // 🔍 Kiểm tra xem thiết bị đã dùng tài khoản khác chưa
      final existingDevice = await _firestore
          .collection("userLogin")
          .where("deviceIds", arrayContains: hashedDeviceId)
          .get();

      if (existingDevice.docs.isNotEmpty && existingDevice.docs.first.id != uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "⚠️ Thiết bị này đã đăng nhập bằng tài khoản khác. Vui lòng đăng xuất tài khoản đó trước."),
            backgroundColor: Colors.redAccent,
          ),
        );
        await _auth.signOut();
        return;
      }

      // ✅ Nếu userDoc đã tồn tại
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final List<dynamic> devices =
        (data['deviceIds'] is List) ? List.from(data['deviceIds']) : [];

        if (devices.isNotEmpty && !devices.contains(hashedDeviceId)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "⚠️ Tài khoản này đã được đăng nhập trên thiết bị khác. Vui lòng đăng xuất thiết bị cũ."),
              backgroundColor: Colors.orange,
            ),
          );
          await _auth.signOut();
          return;
        }

        // Nếu chưa lưu Device ID → thêm mới
        if (!devices.contains(hashedDeviceId)) {
          await userDoc.set({
            "deviceIds": FieldValue.arrayUnion([hashedDeviceId]),
            "lastLogin": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          // Cập nhật thời gian đăng nhập cuối
          await userDoc.update({
            "lastLogin": FieldValue.serverTimestamp(),
          });
        }
      } else {
        // 🔰 User mới → tạo bản ghi mới
        await userDoc.set({
          "deviceIds": [hashedDeviceId],
          "createdAt": FieldValue.serverTimestamp(),
          "lastLogin": FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Đăng nhập thành công!"),
            backgroundColor: Colors.green,
          ),
      );

      // 👉 Điều hướng đến trang chính
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyPage()),
        );
      }

    } catch (e) {
      debugPrint("❌ Lỗi khi xử lý đăng nhập: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập thất bại: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  //....END



  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final result = await _authService.loginUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result == "Thành công") {
      // ✅ Chuyển trách nhiệm điều hướng cho handleLoginSuccess
      await handleLoginSuccess(emailController.text.trim());
    } else {
      setState(() {
        isLoading = false;
      });
      // Thông báo đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập $result"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
    // void _login() async {
    // setState(() {
    //   isLoading = true;
    // });
    // final result = await _authService.loginUser(
    //   email: emailController.text,
    //   password: passwordController.text,
    // );
    // if ((result == "Thành công") & (_formKey.currentState!.validate())) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   await handleLoginSuccess(emailController.text);
    //   //showSnackBAR(context, "Đăng nhập thành công!");
    //   // Navigator.pushReplacement(
    //   //   context,
    //   //   MaterialPageRoute(builder: (context) => MyPage()),
    //   // );
    // } else {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   // Thông báo đăng nhập thất bại
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Đăng nhập $result"),
    //       duration: const Duration(seconds: 2),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
   // }

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
