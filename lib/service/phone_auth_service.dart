// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:crypto/crypto.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
//
// class AuthServicePhone {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   String? verificationId;
//   String? deviceId;
//
//   /// Lấy ID thiết bị và có mã hóa (Android/iOS/Web)
//   //  static Future<String> getHashedDeviceId() async {
//   //     String rawId;
//   //   final deviceInfo = DeviceInfoPlugin();
//   //
//   //     try {
//   //       if (kIsWeb) {
//   //         final webInfo = await deviceInfo.webBrowserInfo;
//   //         rawId = "${webInfo.vendor ?? "web"}-${webInfo.userAgent ?? "unknown"}";
//   //       } else if (Platform.isAndroid) {
//   //         final androidInfo = await deviceInfo.androidInfo;
//   //         rawId = androidInfo.id ?? androidInfo.device;
//   //       } else if (Platform.isIOS) {
//   //         final iosInfo = await deviceInfo.iosInfo;
//   //         rawId = iosInfo.identifierForVendor ?? "unknown_ios";
//   //       } else if (Platform.isWindows) {
//   //         final winInfo = await deviceInfo.windowsInfo;
//   //         rawId = winInfo.deviceId;
//   //       } else if (Platform.isLinux) {
//   //         final linuxInfo = await deviceInfo.linuxInfo;
//   //         rawId = linuxInfo.machineId ?? "unknown_linux";
//   //       } else if (Platform.isMacOS) {
//   //         final macInfo = await deviceInfo.macOsInfo;
//   //         rawId = macInfo.systemGUID ?? "unknown_macos";
//   //       } else {
//   //         rawId = "unknown_device";
//   //       }
//   //     } catch (e) {
//   //       rawId = "error_$e";
//   //     }
//   //
//   //     // Hash SHA-1
//   //     final bytes = utf8.encode(rawId);
//   //     final digest = sha1.convert(bytes);
//   //     return digest.toString();
//   //   }
//
//   //Lấy DEVICEID thiết bị nhưng không mã hóa
//   Future<void> initDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       final info = await deviceInfo.androidInfo;
//       deviceId = info.id;
//     } else if (Platform.isIOS) {
//       final info = await deviceInfo.iosInfo;
//       deviceId = info.identifierForVendor;
//     }
//   }
//   /// Xử lý đăng nhập thành công + Device Binding
//   Future<void> handleLoginSuccess(String phone) async {
//      await initDeviceId();
//     //await getHashedDeviceId();
//     final uid = _auth.currentUser!.uid;
//     final userDoc = _db.collection("userLogin").doc(uid);
//     final snapshot = await userDoc.get();
//
//     if (snapshot.exists) {
//       // user đã có trong database
//       final List<dynamic> devices = snapshot['deviceIds'] ?? [];
//       if (!devices.contains(deviceId)) {
//         // Thiết bị mới
//         await userDoc.update({
//           "deviceIds": FieldValue.arrayUnion([deviceId])
//         });
//       }
//     } else {
//       // Tạo user mới
//       await userDoc.set({
//         "phone": phone,
//         "deviceIds": [deviceId],
//       });
//     }
//   }
//
//   /// Lấy user hiện tại
//   User? get currentUser => _auth.currentUser;
//
//   /// Đăng xuất
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }