import 'package:flutter/material.dart';

class PopulationChart extends StatelessWidget {

  final List<String> xaNames = ['Tây Trà','Trà Bồng', 'Thanh Bồng', 'Tây Trà Bồng','Bình Minh', 'Đông Sơn',
    'Cà Đam', 'Vạn Tường',  'Bình Sơn', 'Đông Trà Bồng', 'Bình Chương',];

  final List<double> areas = [11617, 18926, 7426, 8078, 19673, 67711,
    4336, 60612, 89058, 11197, 16565,];

  @override
  Widget build(BuildContext context) {
    final double maxArea = areas.reduce((a, b) => a > b ? a : b);

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
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: xaNames.length,
                itemBuilder: (context, index) {
                  double value = areas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            xaNames[index],
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 24,
                                width:
                                    (value / maxArea) *
                                    MediaQuery.of(context).size.width *
                                    0.6,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '${value.toInt()} Km2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
