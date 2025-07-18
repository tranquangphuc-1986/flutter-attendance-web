import 'package:app_02/service/students_firebase_service.dart';
import 'package:app_02/student_screens/students_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:app_02/student_screens/students_attendance_screen_1.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});
  @override
  State<HomeScreen1> createState() => _HomeScreenState1();
}

class _HomeScreenState1 extends State<HomeScreen1> {
  final FirebaseService service = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController classCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();
  String filterClass = '';

  void _addStudent() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: '',
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        className: classCtrl.text,
      );
      service.addStudent(student);
      nameCtrl.clear();
      phoneCtrl.clear();
      classCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý sinh viên")),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Họ tên"),
                      validator: (v) => v!.isEmpty ? "Nhập họ tên" : null),
                  TextFormField(controller: phoneCtrl,
                      decoration: const InputDecoration(
                          labelText: "Số điện thoại"),
                      validator: (v) =>
                      v!.isEmpty
                          ? "Nhập số điện thoại"
                          : null),
                  TextFormField(controller: classCtrl,
                      decoration: const InputDecoration(labelText: "Lớp học"),
                      validator: (v) => v!.isEmpty ? "Nhập lớp học" : null),
                  ElevatedButton(onPressed: _addStudent,
                      child: const Text("Thêm sinh viên")),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                  labelText: "Tìm kiếm theo lớp học"),
              onChanged: (value) {
                setState(() {
                  filterClass = value.trim();
                });
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: service.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final students = snapshot.data!;
                final filteredStudents = filterClass.isEmpty
                    ? students
                    : students.where((s) =>
                    s.className.toLowerCase().contains(
                        filterClass.toLowerCase())).toList();
                return ListView.builder(
                  itemCount: filteredStudents.length,
                  // itemBuilder: (_, i) =>
                  //     ListTile(
                  //       title: Text(filteredStudents[i].name),
                  //       subtitle: Text("Lớp: ${filteredStudents[i]
                  //           .className} | SDT: ${filteredStudents[i].phone}"),
                  //     ),
                  itemBuilder: (_, i) {
                    final student = filteredStudents[i];
                    return Dismissible(
                        key: Key(student.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete_forever, color: Colors.white,),
                        ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white,),
                      ),
                      onDismissed: (direction){
                          if(direction==DismissDirection.startToEnd){
                            //xóa dữ liệu
                            service.deleteData(student.id);
                          }else{
                            //Chuyển sang màn hình sửa sinh viên
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => EditDataScreen (student: student),
                            ));
                          }
                      },
                      child: ListTile(
                            title: Text(filteredStudents[i].name),
                            subtitle: Text("Lớp: ${filteredStudents[i]
                                .className} | SĐT: ${filteredStudents[i].phone}"),
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
            heroTag: "attendance",
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AttendanceScreen())),
            child: const Icon(Icons.how_to_reg),
            tooltip: "Điểm danh",
          ),
          const SizedBox(height: 10),
          // FloatingActionButton(
          //   heroTag: "summary",
          //   onPressed: () =>
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (_) => const SummaryScreen())),
          //   child: const Icon(Icons.list),
          //   tooltip: "Tổng hợp",
          // ),
        ],
      ),
    );
  }
}