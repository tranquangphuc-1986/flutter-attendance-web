import 'package:app_02/service/students_firebase_service.dart';
import 'package:app_02/check/students_attendance_screen_1.dart';
import 'package:app_02/check/students_statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, String> attendanceResults;
  SummaryScreen(this.attendanceResults);
  //const SummaryScreen({super.key});
  Widget buildStatusIcon(String status) {
    switch (status) {
      case 'Có mặt':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Vắng do ốm':
        return const Icon(Icons.healing, color: Colors.red);
      case 'Vắng do công tác':
        return const Icon(Icons.work, color: Colors.orange);
      default:
        return const Icon(Icons.help_outline);
    }
  }
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Tổng hợp điểm danh hôm nay"),
        automaticallyImplyLeading: false,
      ),
      body: Column(

        children: [
          Expanded(
            child: StreamBuilder<List<Student>>( //dùng để lấy danh sách sinh viên
              stream: service.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!;

                return StreamBuilder<Map<String, String>>(//dùng để lấy kết quả điểm danh
                  stream: service.getTodayAttendance(),
                  builder: (context, attSnapshot) {
                    if (!attSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final attendance = attSnapshot.data!;
                    //Tổng hợp kết quả
                    final total = {
                      'Có mặt': 0,
                      'Vắng do công tác': 0,
                      'Vắng do ốm': 0,
                      'Chưa điểm danh': 0,
                    };
                    for (var student in students) {
                      final status = attendance[student.id];
                      if (status == 'Có mặt') {
                        total['Có mặt'] = total['Có mặt']! + 1;
                      } else if (status == 'Vắng do công tác') {
                        total['Vắng do công tác'] =
                            total['Vắng do công tác']! + 1;
                      } else if (status == 'Vắng do ốm') {
                        total['Vắng do ốm'] = total['Vắng do ốm']! + 1;
                      } else {
                        total['Chưa điểm danh'] = total['Chưa điểm danh']! + 1;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.blue),
                                  const Text(
                                    'Kết quả điểm danh:',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  buildStatusIcon('Có mặt'),
                                  Text('Có mặt: ${total['Có mặt']}'),
                                  const SizedBox(width: 60,),
                                  buildStatusIcon('Vắng do công tác'),
                                  Text(
                                    'Vắng do công tác: ${total['Vắng do công tác']}',
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  buildStatusIcon('Vắng do ốm'),
                                  Text('Vắng do ốm: ${total['Vắng do ốm']}'),
                                  const SizedBox(width: 30,),
                                  buildStatusIcon('Chưa điểm danh'),
                                  Text(
                                    'Chưa điểm danh: ${total['Chưa điểm danh']}',
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            children:
                                students.map((s) {
                                  final status =
                                      attendance[s.id] ?? "Chưa điểm danh";
                                  return ListTile(
                                    title: Text(s.name),
                                    subtitle: Text("Lớp: ${s.className}"),
                                    trailing: Text(status),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "attendance",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendanceScreen()),
                ),
            child: const Icon(Icons.how_to_reg),
            tooltip: "Điểm danh",
          ),
          const SizedBox(height: 10),

          // FloatingActionButton(
          //   heroTag: "attendance",
          //   // onPressed:
          //   //     () => Navigator.push(
          //   //       context,
          //   //      MaterialPageRoute(builder: (_) => AttendancePScreen()),
          //   //     ),
          //   child: const Icon(Icons.perm_contact_cal_outlined),
          //   tooltip: "Điểm danh mới",
          // ),

          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "Thống kê",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentStatisticsScreen(),
                  ),
                ),
            child: const Icon(Icons.list),
            tooltip: "Thống kê",
          ),
        ],
      ),
    );
  }
}
