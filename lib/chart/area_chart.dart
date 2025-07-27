import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AreaBarChartScreen extends StatelessWidget {
  final List<String> xaNames = ['Xã A', 'Xã B', 'Xã C', 'Xã D', 'Xã E'];
  final List<double> areas = [100, 110, 90, 75, 300];

  @override
  Widget build(BuildContext context) {
    final maxArea = areas.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ diện tích các xã')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột tên xã
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  xaNames
                      .map(
                        (name) => Container(
                          height: 40,
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(width: 8),
            // Biểu đồ và overlay text
            Expanded(
              child: Stack(
                children: [
                  // Biểu đồ thanh nằm ngang
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxArea + 30,
                      minY: 0,
                      groupsSpace: 12,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(xaNames.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: areas[index],
                              width: 20,
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  // Overlay số liệu diện tích
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(areas.length, (index) {
                        return Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            left: _calculateTextPadding(areas[index], maxArea),
                          ),
                          child: Text(
                            '${areas[index]} km²',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tính khoảng cách để text nằm trong thanh biểu đồ
  double _calculateTextPadding(double area, double maxArea) {
    double percent = area / maxArea;
    return percent * 200 * 0.6; // có thể điều chỉnh số 200 tuỳ UI
  }
}
