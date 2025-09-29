import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceQRScreen extends StatefulWidget {
  final String phone; // id hoặc phone của sinh viên
  const AttendanceQRScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<AttendanceQRScreen> createState() => _AttendanceQRScreenState();
}

class _AttendanceQRScreenState extends State<AttendanceQRScreen> {
  /// Camera / scanner
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessingScan = false;
  /// State hiển thị
  bool loading = false;
  bool hasCheckedIn = false;
  String statusMessage = "Đưa mã QR vào khung quét";
  String lastAction = "";

  /// Student info (fetched from server or fallback)
  String studentName = "";
  String studentPhone = "";
  String studentClass = "";

  Timer? _deadlineTimer;
  final int CHECKIN_START_HOUR = 7; // 07:00
  final int CHECKIN_END_HOUR = 23; // 09:00

  @override
  void initState() {
    super.initState();
    _setupDeadlineTimerForToday();
    _checkGpsAndPermissions(context);
    _fetchStudentInfo();
  }

  @override
  void dispose() {
    _deadlineTimer?.cancel();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _initFlow() async {
    //await _checkGpsAndPermissions();
    // await _fetchStudentInfo();
    //_setupDeadlineTimerForToday();
  }

  // Hàm set deadline 23h
  Future<void> _autoSaveNotChecked() async {
    setState(() {
      statusMessage = "⏰ Hết hạn điểm danh. Ghi 'Chưa điểm danh'.";
    });
    await _saveAttendanceToFirebase(
      status: "NOT_CHECKED",
      method: "AUTO",
      note: "Hết hạn điểm danh - ghi tự động",
    );
  }
  void _setupDeadlineTimerForToday() {
    final now = DateTime.now();
    final deadline = DateTime(
      now.year,
      now.month,
      now.day,
      CHECKIN_END_HOUR,
      0,
    );
    if (now.isAfter(deadline)){
      // đã quá hạn hôm nay
      if (!hasCheckedIn) {
        _autoSaveNotChecked();
      }
    return;
  }
    final duration = deadline.difference(now);
    _deadlineTimer?.cancel();
    _deadlineTimer = Timer(duration, () async {
      if (!hasCheckedIn) {
        await _autoSaveNotChecked();
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

  // ---------- Permissions & GPS ----------

  //   Future<void> _checkGpsAndPermissions() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       setState(() {
  //         //statusMessage = "Vui lòng bật GPS để điểm danh.";
  //         _showSnackbar('Vui lòng bật GPS để điểm danh.');
  //       });
  //       return;
  //     }
  //
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         setState(() {
  //           statusMessage = "Ứng dụng cần quyền GPS. Vui lòng cho phép.";
  //         });
  //         return;
  //       }
  //     }
  //     if (permission == LocationPermission.deniedForever) {
  //       setState(() {
  //         statusMessage =
  //         "Quyền GPS bị chặn vĩnh viễn. Mở cài đặt để cấp quyền.";
  //       });
  //       return;
  //     }
  //
  //     setState(() {
  //       statusMessage = "Sẵn sàng quét QR để điểm danh.";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       statusMessage = "Lỗi quyền/GPS: $e";
  //     });
  //   }
  // }

  Future<bool> _checkGpsAndPermissions(BuildContext context) async {
    // 1. Kiểm tra GPS (Location Services) đã bật chưa
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Nếu GPS tắt -> hiển thị cảnh báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("GPS đang tắt. Vui lòng bật GPS trong Cài đặt."),
        ),
      );
      return false;
    }
    // 2. Kiểm tra quyền Location
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      // Xin quyền lần đầu
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isPermanentlyDenied) {
      // User từ chối vĩnh viễn -> mở App Settings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Bạn đã chặn quyền GPS. Vui lòng bật lại trong Cài đặt.",
          ),
        ),
      );
      await openAppSettings();
      return false;
    }
    if (status.isGranted) {
      return true; // Có quyền và GPS bật
    }
    return false;
  }

  Future<void> _fetchStudentInfo() async {
    // Thử fetch từ backend; nếu không thành công, chỉ hiện mã ID
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance
              .collection('userLogin')
              .doc(uid)
              .get();
      setState(() {
        studentName = doc['name'];
        studentPhone = doc['phone'];
      });
    } catch (_) {
      // Ignore - có thể offline hoặc endpoint khác
      setState(() {
        studentName = "";
        studentPhone = "";
      });
    }
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
      double qrLat =
          _extractDoubleFromJson(obj, ['lat', 'latitude', 'class_lat']) ??
              (throw Exception("null lat"));
      double qrLng =
          _extractDoubleFromJson(obj, ['lng', 'longitude', 'class_lng']) ??
              (throw Exception("null long"));
      double allowedRadius =
          _extractDoubleFromJson(obj, ['radius', 'allowed_radius']) ?? 50.0;

      if (qrLat == null || qrLng == null) {
        _showSnackbar("QR code không chứa tọa độ hợp lệ.");
        debugPrint("⚠️ Parse lỗi: lat=$qrLat, lng=$qrLng");
        return;
      }

