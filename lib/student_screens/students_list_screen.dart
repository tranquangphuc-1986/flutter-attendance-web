import 'package:app_02/service/students_firebase_service.dart';
import 'package:app_02/student_screens/students_add_screen.dart';
import 'package:app_02/student_screens/students_attendance_screen3_1.dart';
import 'package:app_02/student_screens/students_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final FirebaseService service = FirebaseService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController classCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();
  String filter = "";
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
              .collection('cax')
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
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                "Thông báo",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "Đã xoá dữ liệu '${student.name}'",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Danh sách cán bộ"),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: "Tìm kiếm theo đơn vị hoặc tên",
              ),
              onChanged: (value) {
                setState(() {
                  filter = value.trim();
                });
              },
            ),
          ),

          //const Divider(),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: service.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có danh sách cán bộ"));
                }
                final students = snapshot.data!;
                final filteredStudents =
                    filter.isEmpty
                        ? students
                        : students
                            .where(
                              (s) =>
                                  s.name.toLowerCase().contains(
                                    filter.toLowerCase(),
                                  ) ||
                                  s.className.toLowerCase().contains(
                                    filter.toLowerCase(),
                                  ),
                            )
                            .toList();

                return SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final st = filteredStudents[index];
                      if (currentRole == 'Admin') {
                        //vai trò admin được quyền xóa, sửa
                        return Slidable(
                          key: ValueKey(st.id),
                          startActionPane: ActionPane(
                            //Vuốt từ trái sang phải
                            // endActionPane: ActionPane( //vuốt từ phải sang trái
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
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: null,
                              child: Text(st.name[0]), //Hình ảnh Avarta
                            ),
                            title: Text(st.name),
                            subtitle: Text(
                              "Đơn vị: ${st.className} | SĐT: ${st.phone}",
                            ),
                          ),
                        );
                      } else {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: null,
                            child: Text(st.name[0]), //Hình ảnh Avarta
                          ),
                          title: Text(st.name),
                          subtitle: Text(
                            "Đơn vị: ${st.className} | SĐT: ${st.phone}",
                          ),
                        );
                      }
                      //-----------------end--------------------
                    },
                    separatorBuilder:
                        (context, index) => Divider(
                          thickness: 0.4,
                          color: Colors.blue.shade400,
                        ), //đường kẻ ngang
                  ),
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
                  MaterialPageRoute(
                    builder:
                        (context) => AttendanceScreen3_1(
                          currentRole: currentRole,
                          currentClass: currentClass,
                        ),
                  ),
                ),
            child: const Icon(Icons.how_to_reg),
          ),
          const SizedBox(height: 10),

          FloatingActionButton(
            tooltip: "Thêm mới",
            heroTag: "Thêm mới",
            onPressed: () {
              if (currentRole == 'Admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNewstudens()),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn không có quyền truy cập.'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
