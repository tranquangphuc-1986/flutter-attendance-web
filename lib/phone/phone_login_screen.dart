// // ignore: deprecated_member_use
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;
// import 'dart:convert';
// import 'dart:io' show Platform;
// import 'package:app_02/Widgets/snackbar.dart';
// import 'package:app_02/home_page/my_home_screen.dart';
// import 'package:app_02/Widgets/my_button.dart';
// import 'package:app_02/email/email_signup_screen.dart';
// import 'package:app_02/email/email_forgot_password_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:crypto/crypto.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:app_02/service/email_auth_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
//
// class EmailLogin extends StatefulWidget {
//   const EmailLoginn({super.key});
//
//   @override
//   State<EmailLoginScreen> createState() => _EmailLoginScreenState();
// }
//
// class _EmailLoginScreenState extends State<EmailLoginScreen> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   bool isLoading = false; //vòng tròn quay loading
//   bool isPasswordHidden = true;
//   final _formKey = GlobalKey<FormState>();
//   final AuthService _authService = AuthService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String errorMessage = '';
//   String? deviceId;
//   // -------------------------
// // 🔑 Hàm tạo fingerprint ổn định đa nền tảng
//   static Future<String> getDeviceFingerprintHybrid() async {
//     try {
//       // 📦 Ưu tiên dùng cache (SharedPreferences hoặc localStorage)
//       if (kIsWeb) {
//         final cached = html.window.localStorage['device_id'];
//         if (cached != null && cached.isNotEmpty) return cached;
//       } else {
//         final prefs = await SharedPreferences.getInstance();
//         final cached = prefs.getString('device_id');
//         if (cached != null && cached.isNotEmpty) return cached;
//       }
//
//       String rawId = "unknown_device";
//
//       if (kIsWeb) {
//         // 🧭 Web Fingerprint
//         final navigator = html.window.navigator;
//         final platform = navigator.platform ?? '';
//         final vendor = navigator.vendor ?? '';
//         final hardwareConcurrency =
//             navigator.hardwareConcurrency?.toString() ?? '';
//         final screenWidth = html.window.screen?.width.toString() ?? '';
//         final screenHeight = html.window.screen?.height.toString() ?? '';
//         final colorDepth = html.window.screen?.colorDepth?.toString() ?? '';
//         final timezone = DateTime.now().timeZoneName;
//
//         // 🧩 Base info fingerprint
//         rawId =
//         'web_${platform}|${vendor}|${hardwareConcurrency}|${screenWidth}x${screenHeight}|$colorDepth|$timezone';
//
//         // 🧂 App salt để tránh trùng giữa các app
//         const appSalt = 'THAMM_UU_APP_SALT_V1';
//         rawId += '_$appSalt';
//       } else {
//         // 📱 Mobile Fingerprint
//         final deviceInfo = DeviceInfoPlugin();
//         if (Platform.isAndroid) {
//           final info = await deviceInfo.androidInfo;
//           rawId =
//           '${info.id}_${info.model}_${info.manufacturer}_${info.device}_${info.version.sdkInt}';
//         } else if (Platform.isIOS) {
//           final info = await deviceInfo.iosInfo;
//           rawId =
//           '${info.identifierForVendor}_${info.model}_${info.systemVersion}_${info.systemName}';
//         } else if (Platform.isWindows) {
//           final info = await deviceInfo.windowsInfo;
//           rawId = '${info.deviceId}_${info.computerName}_${info.numberOfCores}';
//         } else if (Platform.isMacOS) {
//           final info = await deviceInfo.macOsInfo;
//           rawId =
//           '${info.systemGUID}_${info.computerName}_${info.arch}_${info.model}';
//         } else if (Platform.isLinux) {
//           final info = await deviceInfo.linuxInfo;
//           rawId =
//           '${info.machineId}_${info.name}_${info.version}_${info.prettyName}';
//         }
//       }
//
//       // 🔐 Hash SHA-256 → gọn & an toàn
//       final bytes = utf8.encode(rawId);
//       final digest = sha256.convert(bytes).toString();
//
//       // 💾 Lưu cache lại để dùng lần sau
//       if (kIsWeb) {
//         html.window.localStorage['device_id'] = digest;
//       } else {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('device_id', digest);
//       }
//
//       return digest;
//     } catch (e) {
//       debugPrint('❌ Error fingerprint: $e');
//       return 'device_${DateTime.now().millisecondsSinceEpoch}';
//     }
//   }
//
//   /// 🔄 Xóa ID thiết bị khi đăng xuất / reset
//   static Future<void> resetDeviceId() async {
//     if (kIsWeb) {
//       html.window.localStorage.remove('device_id');
//     } else {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('device_id');
//     }
//   }
//
//   /// 🧭 Xử lý đăng nhập + giới hạn 1 tài khoản / 1 thiết bị
//   Future<void> handleLoginSuccess(String email) async {
//     deviceId = await getDeviceFingerprintHybrid();
//
//     final uid = _auth.currentUser!.uid;
//     final userDoc = _firestore.collection("userLogin").doc(uid);
//     final snapshot = await userDoc.get();
//
//     // 🔍 Kiểm tra xem deviceId này đã tồn tại ở tài khoản khác chưa
//     final existingDevice = await _firestore
//         .collection("userLogin")
//         .where("deviceIds", arrayContains: deviceId)
//         .get();
//
//     if (existingDevice.docs.isNotEmpty) {
//       final otherUserId = existingDevice.docs.first.id;
//       if (otherUserId != uid) {
//         showSnackBAR(
//             context,
//             "Thiết bị này đã được sử dụng để đăng nhập tài khoản khác.\n"
//                 "Vui lòng đăng xuất tài khoản đó trước khi tiếp tục.");
//         await _auth.signOut();
//         return;
//       }
//     }
//
//     // ✅ Kiểm tra tài khoản này có đăng nhập thiết bị khác không
//     if (snapshot.exists) {
//       final data = snapshot.data() ?? {};
//       final List<dynamic> devices =
//       (data['deviceIds'] is List) ? List.from(data['deviceIds']) : [];
//
//       if (devices.isNotEmpty && !devices.contains(deviceId)) {
//         showSnackBAR(context,
//             "Tài khoản này đã đăng nhập trên thiết bị khác.\nVui lòng đăng xuất thiết bị cũ trước.");
//         await _auth.signOut();
//         return;
//       }
//
//       // Nếu chưa có deviceId hoặc cùng thiết bị → cho phép login
//     if (!devices.contains(deviceId)) {
//         await userDoc.set({
//           "deviceIds": FieldValue.arrayUnion([deviceId]),
//           "lastLogin": FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       } else {
//         // Cập nhật thời gian đăng nhập cuối
//         await userDoc.update({
//           "lastLogin": FieldValue.serverTimestamp(),
//         });
//       }
//     } else {
//       // 🔰 User mới → tạo mới
//       await userDoc.set({
//         "deviceIds": [deviceId],
//         "lastLogin": FieldValue.serverTimestamp(),
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//     }
//
//     showSnackBAR(context, "Đăng nhập thành công!");
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => MyPage()),
//     );
//   }
//
//   // Nút đăng nhập
//   void _login() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     final result = await _authService.loginUser(
//       email: emailController.text,
//       password: passwordController.text,
//     );
//
//     if ((result == "Thành công") & (_formKey.currentState!.validate())) {
//       setState(() => isLoading = false);
//       await handleLoginSuccess(emailController.text);
//     } else {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Đăng nhập $result"),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   // -------------------------
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Image.asset("img/logocand.png"),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "PHÒNG THAM MƯU",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 70),
//                 //Tạo hàng đăng nhập email
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: emailController,
//                         decoration: InputDecoration(
//                           labelText: "Email",
//                           hintText: "abc@gmail",
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (v) {
//                           if (v == null || v.trim().isEmpty) {
//                             return "Nhập Email";
//                           }
//                           final emailRegex = RegExp(
//                             r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
//                           );
//                           if (!emailRegex.hasMatch(v.trim())) {
//                             return "Email không hợp lệ";
//                           }
//                           return null;
//                         },
//                       ),
//
//                       //Tạo hàng đăng nhập mật khẩu
//                       const SizedBox(height: 30),
//                       TextFormField(
//                         controller: passwordController,
//                         decoration: InputDecoration(
//                           labelText: "Mật khẩu",
//                           hintText: "Nhập mật khẩu của bạn",
//                           border: OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               isPasswordHidden
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 isPasswordHidden = !isPasswordHidden;
//                               });
//                             },
//                           ),
//                         ),
//                         validator: (v) {
//                           if (v == null || v.trim().isEmpty || v.length < 6) {
//                             return "Mật khẩu không đúng";
//                           }
//                           return null;
//                         },
//                         obscureText: isPasswordHidden,
//                         obscuringCharacter: '*',
//                       ),
//                       //tạo một vòng tròn xoay loading
//                       const SizedBox(height: 50),
//                       isLoading
//                           ? const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.blue,
//                             ),
//                           )
//                           //Tạo nút button đăng nhập
//                           : SizedBox(
//                             width: double.infinity,
//                             child: MyButton(
//                               onTap: _login,
//                               buttontext: "Đăng nhập",
//                             ),
//                           ),
//                       SizedBox(height: 20),
//                       const EmailForgotPasswordScreen(),
//                       const SizedBox(height: 100),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Bạn chưa có tài khoản?",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           GestureDetector(
//                             child: Text(
//                               " Đăng ký",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.red,
//                                 letterSpacing: -1,
//                               ),
//                             ),
//                             onTap: () {
//                               //xử lý khi click vào chữ đăng ký, sẽ ra form đăng ký
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EmailSignupScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
