import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class PoliceBanner extends StatelessWidget {
  final String url = 'https://www.mps.gov.vn'; // Trang web Bộ Công an

  Future<void> _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Không thể mở URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.yellow[700], // Màu vàng đặc trưng
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, color: Colors.black), // Biểu tượng tùy chọn
            SizedBox(width: 10),
            Text(
              'Bộ Công an',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}