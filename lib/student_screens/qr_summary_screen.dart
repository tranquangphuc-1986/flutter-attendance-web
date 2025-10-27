import 'package:app_02/phone/phone_model_service.dart';
import 'package:app_02/student_screens/students_attendance_screen3_1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QrSummaryScreenResult extends StatefulWidget {
  const QrSummaryScreenResult({Key? key}) : super(key: key);
  @override
  _QrSummaryScreenResultState createState() => _QrSummaryScreenResultState();
}
class _QrSummaryScreenResultState extends State<QrSummaryScreenResult> {
  final FirebaseUserService service = FirebaseUserService();
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
            child: StreamBuilder<List<UserModel>>(
              //dùng để lấy danh sách cán bộ
              stream: service.getAllUsersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final police = snapshot.data!;

                return StreamBuilder<Map<String, String>>(
                  //dùng để lấy kết quả điểm danh
                  stream: service.getTodayAttendanceQr(),
                  builder: (context, attSnapshot) {
                    if (!attSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final attendance = attSnapshot.data!;
                    //Tổng hợp kết quả
                    final total = {
                      'Có mặt': 0,
                      'Vắng do công tác': 0,
                      'Vắng mặt': 0,
                      'Chưa điểm danh': 0,
                      "Nghỉ phép": 0,
                      "Vắng do đi học": 0,
                      "Vắng việc cá nhân": 0,
                      "Vắng không lý do": 0,
                      "Đi trễ": 0,
                    };

                    for (var _police in police) {
                      final status = attendance[_police.id];
                      if (status == 'Có mặt') {
                        total['Có mặt'] = total['Có mặt']! + 1;
                      } else if (status == 'Vắng do công tác') {
                        total['Vắng do công tác'] =
                            total['Công tác']! + 1;
                      } else if (status == 'Vắng do ốm') {
                        total['Vắng do ốm'] = total['Bị ốm']! + 1;
                      } else if (status == 'Vắng do nghỉ phép') {
                        total['Vắng do nghỉ phép'] =
                            total['Nghỉ phép']! + 1;
                      } else if (status == 'Vắng do đi học') {
                        total['Vắng do đi học'] = total['Đi học']! + 1;
                      } else if (status == 'Vắng việc cá nhân') {
                        total['Vắng việc cá nhân'] =
                            total['Việc riêng']! + 1;
                      } else if (status == 'Đi trễ') {
                        total['Đi trễ'] = total['Đi trễ']! + 1;
                      } else {
                        total['Chưa điểm danh'] = total['Chưa điểm danh']! + 1;
                      }
                    }

                    //Danh sách sinh viên được lọc theo selectedStatus
                    List<UserModel> filteredPolice =
                    police.where((s) {
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
                            filteredPolice.map((s) {
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
