import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:app_02/service/students_firebase_service.dart';

class AttendanceScreen3_1 extends StatefulWidget {
  final String currentRole;
  final String currentClass;
  const AttendanceScreen3_1({
    super.key,
    required this.currentRole,
    required this.currentClass,
  });
  @override
  _AttendanceScreen3_1State createState() => _AttendanceScreen3_1State();
}

class _AttendanceScreen3_1State extends State<AttendanceScreen3_1> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController searchCtrl = TextEditingController();
  List<Student> _studentList = [];
  Map<String, String> attendanceMap =
      {}; //lưu kq chọn trên lisview theo từng sinh viên theo ID
  String searchName = '';
  bool isLoading = true;
  late String currentRole = '';
  late String currentClass = '';
  @override
  void initState() {
    super.initState();
    currentRole = widget.currentRole;
    currentClass = widget.currentClass;
    loadDataRole();
    filteredStudents();
    _loadDataStudents();
    // _loadStudents();
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
     _firebaseService.getStudents().listen((allStudentList) {
      setState(() {
        if (currentRole == 'Lãnh đạo') {
          _studentList = allStudentList.where((s) => s.className == 'Lãnh đạo').toList();
        } else if (currentRole.startsWith('Chỉ huy')) {
          final clas =
          currentRole
              .replaceFirst('Chỉ huy ', '')
              .trim();
       _studentList = allStudentList.where((s)=> s.className.toLowerCase() == clas.toLowerCase()).toList();
            }else{
          //_studentList = []; //không có quyền
          _studentList = allStudentList;
        }
        isLoading = false;
      });
    });
  }

  void _markAttendance(String studentId, String status) async {
    await _firebaseService.markAttendance(studentId, status);
    setState(() {
      attendanceMap[studentId] = status;
    });
  }
  void _loadDataStudents() {
    _firebaseService.getTodayAttendance().listen((result) {
      setState(() {
        attendanceMap = result;
        isLoading = false;
      });
    });
  }
  // void _loadStudents() {
  //   _firebaseService.getStudents().listen((allstudentList) {
  //     setState(() {
  //       _studentList = allstudentList;
  //       isLoading = false;
  //     });
  //   });
  // }

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
  }

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
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudent = _studentList.where((st){
      final name = st.name.toLowerCase();
      return name.contains(searchName.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm danh hôm nay'),
        backgroundColor: Colors.yellowAccent,
      ),
      backgroundColor: Colors.white70,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                labelText: "Tìm kiếm theo tên...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), //Bo viền textfield
                ),
                filled: true, //có màu nền không
                fillColor: Colors.white, //màu nền bên trong textfield
              ),
              onChanged: (value) {
                setState(() {
                  searchName = value.trim();
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
                  child:  ListView.builder(
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
                        leading: Icon(Icons.person, color: Colors.blue,),
                        title: Text(student.name),
                        subtitle: Text(
                          'Đơn vị:${student.className} | Trạng thái: ${status}',
                        ),
                        trailing: currentRole=='Cán bộ'
                        ? null
                        :PopupMenuButton<String>(
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: getIconColor(status),
                          ),
                          onSelected: (value) {
                            _markAttendance(student.id, value);
                            setState(() {
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
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
