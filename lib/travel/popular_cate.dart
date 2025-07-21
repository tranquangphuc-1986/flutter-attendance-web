import 'package:app_02/cax/cax_home_screen.dart';
import 'package:app_02/data_diaban/diaban_page_home.dart';
import 'package:app_02/student_screens/students_attendance_screen3_1.dart';
import 'package:app_02/student_screens/students_attendance_screen3_2.dart';
import 'package:app_02/student_screens/students_statistics_page.dart';
import 'package:app_02/student_screens/students_list_screen.dart';
import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class PopularCategories extends StatefulWidget {
  const PopularCategories({super.key});
  @override
  State<PopularCategories> createState() => _PopularCategoriesState();
}

class _PopularCategoriesState extends State<PopularCategories> {
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
              .collection('students')
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
                  Text("Tiện ích", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  // Text(
                  //   "Mở rộng",
                  //   style: TextStyle(fontSize: 14, color: Color(0xFFA36C88)),
                  // ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentsListScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFF8CDEC),
                      child: Image.asset("img/person.png", height: 40),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AttendanceScreen3_1(
                            currentRole: currentRole,
                            currentClass: currentClass,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF9ED2F7),
                      child: Image.asset("img/word.png", height: 40),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummaryScreenResult(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFfcbb8ef),
                      child: Image.asset("img/anlystatis.png", height: 40),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentsStatisticsPage(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFFacdcc),
                      child: Image.asset("img/pie-chart.png", height: 40),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 13, right: 15, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cán bộ",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Điểm danh",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Thống kê",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Tổng hợp",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                  ],
                ),
              ),
         //..................Dãy Icon hàng thứ 2 'thông tin CAX'.......
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreenCAX(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFF8CDEC),
                      child: Image.asset("img/logocand.png", height: 40),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CAXScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF9ED2F7),
                      child: Image.asset("img/statistical.png", height: 40),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceScreen3_2(
                              currentRole: currentRole,
                              currentClass: currentClass),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFfcbb8ef),
                      child: Image.asset("img/anlystatis.png", height: 40),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceScreen3_2(
                              currentRole: currentRole,
                              currentClass: currentClass),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFFacdcc),
                      child: Image.asset("img/pie-chart.png", height: 40),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 13, right: 15, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Công an xã",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Dữ liệu",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Thống kê",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Tổng hợp",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
