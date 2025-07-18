import 'package:app_02/service/students_firebase_service.dart';
import 'package:app_02/student_screens/students_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../student_screens/students_attendance_screen_1.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});
  @override
  State<HomeScreen2> createState() => _HomeScreenState2();
}

class _HomeScreenState2 extends State<HomeScreen2> {
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

  void _confirmDelete(BuildContext context, Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xác nhận xoá"),
            content: Text("Bạn có chắc muốn xoá dữ liệu '${student.name}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Huỷ"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Xoá", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await FirebaseService().deleteData(student.id);
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã xóa dữ liệu '${student.name}'")));
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
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Họ tên"),
                    validator: (v) => v!.isEmpty ? "Nhập họ tên" : null,
                  ),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại",
                    ),
                    validator: (v) => v!.isEmpty ? "Nhập số điện thoại" : null,
                  ),
                  TextFormField(
                    controller: classCtrl,
                    decoration: const InputDecoration(labelText: "Lớp học"),
                    validator: (v) => v!.isEmpty ? "Nhập lớp học" : null,
                  ),
                  ElevatedButton(
                    onPressed: _addStudent,
                    child: const Text("Thêm sinh viên"),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: "Tìm kiếm theo lớp học",
              ),
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
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có danh sách cán bộ"));
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
                    final st = filteredStudents[index];
                    
                    return Slidable(
                      key: ValueKey(st.id),
                     startActionPane: ActionPane( //Vuốt từ trái sang phải
                      //endActionPane: ActionPane( //vuốt từ phải sang trái
                        motion: const DrawerMotion(),
                        extentRatio: 0.5, //Để chia đều cho 2 nút xóa và sửa
                        children: [
                          SlidableAction(
                            onPressed: (_) => _confirmDelete(context, st),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Xoá',
                          ),
                          SlidableAction(
                            onPressed: (_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditDataScreen(student: st),
                                ),
                              );
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Sửa',
                          ),
                        ],
                      ),

                      child: ListTile(
                        title: Text(st.name),
                        subtitle: Text(
                          "Lớp: ${st.className} | SĐT: ${st.phone}",
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
            heroTag: "attendance",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                ),
            child: const Icon(Icons.how_to_reg),
            tooltip: "Điểm danh",
          ),
          const SizedBox(height: 10),

          // FloatingActionButton(
          //   heroTag: "summary",
          //   onPressed:
          //       () => Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const SummaryScreen()),
          //       ),
          //   child: const Icon(Icons.pie_chart),
          //   tooltip: "Tổng hợp",
          // ),
        ],
      ),
    );
  }
}
