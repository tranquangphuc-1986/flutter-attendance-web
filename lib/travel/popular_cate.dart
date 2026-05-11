import 'package:app_02/Widgets/showPasscodeBottomSheet.dart';
import 'package:app_02/cax/cax_home_screen.dart';
import 'package:app_02/chart/area_chart.dart';
import 'package:app_02/chart/chart_screen.dart';
import 'package:app_02/chart/cyberLeaderboard.dart';
import 'package:app_02/chart/population_Leaderboard.dart';
import 'package:app_02/data_diaban/diaban_page_home.dart';
import 'package:app_02/phone/signup_phone.dart';
import 'package:app_02/report_screens/addNew_report.dart';
import 'package:app_02/report_screens/list_report.dart';
import 'package:app_02/report_screens/list_view_report.dart';
import 'package:app_02/student_screens/AdminCloseAttendanceScreen.dart';
import 'package:app_02/student_screens/importExcelScreen.dart';
import 'package:app_02/student_screens/qr_summaryToday_screen.dart';
import 'package:app_02/student_screens/qr_summary_screen.dart';
import 'package:app_02/student_screens/scan_Qrcode.dart';
import 'package:app_02/student_screens/students_attendance_screen3_1.dart';
import 'package:app_02/check/students_attendance_screen3_2.dart';
import 'package:app_02/student_screens/students_statistics_page.dart';
import 'package:app_02/student_screens/students_list_screen.dart';
import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:app_02/taphuan/taphuan_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_02/check/students_statistics_page_2.dart';
import 'package:url_launcher/url_launcher.dart';

class PopularCategories extends StatefulWidget {
  const PopularCategories({super.key});
  @override
  State<PopularCategories> createState() => _PopularCategoriesState();
}

class _PopularCategoriesState extends State<PopularCategories> {
  String currentRole = '';
  String currentClass = '';
  String phone = '';
  bool isLoading = true;
  bool isPasswordHidden = true;

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
              .collection('students')
              .doc(uid)
              .get();
      setState(() {
        currentRole = doc['role'];
        currentClass = doc_student['className'];
        phone = doc['phone'];
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      }); // Cập nhật giao diện
    }
  }

  Future<void> _map() async {
    final url = Uri.parse(
      'https://sapnhap.bando.com.vn/?zarsrc=31&utm_source=zalo&utm_medium=zalo&utm_campaign=zalo',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Không thể mở URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tiện ích",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          bool? isSuccess = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PasscodeWidget(),
                          );

                          if (isSuccess == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ReportListViewScreen(), //StudentsListScreen(),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFfcbb8ef),
                          child: Image.asset("img/word.png", height: 40),
                        ),
                      ),
                      Text(
                        "Xem báo cáo",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          bool? isSuccess = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PasscodeWidget(),
                          );

                          if (isSuccess == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ReportListScreen(), //AttendanceQRScreen (phone: phone),
                              ),
                            );
                          }
                        },

                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFF9ED2F7),
                          child: Image.asset("img/folder.png", height: 40),
                        ),
                      ),
                      Text(
                        "Nhập báo cáo",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      StudentsListScreen(), //ImportExcelScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFF9ED2F7),
                          child: Image.asset("img/person.png", height: 40),
                        ),
                      ),
                      const Text(
                        "Danh bạ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      HomeScreenCAX(), //QrSummaryScreenResult(),//QrSummaryTodayScreenResult(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFFF8CDEC),
                          child: Image.asset("img/logocand.png", height: 40),
                        ),
                      ),
                      const Text(
                        "Công an xã",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChartScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFfcbb8ef),
                          child: Image.asset("img/statistical.png", height: 40),
                        ),
                      ),

                      const Text(
                        "Biểu đồ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: _map,
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFFFacdcc),
                          child: Image.asset("img/search.png", height: 40),
                        ),
                      ),
                      const Text(
                        "Tra cứu",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          bool? isSuccess = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PasscodeWidget(),
                          );

                          if (isSuccess == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ReportListViewScreen(), //StudentsListScreen(),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFfcbb8ef),
                          child: Image.asset("img/word.png", height: 40),
                        ),
                      ),
                      Text(
                        "Xem báo cáo",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CyberLeaderboard(),
                                      //QrSummaryTodayScreenResult(), //SummaryScreenResult(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFfcbb8ef),
                          child: Image.asset("img/anlystatis.png", height: 40),
                        ),
                      ),
                      const Text(
                        "Diện tích",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PopulationLeaderboard(), //AdminCloseAttendanceScreen(),//StudentsStatisticsPage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFFFacdcc),
                          child: Image.asset("img/pie-chart.png", height: 40),
                        ),
                      ),
                      const Text(
                        "Dân số",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB07C97),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
