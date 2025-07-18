import 'package:app_02/Service/students_firebase_service.dart';
import 'package:app_02/check/summary_screen1.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';

class AttendanceScreen1 extends StatefulWidget {
  const AttendanceScreen1({super.key});

  @override
  State<AttendanceScreen1> createState() => _AttendanceScreenState1();
}

class _AttendanceScreenState1 extends State<AttendanceScreen1> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService service = FirebaseService();
  final TextEditingController searchCtrl = TextEditingController();
  String filterClass = '';
  Map<String, String> attendanceResult={};//lưu kq chọn trên lisview theo từng sinh viên theo ID
  Map<String, Color> tileColor={};//lưu thay đổi màu (tạm thời) theo từng sinh viên theo ID

  Color getDropdownColor(String? status){
    switch(status){
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
        title: const Text("Điểm danh hôm nay"),
        automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                labelText: "Tìm kiếm theo lớp học",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), //Bo viền textfield
                ),
                filled: true,//có màu nền không
                fillColor: Colors.white,//màu nền bên trong textfield
              ),

              onChanged: (value) {
                setState(() {
                  filterClass = value.trim();
                });
              },
            ),
          ),
         const SizedBox(height: 20,),
        // const Divider(), //dấu gạch ngang
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: service.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
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
                  itemBuilder:

                  //@@@@@@-----Đổi màu khi chọn xong
                  //     (context, i){
                  //  final status = attendanceResult[filteredStudents[i].id];
                  //   return Container(
                  //     color: getDropdownColor(status),
                  //     child: ListTile(
                  //        title: Text(filteredStudents[i].name),
                  //        subtitle: Text("Lớp: ${filteredStudents[i].className} "
                  //            "| KQ:${status??''}"),
                  //        trailing: DropdownButton<String>(
                  //        value: status,
                  //        hint: Text("Chọn"),
                  //           items: const ["Có mặt", "Vắng do công tác",
                  //             "Vắng do ốm"].map((e)=>DropdownMenuItem(
                  //               value: e,
                  //               child: Text(e),)).toList(),
                  //
                  //               onChanged: (value) {
                  //                 //.....Định thời gian điểm danh.......
                  //                bool isAtten() {
                  //                  final now = TimeOfDay.now();
                  //                  final currentMinutes = now.hour * 60 + now.minute;
                  //                  return currentMinutes >= 720 && currentMinutes <=1095;
                  //                }
                  //                if(!isAtten()) {
                  //                  ScaffoldMessenger.of(context).showSnackBar(
                  //                    SnackBar(content: Text(
                  //                        "Hết thời gian điểm danh (13:00-13:15)")),
                  //                  );
                  //                  return;
                  //                }
                  //                if (value != null) {
                  //                  service.markAttendance(filteredStudents[i].id, value);
                  //                  setState(() {
                  //                    attendanceResult[filteredStudents[i].id]=value;
                  //                  });
                  //                }
                  //              },
                  //
                  //    ),
                  //    ),
                  //   );
                  // }
                //@@@@@@
                    //................
                      (_, item) => ListTile(
                        title: Text(filteredStudents[item].name),
                        subtitle: Text("Lớp: ${filteredStudents[item].className} "
                            "| KQ:${attendanceResult[filteredStudents[item].id]??''}"),
                        trailing: DropdownButton<String>(
                          hint: const Text("Chọn"),
                          onChanged: (value) {
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
                            // }
                            if (value != null) {
                              service.markAttendance(filteredStudents[item].id, value);
                              setState(() {
                               attendanceResult[filteredStudents[item].id]=value;
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
                      ),
                  //......................

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
            heroTag: "summary",
            onPressed: () =>
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>  SummaryScreen1())),
            child: const Icon(Icons.list),
            tooltip: "Tổng hợp",
          ),
        ],
      ),
    );
  }
}
