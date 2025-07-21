import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:app_02/service/students_firebase_service.dart';

class AttendanceScreen3_2 extends StatefulWidget {
  final String currentRole;
  final String currentClass;
  const AttendanceScreen3_2({
    super.key,
    required this.currentRole,
    required this.currentClass,
  });
  @override
  _AttendanceScreenState3_2 createState() => _AttendanceScreenState3_2();
}

class _AttendanceScreenState3_2 extends State<AttendanceScreen3_2> {
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
    _loadDataStudents();
    // _loadStudents();
  }

  // void _loadStudents() {
  //   _firebaseService.getStudents().listen((studentList) {
  //     setState(() {
  //       _students = studentList;
  //       isLoading = false;
  //     });
  //   });
  // }
  void _loadDataStudents() {
    _firebaseService.getTodayAttendance().listen((result) {
      setState(() {
        attendanceMap = result;
        isLoading = false;
      });
    });
  }

  void _markAttendance(String studentId, String status) async {
    await _firebaseService.markAttendance(studentId, status);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm danh hôm nay'),
        backgroundColor: Colors.cyanAccent,
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
            child: StreamBuilder<List<Student>>(
              stream: _firebaseService.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final allStudents = snapshot.data!;
                // //lọc sinh viên theo phân quyền
                final filteredStudents =
                    allStudents.where((s) {
                      // Nếu là chỉ huy, chỉ hiển thị lớp của họ
                      if (currentRole.startsWith('Chỉ huy')) {
                        final clas =
                            currentRole
                                .replaceFirst('Chỉ huy ', '')
                                .trim();
                        return s.className.toLowerCase() == clas.toLowerCase();
                      }
                      // Nếu là cán bộ thì hiển thị all
                      else if (currentRole == 'Cán bộ') {
                        return true;
                      } else {
                        // Admin hoặc các vai trò khác xem tất cả
                        return true;
                      }
                    }).toList();

                final filtered = filteredStudents.where((st){
                  final name = st.name.toLowerCase();
                  return name.contains(searchName.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
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
                            setState(() {
                              attendanceMap[student.id] == value;
                            });
                            //Phân quyền điểm danh
                            if (currentRole == 'Cán bộ') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bạn không có quyền điểm danh.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            } else{
                            _markAttendance(student.id, value);
                            }
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
