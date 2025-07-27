import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HorizontalAreaChart extends StatelessWidget {
  final List<String> xaNames = ['Xã A', 'Xã B', 'Xã C', 'Xã D', 'Xã E'];
  final List<double> areas = [300, 180, 100, 250, 270];

  @override
  Widget build(BuildContext context) {
    final double maxValue = areas.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: Text('Biểu đồ diện tích')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Biểu đồ diện tích',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue + 50,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, _) {
                          int index = value.toInt();
                          if (index >= 0 && index < xaNames.length) {
                            return Text(
                              xaNames[index],
                              style: TextStyle(fontSize: 14),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(xaNames.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: areas[index],
                          width: 20,
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(4),
                          rodStackItems: [],
                        ),
                      ],
                      showingTooltipIndicators: [],
                    );
                  }),
                ),
              ),
            ),

            // Hiển thị số liệu bên phải thanh
            SizedBox(height: 16),
            ...List.generate(xaNames.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const SizedBox(width: 60), // match reservedSize
                    Expanded(
                      child: LinearProgressIndicator(
                        value: areas[index] / maxValue,
                        minHeight: 20,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${areas[index].toInt()} Km2',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
