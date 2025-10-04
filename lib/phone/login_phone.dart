// import 'package:app_02/home_page/my_home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:app_02/service/phone_auth_service.dart';
//
//
// class LoginPhoneScreen extends StatefulWidget {
//   @override
//   _LoginPhoneScreenState createState() => _LoginPhoneScreenState();
// }
//
// class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final AuthServicePhone _authService = AuthServicePhone();
//
//   bool otpSent = false;
//
//   void _sendOtp() async {
//     await _authService.sendOtp(
//       phoneController.text,
//       onCodeSent: (verId) {
//         setState(() => otpSent = true);
//       },
//       onError: (msg) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//       },
//     );
//   }
//
//   void _verifyOtp() async {
//     final success =
//     await _authService.verifyOtp(otpController.text, phoneController.text);
//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => MyPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("OTP không hợp lệ hoặc hết hạn")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Đăng nhập OTP + Device Binding")),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: phoneController,
//               decoration: InputDecoration(labelText: "Số điện thoại"),
//               keyboardType: TextInputType.phone,
//             ),
//             if (!otpSent)
//               ElevatedButton(onPressed: _sendOtp, child: Text("Gửi OTP")),
//             if (otpSent) ...[
//               TextField(
//                 controller: otpController,
//                 decoration: InputDecoration(labelText: "Nhập OTP"),
//                 keyboardType: TextInputType.number,
//               ),
//               ElevatedButton(onPressed: _verifyOtp, child: Text("Xác minh OTP")),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }