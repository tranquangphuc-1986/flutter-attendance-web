import 'package:flutter/material.dart';

class AreaBarChart extends StatelessWidget {
  final List<String> xaNames = ['Xã Tây Trà','Xã Trà Bồng', 'Xã Thanh Bồng', 'Xã Tây Trà Bồng','Xã Bình Minh', 'Xã Đông Sơn',
    'Xã Cà Đam', 'xã Vạn Tường',  'Xã Bình Sơn', 'Xã Đông Trà Bồng', 'Xã Bình Chương',];


  final List<double> areas = [170.86, 139.43, 133.89, 129.1, 128.61, 119.18,
    112.35, 109.28, 100.1, 74.83, 30.79,];

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
                            style: TextStyle(fontSize: 16),
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
