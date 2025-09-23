// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AttendanceScreen extends StatefulWidget {
//   final String studentId;
//
//   const AttendanceScreen({super.key, required this.studentId});
//
//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }
//
// class _AttendanceScreenState extends State<AttendanceScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String status = "Chưa điểm danh";
//   bool isLoading = false;
//
//   /// ✅ Hàm tính khoảng cách giữa 2 tọa độ
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const R = 6371000; // bán kính Trái Đất (m)
//     final dLat = (lat2 - lat1) * pi / 180;
//     final dLon = (lon2 - lon1) * pi / 180;
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
//             sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }
//
//   /// ✅ Quét QR Code để điểm danh
//   Future<void> scanQRCodeAndMark() async {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (_) => QRViewExample(onQRViewCreated: (qrData) async {
//               Navigator.pop(context); // đóng màn hình scanner
//               try {
//                 final data = jsonDecode(qrData);
//                 final qrLat = data["latitude"];
//                 final qrLng = data["longitude"];
//                 final allowedRadius = data["allowed_radius"];
//
//                 // Lấy vị trí hiện tại
//                 bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//                 if (!serviceEnabled) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("⚠️ Vui lòng bật GPS")));
//                   return;
//                 }
//
//                 LocationPermission permission = await Geolocator.checkPermission();
//                 if (permission == LocationPermission.denied) {
//                   permission = await Geolocator.requestPermission();
//                   if (permission == LocationPermission.denied) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("⚠️ Không có quyền truy cập GPS")));
//                     return;
//                   }
//                 }
//
//                 final position = await Geolocator.getCurrentPosition(
//                     desiredAccuracy: LocationAccuracy.high);
//
//                 final distance = calculateDistance(
//                     qrLat, qrLng, position.latitude, position.longitude);
//
//                 if (distance <= allowedRadius) {
//                   await _markAttendance("Có mặt");
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("⚠️ Ngoài phạm vi điểm danh")),
//                   );
//                 }
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("⚠️ QRCode không hợp lệ")),
//                 );
//               }
//             }),
//         ),
//     );
//   }
//
//   /// ✅ Cập nhật Firestore
//   Future<void> _markAttendance(String newStatus) async {
//     setState(() => isLoading = true);
//
//     final now = DateTime.now();
//     if (now.hour < 7 || now.hour >= 9 || now.weekday >= 6) {
//       // weekday: 6 = Thứ 7, 7 = CN
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("⚠️ Ngoài giờ điểm danh (7h-9h, T2-T6)")));
//       setState(() => isLoading = false);
//       return;
//     }
//
//     final todayId =
//         "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
//
//     await _firestore
//         .collection("attendance")
//         .doc("${todayId}_${widget.studentId}")
//         .set({
//       "studentId": widget.studentId,
//       "date": todayId,
//       "status": newStatus,
//       "timestamp": FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//
//     setState(() {
//       status = newStatus;
//       isLoading = false;
//     });
//
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("✅ Điểm danh: $newStatus")));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Điểm danh")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Trạng thái: $status"),
//             const SizedBox(height: 20),
//
//             /// Nút quét QRCode
//             ElevatedButton.icon(
//               icon: Icon(Icons.qr_code_scanner),
//               label: Text("Quét QRCode (Có mặt)"),
//               onPressed: scanQRCodeAndMark,
//             ),
//
//             const SizedBox(height: 20),
//
//             /// Các trạng thái khác (tự chọn)
//             Wrap(
//               spacing: 10,
//               children: [
//                 ElevatedButton(
//                     onPressed: () => _markAttendance("Ốm"),
//                     child: Text("Vắng do ốm")),
//                 ElevatedButton(
//                     onPressed: () => _markAttendance("Công tác"),
//                     child: Text("Vắng do công tác")),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// 🔹 Màn hình quét QRCode
// class QRViewExample extends StatelessWidget {
//   final Function(String) onQRViewCreated;
//   const QRViewExample({super.key, required this.onQRViewCreated});
//
//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//     return Scaffold(
//       appBar: AppBar(title: Text("Quét QR Code")),
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: (controller) {
//           controller.scannedDataStream.listen((scanData) {
//             onQRViewCreated(scanData.code ?? "");
//             controller.dispose();
//           });
//         },
//       ),
//     );
//   }
// }