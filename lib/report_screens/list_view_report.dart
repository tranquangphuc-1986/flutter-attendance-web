import 'package:app_02/models/dailyReport.dart';
import 'package:app_02/report_screens/edit_report.dart';
import 'package:app_02/report_screens/view_report.dart';
import 'package:app_02/service/report_firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class ReportListViewScreen extends StatefulWidget {
  const ReportListViewScreen({super.key});

  @override
  State<ReportListViewScreen> createState() => _ReportListViewScreenState();
}

class _ReportListViewScreenState extends State<ReportListViewScreen> {
  final ReportFirebaseService service = ReportFirebaseService();

  final TextEditingController searchCtrl = TextEditingController();

  String filter = "";
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    fetchReportInfo();
  }

  Future<void> fetchReportInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
                      s.createdAt.toDate().toString().contains(
                        filter.toLowerCase(),
                      ),
                )
                    .toList();

                return SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    itemCount: filteredReport.length,
                    itemBuilder: (context, index) {
                      final st = filteredReport[index];
                      return Slidable(
                        key: ValueKey(st.id),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: null,
                            child: Image.asset("img/logocand.png", height: 40),
                          ),
                          title: Text(st.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                          subtitle: Text("Cán bộ báo cáo: ${st.fullName}\n"
                              " Ngày báo cáo: ${st.createdAt.toDate().day}/${st.createdAt.toDate().month}/${st.createdAt.toDate().year}",),
                          trailing: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ViewReport(report: st),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child:
                            isLoading
                                ? CircularProgressIndicator(color: Colors.red)
                                : const Text("Xem", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      );

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
