import 'package:app_02/chart/area_chart.dart';
import 'package:app_02/student_screens/students_statistics_page.dart';
import 'package:app_02/student_screens/students_list_screen.dart';
import 'package:app_02/student_screens/students_summary_screen.dart';
import 'package:flutter/material.dart';
class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});
  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                              (context) => AreaBarChart(),
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
                      "Biểu đồ diện tích",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Biểu đồ dân số",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Biểu đồ kinh tế",
                      style: TextStyle(fontSize: 16, color: Color(0xFFB07C97)),
                    ),
                    Text(
                      "Biểu đồ....",
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
