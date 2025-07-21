import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:app_02/check/students_firebase.dart';
class AttendancePScreen_3 extends StatefulWidget {
  @override
  _AttendancePScreenState3 createState() => _AttendancePScreenState3();
}

class _AttendancePScreenState3 extends State<AttendancePScreen_3> {
  final FirebaseServic _firebaseService = FirebaseServic();
  final TextEditingController searchCtrl = TextEditingController();
  List<Student> _students = [];
  Map<String, String> _attendanceStatus ={};
  String filterClass = '';
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _firebaseService.getStudents();
    final Map<String, String> statuses={};
    for (final student in students){
   final status= await _firebaseService.getTodayAttendance(student.id ?? '');
   if (status!=null){
     statuses[student.id ?? ''] = status;
   }
    }
      setState(() {
        _students = students;
        _attendanceStatus=statuses;
        isLoading=false;
      });

  }

  Color getDropdownColor(String? status) {
    switch (status) {
      case "Có mặt":
        return Colors.green.shade100;
      case "Vắng do công tác":
        return Colors.red.shade100;
      case "Vắng do ốm":
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

  void _markAttendance(String studentId, String status) async {
    await _firebaseService.markAttendance(studentId, status);
    setState(() {
      _attendanceStatus[studentId]=status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Điểm danh hôm nay')),
      body: Column(
        // children: [
        //   Padding(
        //     padding: const EdgeInsets.all(12),
        //     child: TextField(
        //       controller: searchCtrl,
        //       decoration: InputDecoration(
        //         labelText: "Tìm kiếm theo đơn vị",
        //         prefixIcon: Icon(Icons.search),
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(16), //Bo viền textfield
        //         ),
        //         filled: true, //có màu nền không
        //         fillColor: Colors.white, //màu nền bên trong textfield
        //       ),
        //       onChanged: (value) {
        //         setState(() {
        //           filterClass = value.trim();
        //         });
        //       },
        //     ),
        //   ),
        //   const SizedBox(height: 20),
        //   Expanded(child:
          // StreamBuilder<Map<String, String>>(
          //   stream: _firebaseService.getTodayAttendance(),
          //   builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //       return Center(child: CircularProgressIndicator());          }
          //     final attendanceMap = snapshot.data!;
          //
          //     return ListView.builder(
          //       itemCount: _students.length,
          //       itemBuilder: (context, index) {
          //         final student = _students[index];
          //         final status = attendanceMap[student.id] ?? 'Chưa điểm danh';
          //
          //         return Card(
          //           color: getDropdownColor(status),
          //           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //           child: ListTile(
          //             title: Text(student.name),
          //             subtitle: Text('Đơn vị:${student.className} | Trạng thái: ${status}'),
          //             trailing: PopupMenuButton<String>(
          //               icon: Icon(Icons.check_circle_outline),
          //               onSelected: (value) {
          //                 _markAttendance(student.id, value);
          //               },
          //               itemBuilder:
          //                   (context) => [
          //                 PopupMenuItem(value: 'Có mặt', child: Text('Có mặt')),
          //                 PopupMenuItem(
          //                   value: 'Vắng do công tác',
          //                   child: Text('Công tác'),
          //                 ),
          //                 PopupMenuItem(
          //                   value: 'Vắng do ốm',
          //                   child: Text('Bị ốm'),
          //                 ),
          //                 PopupMenuItem(
          //                   value: 'Vắng do đi học',
          //                   child: Text('Đi học'),
          //                 ),
          //                 PopupMenuItem(
          //                   value: 'Vắng do nghỉ phép',
          //                   child: Text('Nghỉ phép'),
          //                 ),
          //                 PopupMenuItem(
          //                   value: 'Vắng việc cá nhân',
          //                   child: Text('Việc riêng'),
          //                 ),
          //                 PopupMenuItem(
          //                   value: 'Vắng không lý do',
          //                   child: Text('Không lý do'),
          //                 ),
          //                 PopupMenuItem(
          //                   value: 'Đi trễ',
          //                   child: Text('Đi trễ'),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),
         // ),
       // ],
      ),
    );
  }
}