      if (!_isWithinTimeWindow()) {
        _showAlert("Ngoài khung giờ điểm danh", "Chỉ được điểm danh từ 7h đến 9h");
        return;
      }
      // Lấy vị trí điện thoại
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      // Tính khoảng cách (m)
      final double distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        qrLat,
        qrLng,
      );

      if (distance <= allowedRadius) {
        setState(() {
          statusMessage =
          "✅ Bạn ở vị trí hợp lệ (${distance.toStringAsFixed(1)} m). Gửi điểm danh...";
        });
        final success = await _saveAttendanceToFirebase(
          status: "PRESENT",
          method: "GPS_QR",
          qrLat: qrLat,
          qrLng: qrLng,
          phoneLat: pos.latitude,
          phoneLng: pos.longitude,
          distance: distance,
          note: obj['label'] ?? obj['siteId'] ?? '',
        );
        if (success) {
          setState(() {
            hasCheckedIn = true;
            lastAction = "Có mặt";
            statusMessage = "Điểm danh có mặt thành công";
          });
          _showCheckinResultDialog("Có mặt");
        }
      } else {
        _showAlert(
          "Ngoài phạm vi",
          "Khoảng cách ${distance.toStringAsFixed(1)} m > $allowedRadius m",
        );
      }
    } catch (e) {
      _showAlert("Lỗi", "QR code không hợp lệ: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 800));
      isProcessingScan = false;
      if (!hasCheckedIn) {
        setState(() {
          statusMessage = "Đưa mã QR vào khung quét";
        });
      }
    }
  }

  // Lưu Firestore
  Future<bool> _saveAttendanceToFirebase({
    required String status,
    required String method,
    double? qrLat,
    double? qrLng,
    double? phoneLat,
    double? phoneLng,
    double? distance,
    String? note,
  }) async {
    try{
    await FirebaseFirestore.instance
        .collection("attendanceqr")
        //.doc("${widget.phone}_${DateTime.now().toIso8601String()}")
        .add({ //set({
          "phone": widget.phone,
          "status": status, // PRESENT | ABSENT | LEAVE | NOT_CHECKED
          "method": method, // GPS_QR | MANUAL | AUTO
          "timestamp": FieldValue.serverTimestamp(),
          "qrLat": qrLat,
          "qrLng": qrLng,
          "phoneLat": phoneLat,
          "phoneLng": phoneLng,
          "distanceMeters": distance,
          "note": note ?? "",
        });
return true;
  } catch (e) {
  print("Error saving attendance: $e");
  return false; // thất bại
  }
    // setState(() {
    //   hasCheckedIn = true;
    //   lastAction = status;
    //   statusMessage = "Đã lưu trạng thái: $status";
    // });
    // final uid = FirebaseAuth.instance.currentUser!.uid;
    // final doc =
    //     await FirebaseFirestore.instance.collection('userLogin').doc(uid).get();
    // try {
    //   setState(() {
    //     loading = false;
    //     studentName = doc['name'];
    //     studentPhone = doc['phone'];
    //   });
    // } catch (_) {}
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text("Điểm danh $status thành công")));
    // return true;
  }

  // Manual chọn trạng thái
  //Cách 1
  // Future<void> _onManualStatus(String label) async {
  //   await _saveAttendanceToFirebase(
  //     label == "Vắng mặt" ? "ABSENT" : "LEAVE",
  //     "MANUAL",
  //   );
  // }
  //Cách 2
  Future<void> _onManualStatus(String statusLabel) async {
    // Confirm dialog
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có chắc muốn ghi '$statusLabel'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );

    if (ok != true) return;
    setState(() {
      loading = true;
      statusMessage = "Đang gửi trạng thái $statusLabel...";
    });
    final success = await _saveAttendanceToFirebase(
      status: statusLabel == "Vắng mặt" ? "ABSENT" : "LEAVE",
      method: "MANUAL",
      note: statusLabel,
    );
    setState(() {
      loading = false;
    });
    if (success) {
      setState(() {
        hasCheckedIn = true;
        lastAction = statusLabel;
        statusMessage = "$statusLabel đã lưu";
      });
      _showCheckinResultDialog(statusLabel);
    }
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
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showCheckinResultDialog(String statusLabel) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
        title: Text("Kết quả điểm danh: $statusLabel"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(
              "Họ và tên",
              studentName.isEmpty ? "(không có)" : studentName,
            ),
            _buildInfoRow(
              "SĐT",
              studentPhone.isEmpty ? "(không có)" : studentPhone,
            ),
            _buildInfoRow("Mã ID", widget.phone),
            _buildInfoRow(
              "Lớp",
              studentClass.isEmpty ? "(không có)" : studentClass,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ---------- Build UI ----------
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
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  fit: BoxFit.cover,
                  onDetect: _onDetect,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    color: Colors.black.withOpacity(0.45),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            statusMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          if (loading) const LinearProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  // Student info
                  Card(
                    child: ListTile(
                      title: Text(
                        studentName.isEmpty ? widget.phone : studentPhone,
                      ),
                      subtitle: Text(
                        "Tên: ${studentName.isEmpty ? '-' : studentName}\nSĐT: ${studentPhone.isEmpty ? '-' : studentPhone}",
                      ),
                      isThreeLine: true,
                      trailing:
                          hasCheckedIn
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code),
                          label: const Text("Quét QR (Có mặt)"),
                          onPressed: _isWithinTimeWindow() ? () {} : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _onManualStatus("Vắng mặt"),
                          child: const Text("Vắng mặt"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _onManualStatus("Nghỉ phép"),
                          child: const Text("Nghỉ phép"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Last action
                  if (lastAction.isNotEmpty)
                    Text(
                      "Trạng thái gần nhất: $lastAction",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "Khung giờ: ${CHECKIN_START_HOUR.toString().padLeft(2, '0')}:00 - ${CHECKIN_END_HOUR.toString().padLeft(2, '0')}:00",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  // Text("Trạng thái: $lastAction"),
                  // Text(statusMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
