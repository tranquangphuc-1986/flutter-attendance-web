import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceQRScreen extends StatefulWidget {
  final String phone; // id hoặc phone của sinh viên
  const AttendanceQRScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<AttendanceQRScreen> createState() => _AttendanceQRScreenState();
}

class _AttendanceQRScreenState extends State<AttendanceQRScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessingScan = false;
  bool hasCheckedIn = false;
  String statusMessage = "Đưa mã QR vào khung quét";
  String lastAction = "";

  Timer? _deadlineTimer;
  final int CHECKIN_START_HOUR = 7; // 07:00
  final int CHECKIN_END_HOUR = 23;  // 09:00

  @override
  void initState() {
    super.initState();
    _setupDeadlineTimerForToday();
    _checkGpsAndPermissions();
  }

  @override
  void dispose() {
    _deadlineTimer?.cancel();
    cameraController.dispose();
    super.dispose();
  }

  // Hàm set deadline 23h
  void _setupDeadlineTimerForToday() {
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, CHECKIN_END_HOUR, 0);
    if (now.isAfter(deadline)) return;
    final duration = deadline.difference(now);
    _deadlineTimer = Timer(duration, () async {
      if (!hasCheckedIn) {
        await _saveAttendanceToFirebase("NOT_CHECKED", "AUTO");
      }
    });
  }

  // Kiểm tra thời gian hợp lệ
  bool _isWithinTimeWindow() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, CHECKIN_START_HOUR, 0);
    final end = DateTime(now.year, now.month, now.day, CHECKIN_END_HOUR, 0);
    return !now.isBefore(start) && !now.isAfter(end);
  }
//Kiem tra GPS
  Future<void> _initFlow() async {
    //await _checkGpsAndPermissions();
   // await _fetchStudentInfo();
    //_setupDeadlineTimerForToday();
  }
  // ---------- Permissions & GPS ----------
  Future<void> _checkGpsAndPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          //statusMessage = "Vui lòng bật GPS để điểm danh.";
          _showSnackbar('Vui lòng bật GPS để điểm danh.');
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            statusMessage = "Ứng dụng cần quyền GPS. Vui lòng cho phép.";
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          statusMessage =
          "Quyền GPS bị chặn vĩnh viễn. Mở cài đặt để cấp quyền.";
        });
        return;
      }

      setState(() {
        statusMessage = "Sẵn sàng quét QR để điểm danh.";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Lỗi quyền/GPS: $e";
      });
    }
  }

  // Lưu Firestore
  Future<void> _saveAttendanceToFirebase(String status, String method,
      {double? qrLat, double? qrLng, double? phoneLat, double? phoneLng, double? distance}) async {
    await FirebaseFirestore.instance
        .collection("attendanceqr")
        .doc("${widget.phone}_${DateTime.now().toIso8601String()}")
        .set({
      "phone": widget.phone,
      "status": status, // PRESENT | ABSENT | LEAVE | NOT_CHECKED
      "method": method, // GPS_QR | MANUAL | AUTO
      "timestamp": FieldValue.serverTimestamp(),
      "qrLat": qrLat,
      "qrLng": qrLng,
      "phoneLat": phoneLat,
      "phoneLng": phoneLng,
      "distanceMeters": distance,
    });
    setState(() {
      hasCheckedIn = true;
      lastAction = status;
      statusMessage = "Đã lưu trạng thái: $status";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Điểm danh $status thành công")));
  }

  // Quét QR
  double? _extractDoubleFromJson(Map obj, List<String> candidates) {
    for (final key in candidates) {
      if (obj.containsKey(key)) {
        return _extractDouble(obj[key]); // dùng hàm ngắn gọn
      }
    }
    return null;
  }

  double? _extractDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // if (isProcessingScan || hasCheckedIn) return;
    // final raw = capture.barcodes.first.rawValue;
    // if (raw == null) return;
    // isProcessingScan = true;

    //test code cu khi lam SQL.....
    if (isProcessingScan || hasCheckedIn) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;
    // process once
    isProcessingScan = true;
    setState(() {
      statusMessage = "Đang xử lý QR...";
    });
    //....end...

    try {
      final obj = jsonDecode(raw);
      //Cach 1
      // double qrLat = (obj["latitude"] ?? obj["lat"]).toDouble();
      // double qrLng = (obj["longitude"] ?? obj["lng"]).toDouble();
      // double allowedRadius = (obj["allowed_radius"] ?? 50).toDouble();

      //Cach 2
      // double? qrLat = _extractDouble(
      //     obj['lat'] ?? obj['latitude'] ?? obj['class_lat']);
      // double? qrLng = _extractDouble(
      //     obj['lng'] ?? obj['longitude'] ?? obj['class_lng']);
      // double allowedRadius = _extractDouble(obj['allowed_radius']) ?? 50.0;

      //Cach 3
      double qrLat = _extractDoubleFromJson(obj, [
        'lat',
        'latitude',
        'class_lat',
      ])?? (throw Exception("null lat"));
      double qrLng = _extractDoubleFromJson(obj, [
        'lng',
        'longitude',
        'class_lng',
      ])?? (throw Exception("null long"));
      double allowedRadius =
          _extractDoubleFromJson(obj, ['radius', 'allowed_radius'] ) ?? 50.0;

      if (!_isWithinTimeWindow()) {
        _showAlert("Ngoài khung giờ", "Chỉ được điểm danh từ 7h đến 9h");
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();
      final double distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          qrLat,
          qrLng);

      if (distance <= allowedRadius) {
        await _saveAttendanceToFirebase("PRESENT", "GPS_QR",
            qrLat: qrLat, qrLng: qrLng, phoneLat: pos.latitude, phoneLng: pos.longitude, distance: distance);
      } else {
        _showAlert("Ngoài phạm vi",
            "Khoảng cách ${distance.toStringAsFixed(1)} m > $allowedRadius m");
      }
    } catch (e) {
      _showAlert("Lỗi", "QR code không hợp lệ: $e");
    } finally {
      isProcessingScan = false;
    }
  }

  // Manual chọn trạng thái
  Future<void> _onManualStatus(String label) async {
    await _saveAttendanceToFirebase(label == "Vắng mặt" ? "ABSENT" : "LEAVE", "MANUAL");
  }
// ---------- UI helpers ----------
  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  // Alert
  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Điểm danh QR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
            tooltip: "Đổi camera",
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
            tooltip: "Bật/tắt đèn",
          ),
        ],
      ),
      body: Column(
        children: [
        Expanded(
        flex: 5,
        child: MobileScanner(
          controller: cameraController,
          fit: BoxFit.cover,
          onDetect: _onDetect,
        ),
      ),
      Expanded(
        flex: 3,
        child: Column(
            children: [
        ElevatedButton.icon(
        icon: const Icon(Icons.qr_code),
        label: const Text("Quét QR (Có mặt)"),
        onPressed: _isWithinTimeWindow() ? () {} : null,
      ),
      Row(
        children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: () => _onManualStatus("Vắng mặt"),
                  child: const Text("Vắng mặt"))),
          const SizedBox(width: 10),
          Expanded(
              child: OutlinedButton(
                  onPressed: () => _onManualStatus("Nghỉ phép"),
                  child: const Text("Nghỉ phép"))),
        ],
      ),
              Text("Trạng thái: $lastAction"),
              Text(statusMessage),
            ],
        ),
      )
        ],
      ),
    );
  }
}