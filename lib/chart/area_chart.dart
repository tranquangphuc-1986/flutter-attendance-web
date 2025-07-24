import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AreaBarChartScreen extends StatelessWidget {
  final List<String> xaNames = ['Xã A', 'Xã B', 'Xã C', 'Xã D', 'Xã E'];
  final List<double> areas = [100, 110, 90, 75, 300];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Biểu đồ diện tích các xã')),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Hiển thị tên xã bên trái
    Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: xaNames.map((name) {
    return Container(
    height: 40,
    alignment: Alignment.centerRight,
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
    name,
    style: TextStyle(fontSize: 14),
    ),
    );
    }).toList(),
    ),
    const SizedBox(width: 12),
    // Biểu đồ cột nằm ngang
    Expanded(
    child: BarChart(
    BarChartData(
    maxY: 320,
    barTouchData: BarTouchData(enabled: false),
    alignment: BarChartAlignment.spaceAround,
    titlesData: FlTitlesData(
    leftTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
    ),
    bottomTitles: AxisTitles(
    sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 42,
    getTitlesWidget: (value, meta) {
    return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Text('${value.toInt()} km²',
    style: TextStyle(fontSize: 12)),
    );
    },
    ),
    ),
    ),
    gridData: FlGridData(show: true),
    borderData: FlBorderData(show: false),
    barGroups: List.generate(xaNames.length, (index) {
    return BarChartGroupData(
    x: index,
    barRods: [
    BarChartRodData(
    toY: areas[index],
    color: Colors.teal,
    width: 22,
      borderRadius: BorderRadius.circular(4),
      rodStackItems: [],
    ),
    ],
    );
    }),
    ),
    ),
    ),
    ],
    ),
        ),
    );
  }
}