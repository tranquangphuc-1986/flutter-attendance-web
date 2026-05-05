import 'package:app_02/models/dailyReport.dart';
import 'package:app_02/report_screens/edit_report.dart';
import 'package:app_02/service/report_firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final ReportFirebaseService service = ReportFirebaseService();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();
  final TextEditingController createdAtCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();
  String filter = "";
  String currentRole = '';
  String currentClass = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchReportInfo();
  }

  Future<void> fetchReportInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc_report = await FirebaseFirestore.instance
          .collection('report')
          .doc(uid)
          .get();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      }); // Cập nhật giao diện
    }
  }

  void _confirmDelete(BuildContext context, DailyReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: Text("Bạn có chắc muốn xoá dữ liệu '${report.title}'?"),
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
      await ReportFirebaseService().deleteReport(report.id);
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
            "Đã xoá dữ liệu '${report.title}'",
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
        title: const Text("Danh sách báo cáo"),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: "Tìm kiếm báo cáo",
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
            child: StreamBuilder<List<DailyReport>>(
              stream: service.getReports(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có danh sách báo cáo"));
                }
                final report = snapshot.data!;
                final filteredReport =
                filter.isEmpty
                    ? report
                    : report
                    .where(
                      (s) =>
                  s.title.toLowerCase().contains(
                    filter.toLowerCase(),
                  ) ||
                      s.createdAt.toString().toLowerCase().contains(
                        filter.toLowerCase(),
                      ),
                )
                    .toList();

                return SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    itemCount: filteredReport.length,
                    itemBuilder: (context, index) {
                      final st = filteredReport[index];
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
                                          (_) => EditReport(report: st),
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
                              child: Text(st.title[0]), //Hình ảnh Avarta
                            ),
                            title: Text(st.title),
                            subtitle: Text(
                              "Ngày báo cáo: ${st.createdAt} | SĐT: ${st.fullName}",
                            ),
                          ),
                        );
                      } else {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: null,
                            child: Text(st.title[0]), //Hình ảnh Avarta
                          ),
                          title: Text(st.title),
                          subtitle: Text(
                            "Ngày báo cáo: ${st.createdAt} | SĐT: ${st.fullName}",
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
