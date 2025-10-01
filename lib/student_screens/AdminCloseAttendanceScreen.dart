import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCloseAttendanceScreen extends StatefulWidget {
  @override
  _AdminCloseAttendanceScreenState createState() =>
      _AdminCloseAttendanceScreenState();
}

class _AdminCloseAttendanceScreenState
    extends State<AdminCloseAttendanceScreen> {
  bool _loading = false;
  String _statusMessage = "";

  Future<void> _closeAttendance() async {
    setState(() {
      _loading = true;
      _statusMessage = "⏳ Đang quét dữ liệu...";
    });

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final startTs = Timestamp.fromDate(startOfDay);
    final endTs = Timestamp.fromDate(endOfDay);

    final userSnap = await FirebaseFirestore.instance.collection("userLogin").get();

    int updatedCount = 0;

    for (var userDoc in userSnap.docs) {
      final userData = userDoc.data();
  final phone = userData["phone"]??"";
  if(phone.isEmpty) continue;
      // Kiểm tra sinh viên này đã có điểm danh hôm nay chưa
      final attendanceSnap = await FirebaseFirestore.instance
          .collection("attendanceqr")
         // .where("uid", isEqualTo: userDoc.id)
          .where("phone", isEqualTo: phone)
          .where("timestamp", isGreaterThanOrEqualTo: startTs)
          .where("timestamp", isLessThanOrEqualTo: endTs)
          .limit(1)
          .get();

      if (attendanceSnap.docs.isEmpty) {
        // Nếu chưa có, thêm bản ghi NOT_CHECKED
        await FirebaseFirestore.instance.collection("attendanceqr").add({
         // "uid": userDoc.id,
          "phone": phone,
          "name": userData["name"] ?? "",
        // "phone": userData["phone"] ?? "",
          "status": "NOT_CHECKED",
          "note": "Quá giờ điểm danh",
          "method": "AUTO",
          "timestamp": Timestamp.now(),
        });
        updatedCount++;
      }
    }

    setState(() {
      _loading = false;
      _statusMessage = "✅ Đã cập nhật $updatedCount sinh viên chưa điểm danh thành 'NOT_CHECKED'.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Đóng điểm danh")),
        body: Center(
          child: _loading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text(_statusMessage),
            ],
          )
              : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          ElevatedButton.icon(
          icon: Icon(Icons.lock_clock),
          label: Text("Đóng điểm danh"),
          onPressed: _closeAttendance,
        ),
        SizedBox(height: 20),
        Text(_statusMessage,
          textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.red)),
              ],
          ),
        ),
    );
  }
}