import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallBannerHelper {

  static Future<void> showInstallBanner(
      BuildContext context) async {

    if (!kIsWeb) return;

    // =========== Kiểm tra đã cài PWA chưa =============
    bool isInstalled = html.window
        .matchMedia('(display-mode: standalone)')
        .matches;
    if (isInstalled) return;

    // ================  Kiểm tra thời gian hiện ===========
    final prefs = await SharedPreferences.getInstance();
    String? lastShown =
    prefs.getString('install_banner_last_shown');

    bool shouldShow = true;

    if (lastShown != null) {

      DateTime lastTime =
      DateTime.parse(lastShown);

      Duration diff =
      DateTime.now().difference(lastTime);

      // 6h mới hiện lại
      if (diff.inHours < 6) {
        shouldShow = false;
      }
    }

    if (!shouldShow) return;

    // Lưu thời gian hiện
    await prefs.setString(
      'install_banner_last_shown',
      DateTime.now().toIso8601String(),
    );

    // ============= HIỆN BOTTOM SHEET ===============
    // 1. Xử lý cho iOS
    if (!context.mounted) return;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Cài ứng dụng vào màn hình chính",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      Text("Bước 1: Nhấn nút Chia sẻ "),
                      Icon(
                        Icons.ios_share,
                        color: Colors.blue,
                      ),
                      Text(" trên Safari"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      Text("Bước 2: Chọn "),
                      Icon(
                        Icons.add_box_outlined,
                        color: Colors.blue,
                      ),
                      Text(" Thêm vào Màn hình chính"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Đã hiểu", style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            );
          },
        );
      }

      //2. xử lý cho Android (nếu muốn, thường Android sẽ tự động hiển thị banner)
      else if (defaultTargetPlatform == TargetPlatform.android) {
        js.context.callMethod('presentInstallPrompt');
      }
  }
}