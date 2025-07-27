import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HorizontalAreaChart extends StatelessWidget {
  final List<String> areaNames = ['Xã A', 'Xã B', 'Xã C', 'Xã D', 'Xã E'];
  final List<double> areaValues = [100, 110, 90, 75, 300];

  @override
  Widget build(BuildContext context) {
    final maxArea = areaValues.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: Text("Thống kê diện tích")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Biểu đồ thanh
                BarChart(
                  BarChartData(
                    maxY: maxArea + 50,
                    alignment: BarChartAlignment.spaceBetween,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index >= 0 && index < areaNames.length) {
                              return Text(
                                areaNames[index],
                                style: TextStyle(fontSize: 14),
                              );
                            }
                            return SizedBox.shrink();
                          },
                          reservedSize: 80,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(areaValues.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: areaValues[index],
                            width: 25,
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.orange,
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                // Overlay số liệu trong thanh
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(areaValues.length, (index) {
                        final value = areaValues[index];
                        final percent = value / maxArea;
                        return Row(
                          children: [
                            SizedBox(width: 85), // Khoảng trống bằng leftTitle
                            SizedBox(
                              width: (constraints.maxWidth - 100) * percent,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${value.toInt()} km²',
                                  style: TextStyle(
                                    color: Colors.yellowAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
