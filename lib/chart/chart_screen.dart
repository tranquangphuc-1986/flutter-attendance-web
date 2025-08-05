import 'package:app_02/chart/area_chart.dart';
import 'package:app_02/chart/population_chart.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Biểu đồ'),
          backgroundColor: Colors.blue,),
        backgroundColor: Colors.white,
    body:  Padding(
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
                          builder: (context) => PopulationChart(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFF8CDEC),
                          child: Image.asset("img/person.png", height: 22),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Biểu đồ dân số',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AreaBarChart()),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFF8CDEC),
                          child: Image.asset("img/statistical.png", height: 22),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Biểu đồ diện tích',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
