import 'package:app_02/models/student.dart' show Student;
import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:flutter/material.dart';
import '../service/students_firebase_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  //final _formKey = GlobalKey<FormState>();
  final FirebaseService service = FirebaseService();
  final TextEditingController searchCtrl = TextEditingController();

  String filterClass = '';
  Map<String, String> attendanceResult =
      {}; //lưu kq chọn trên lisview theo từng sinh viên theo ID
  Map<String, Color> tileColor =
      {}; //lưu thay đổi màu (tạm thời) theo từng sinh viên theo ID


  @override
  void initState() {
    super.initState();
    service.getTodayAttendance().listen((result) {
      setState(() {
        attendanceResult = result;
      });
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
      default:
        return Colors.blue.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Điểm danh"),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  labelText: "Tìm kiếm theo đơn vị",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16), //Bo viền textfield
                  ),
                  filled: true, //có màu nền không
                  fillColor: Colors.white, //màu nền bên trong textfield
                ),
                onChanged: (value) {
                  setState(() {
                    filterClass = value.trim();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // const Divider(), //dấu gạch ngang
            Expanded(
              child: StreamBuilder<List<Student>>(
                stream: service.getStudents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData){
                    return const Center(child: CircularProgressIndicator());
                  }
                  final students = snapshot.data!;
                  final filteredStudents =
                      filterClass.isEmpty
                          ? students
                          : students
                              .where(
                                (s) => s.className.toLowerCase().contains(
                                  filterClass.toLowerCase(),
                                ),
                              )
                              .toList();

                  return ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final isMarked =
                          attendanceResult[filteredStudents[index].id] !=
                          'Chưa chọn';
                      return ListTile(
                        title: Text(filteredStudents[index].name),
                        subtitle: Text(
                          "Đơn vị: ${filteredStudents[index].className} "
                          "| KQ:${attendanceResult[filteredStudents[index].id] ?? 'Chưa chọn'}",
                        ),
                        trailing: DropdownButton<String>(
                          value: attendanceResult[filteredStudents[index].id],
                          hint: const Text("Chọn"),
                          dropdownColor: Colors.white,
                          style: TextStyle(
                            color: isMarked ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) async {
                            //Hẹn thời gian để điểm danh
                            // bool isAtten() {
                            //   final now = TimeOfDay.now();
                            //   final currentMinutes = now.hour * 60 + now.minute;
                            //   return currentMinutes >= 720 && currentMinutes <=995;
                            // }
                            // if(!isAtten()) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text(
                            //         "Hết thời gian điểm danh (13:00-13:15)")),
                            //   );
                            //   return;
                            if (value != null) {
                              service.markAttendance(
                                filteredStudents[index].id,
                                value,
                              );
                              setState(() {
                                attendanceResult[filteredStudents[index].id] =
                                    value; //hiện giá trị chọn
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'Có mặt',
                              child: Text('Có mặt'),
                            ),
                            DropdownMenuItem(
                              value: 'Vắng do công tác',
                              child: Text('Công tác'),
                            ),
                            DropdownMenuItem(
                              value: 'Vắng do ốm',
                              child: Text('Bị ốm'),
                            ),
                          ],
                        ),
                      );
                      //......................
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          FloatingActionButton(
            tooltip: "Tổng hợp",
            heroTag: "summary",
            onPressed: //_gotoSummaryScreen,
                () => Navigator.push(
              context,
              MaterialPageRoute(
                //builder: (_) => SummaryScreenTest(attendanceResult),//chạy ổn
                builder: (_) => const SummaryScreenResult(),
              ),
            ),
            child: const Icon(Icons.pie_chart),
          ),
        ],
      ),
    );
  }
}
