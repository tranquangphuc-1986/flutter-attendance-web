import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:app_02/service/students_firebase_service.dart';

class AttendanceScreen4 extends StatefulWidget {
  final String currentRole;
  final String currentClass;
  const AttendanceScreen4({
    super.key,
    required this.currentRole,
    required this.currentClass,
  });
  @override
  _AttendanceScreen4State createState() => _AttendanceScreen4State();
}

class _AttendanceScreen4State extends State<AttendanceScreen4> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController searchCtrl = TextEditingController();
  List<Student> _studentList = [];
  Map<String, String> attendanceMap =
      {}; //lưu kq chọn trên lisview theo từng sinh viên theo ID
  String search = '';
  bool isLoading = true;
  late String currentRole = '';
  late String currentClass = '';
  @override
  void initState() {
    super.initState();
    currentRole = widget.currentRole;
    currentClass = widget.currentClass;
    loadDataRole();
  }

  Future<void> loadDataRole() async {
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
    filteredStudents();
  }

  Future<void> filteredStudents() async {
    setState(() => isLoading = true);
    final allStudent = await _firebaseService.fetchStudents();
    final filter =
        allStudent.where((s) {
          if (currentRole == "Lãnh đạo") {
            return s.className == 'LĐ';
          } else if (currentRole.startsWith("Chỉ huy")) {
            final clas = currentRole.replaceFirst('Chỉ huy ', '').trim();
            return s.className.toLowerCase() == clas.toLowerCase();
          } else {
            return true;
           // return false;
          }
        }).toList();
    final Map<String, String> statusMap = {};
    for (var student in filter) {
      final status = await _firebaseService.getTodayAttendanceFuture(
        student.id,
      );
      if (status != null) statusMap[student.id] = status;
    }
    setState(() {
      _studentList = filter;
      attendanceMap = statusMap;
      isLoading = false;
    });
  }

  void _markAttendance(String studentId, String status) async {
    await _firebaseService.markAttendance(studentId, status);
    setState(() {
      attendanceMap[studentId] = status;
    });
  }

  Color getIconColor(String? selected) {
    switch (selected) {
      case "Có mặt" ||
          "Vắng do công tác" ||
          "Vắng do ốm" ||
          "Vắng do nghỉ phép" ||
          "Vắng do đi học" ||
          "Vắng việc cá nhân" ||
          "Vắng không lý do" ||
          "Đi trễ":
        return Colors.green;
      default:
        return Colors.redAccent;
    }
  } //đổi màu icon chọn điểm danh

  Color getDropdownColor(String? status) {
    switch (status) {
      case "Có mặt":
        return Colors.green.shade100;
      case "Vắng do công tác" || "Vắng do ốm":
        return Colors.red.shade100;
      case "Vắng do nghỉ phép":
        return Colors.red.shade100;
      case "Vắng do đi học":
        return Colors.red.shade100;
      case "Vắng việc cá nhân":
        return Colors.red.shade100;
      case "Vắng không lý do":
        return Colors.red.shade100;
      case "Đi trễ":
        return Colors.red.shade100;
      default:
        return Colors.white;
    }
  } //đổi màu card khi điểm danh

  @override
  Widget build(BuildContext context) {
    final filteredStudent = _studentList.where((st){
      final name = st.name.toLowerCase();
      return name.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm danh hôm nay'),
        backgroundColor: Colors.yellowAccent,
      ),
      backgroundColor: Colors.white70,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        labelText: "Tìm kiếm theo đơn vị",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            16,
                          ), //Bo viền textfield
                        ),
                        filled: true, //có màu nền không
                        fillColor: Colors.white, //màu nền bên trong textfield
                      ),
                      onChanged: (value) {
                        setState(() {
                          search = value.trim();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredStudent.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudent[index];
                        final status =
                            attendanceMap[student.id] ?? 'Chưa điểm danh';
                        return Card(
                          color: getDropdownColor(status),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(student.name),
                            subtitle: Text(
                              'Đơn vị:${student.className} | Trạng thái: ${status}',
                            ),
                            trailing:
                                currentRole == 'Cán bộ'
                                    ? null
                                    : PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.check_circle_outline,
                                        color: getIconColor(status),
                                      ),
                                      onSelected: (value) {
                                        setState(() {
                                          _markAttendance(student.id, value);
                                          attendanceMap[student.id] == value;
                                        });
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: 'Có mặt',
                                              child: Text('Có mặt'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Vắng do công tác',
                                              child: Text('Công tác'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Vắng do ốm',
                                              child: Text('Bị ốm'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Vắng do đi học',
                                              child: Text('Đi học'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Vắng do nghỉ phép',
                                              child: Text('Nghỉ phép'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Vắng việc cá nhân',
                                              child: Text('Việc riêng'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Vắng không lý do',
                                              child: Text('Không lý do'),
                                            ),
                                            PopupMenuItem(
                                              value: 'Đi trễ',
                                              child: Text('Đi trễ'),
                                            ),
                                          ],
                                    ),
                          ),
                        );
                      },
                    ),
                    // },
                    //),
                  ),
                ],
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: "Điểm danh",
            heroTag: "attendance",
            backgroundColor: Colors.blue,
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SummaryScreenResult(),
                  ),
                ),
            child: const Icon(Icons.summarize_outlined),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
