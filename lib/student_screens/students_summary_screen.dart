import 'package:app_02/service/students_firebase_service.dart';
import 'package:app_02/student_screens/students_attendance_screen3_1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';

class SummaryScreenResult extends StatefulWidget {
  const SummaryScreenResult({Key? key}) : super(key: key);
  @override
  _SummaryScreenResultState createState() => _SummaryScreenResultState();
}
class _SummaryScreenResultState extends State<SummaryScreenResult> {
  final FirebaseService service = FirebaseService();
  String? selectedStatus; //Trạng thái đang chọn để lọc
  //phân quyền truy cập
  String currentRole = '';
  String currentClass = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
      await FirebaseFirestore.instance
          .collection('userLogin')
          .doc(uid)
          .get();
      final doc_student =
      await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();
      setState(() {
        currentRole = doc['role'];
        currentClass = doc_student['className'];
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      }); // Cập nhật giao diện
    }
  }
  // Hàm tạo item thống kê có thể nhấn
  Widget _buildStatItem(String label, int count) {
    final isSelected = selectedStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedStatus = null; // Bỏ chọn nếu nhấn lại
          } else {
            selectedStatus = label;
          }
        });
      },
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
                color: isSelected ? Colors.green : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusIcon(String status) {
    switch (status) {
      case 'Có mặt':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Vắng do ốm':
        return const Icon(Icons.healing, color: Colors.orange);
      case 'Vắng do công tác':
        return const Icon(Icons.work, color: Colors.orange);
      case "Vắng do nghỉ phép":
        return const Icon(Icons.healing, color: Colors.orange);
      case "Vắng do đi học":
        return const Icon(Icons.edit_outlined, color: Colors.orange);
      case "Vắng việc cá nhân":
        return const Icon(Icons.person, color: Colors.yellow);
      case "Vắng không lý do":
        return const Icon(Icons.close, color: Colors.red);
      case "Đi trễ":
        return const Icon(Icons.healing, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Kết quả điểm danh hôm nay"),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Student>>(
              //dùng để lấy danh sách sinh viên
              stream: service.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = snapshot.data!;

                return StreamBuilder<Map<String, String>>(
                  //dùng để lấy kết quả điểm danh
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
                      "Vắng do nghỉ phép": 0,
                      "Vắng do đi học": 0,
                      "Vắng việc cá nhân": 0,
                      "Vắng không lý do": 0,
                      "Đi trễ": 0,
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
                      } else if (status == 'Vắng do nghỉ phép') {
                        total['Vắng do nghỉ phép'] =
                            total['Vắng do nghỉ phép']! + 1;
                      } else if (status == 'Vắng do đi học') {
                        total['Vắng do đi học'] = total['Vắng do đi học']! + 1;
                      } else if (status == 'Vắng việc cá nhân') {
                        total['Vắng việc cá nhân'] =
                            total['Vắng việc cá nhân']! + 1;
                      } else if (status == 'Vắng không lý do') {
                        total['Vắng không lý do'] =
                            total['Vắng không lý do']! + 1;
                      } else if (status == 'Đi trễ') {
                        total['Đi trễ'] = total['Đi trễ']! + 1;
                      } else {
                        total['Chưa điểm danh'] = total['Chưa điểm danh']! + 1;
                      }
                    }

                    //Danh sách sinh viên được lọc theo selectedStatus
                    List<Student> filteredStudents =
                        students.where((s) {
                          final status = attendance[s.id] ?? "Chưa điểm danh";
                          return selectedStatus == null ||
                              status == selectedStatus;
                        }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Thống kê với từng dòng để nhấn
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.blue),
                                  const Text(
                                    'Kết quả điểm danh (chọn để xem chi tiết):',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildStatItem('Có mặt', total['Có mặt']!),
                              _buildStatItem(
                                'Vắng do công tác',
                                total['Vắng do công tác']!,
                              ),
                              _buildStatItem(
                                'Vắng do ốm',
                                total['Vắng do ốm']!,
                              ),
                              _buildStatItem(
                                'Vắng do nghỉ phép',
                                total['Vắng do nghỉ phép']!,
                              ),
                              _buildStatItem(
                                'Vắng do đi học',
                                total['Vắng do đi học']!,
                              ),
                              _buildStatItem(
                                'Vắng việc cá nhân',
                                total['Vắng việc cá nhân']!,
                              ),
                              _buildStatItem(
                                'Vắng không lý do',
                                total['Vắng không lý do']!,
                              ),
                              _buildStatItem('Đi trễ', total['Đi trễ']!),
                              _buildStatItem(
                                'Chưa điểm danh',
                                total['Chưa điểm danh']!,
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            children:
                                //  students.map((s) {
                                filteredStudents.map((s) {
                                  final status =
                                      attendance[s.id] ?? "Chưa điểm danh";
                                  return ListTile(
                                    title: Text(s.name),
                                    subtitle: Text("Đơn vị: ${s.className}"),
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
            tooltip: "Điểm danh",
            heroTag: "attendance",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendanceScreen3_1(
                    currentRole: currentRole,
                    currentClass: currentClass,
                  )),
                ),
            child: const Icon(Icons.how_to_reg),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
