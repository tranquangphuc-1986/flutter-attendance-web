import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QrSummaryTodayScreenResult extends StatefulWidget {
  const QrSummaryTodayScreenResult({Key? key}) : super(key: key);

  @override
  State<QrSummaryTodayScreenResult> createState() => _QrSummaryTodayScreenResultState();
}

class _QrSummaryTodayScreenResultState extends State<QrSummaryTodayScreenResult> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedStatus;

  /// 🔹 Stream danh sách điểm danh hôm nay
  Stream<List<Map<String, dynamic>>> getTodayAttendanceStream() {
    final now = DateTime.now();
    //final today = DateTime(now.year, now.month, now.day);
   // final timestampToday = Timestamp.fromDate(today); kiêu 00:00:00
    final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59, 999),);

    return _firestore
        .collection('attendanceqr')
       // .where('timestamp', isEqualTo: timestampToday)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  /// 🔹 Widget hiển thị mỗi mục thống kê
  Widget _buildStatItem(String label, int count) {
    final isSelected = selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() {
        selectedStatus = isSelected ? null : label;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "$label: $count",
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.green[800] : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Widget hiển thị 1 dòng danh sách người điểm danh
  Widget _buildAttendanceTile(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Không rõ tên';
    final className = item['className'] ?? 'Không rõ đơn vị';
    final phone = item['phone'] ?? 'Không rõ số';
    final status = item['status'] ?? 'Chưa điểm danh';

    Color statusColor;
    switch (status) {
      case 'Có mặt':
        statusColor = Colors.green;
        break;
      case 'Đi trễ':
        statusColor = Colors.orange;
        break;
      case 'Nghỉ phép':
      case 'Công tác':
      case 'Bị ốm':
      case 'Đi học':
      case 'Việc riêng':
        statusColor = Colors.blueGrey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.person, color: statusColor),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text('Đơn vị: $className\nSĐT: $phone'),
        trailing: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kết quả điểm danh hôm nay"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getTodayAttendanceStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có dữ liệu điểm danh hôm nay.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final attendanceList = snapshot.data!;

          // 🔸 Thống kê số lượng theo trạng thái
          final Map<String, int> totals = {};
          for (var a in attendanceList) {
            final status = a['status'] ?? 'Chưa điểm danh';
            totals[status] = (totals[status] ?? 0) + 1;
          }

          // 🔸 Lọc danh sách theo trạng thái đang chọn
          final filtered = attendanceList.where((a) {
            final status = a['status'] ?? 'Chưa điểm danh';
            return selectedStatus == null || status == selectedStatus;
          }).toList();

          // 🔸 Sắp xếp theo tên (tùy chọn, giúp dễ đọc)
          filtered.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Thống kê tổng ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bar_chart, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Thống kê điểm danh (chạm để lọc):',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...totals.entries.map((e) => _buildStatItem(e.key, e.value)),
                  ],
                ),
              ),
              const Divider(height: 1),
              // --- Danh sách chi tiết ---
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildAttendanceTile(filtered[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
