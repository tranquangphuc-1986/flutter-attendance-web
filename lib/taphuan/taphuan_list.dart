import 'package:app_02/phone/phone_model_service.dart';
import 'package:app_02/taphuan/taphuan_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaphuanListScreen extends StatefulWidget {
  const TaphuanListScreen({super.key});

  @override
  State<TaphuanListScreen> createState() => _TaphuanListScreenState();
}

class _TaphuanListScreenState extends State<TaphuanListScreen> {
  final FirebaseUserService service = FirebaseUserService();
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
         setState(() {
        currentRole = doc['role'];
        currentClass = doc['className'];
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      }); // Cập nhật giao diện
    }
  }

  void _confirmDelete(BuildContext context, UserModel userlogin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: Text("Bạn có chắc muốn xoá dữ liệu '${userlogin.name}'?"),
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
      await FirebaseUserService().deleteUser(userlogin.id);
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
            "Đã xoá dữ liệu '${userlogin.name}'",
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
            child: StreamBuilder<List<UserModel>>(
              stream: service.getAllUsersStream(),
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
                                          (_) => EditTaphuanScreen(student: st),
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
    );
  }
}
