import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallBannerHelper {

  static Future<void> showInstallBanner(
      BuildContext context) async {

    // Chỉ dùng cho Web
    if (!kIsWeb) return;

    // =========================
    // 1. Kiểm tra đã cài PWA chưa
    // =========================

    bool isStandalone = html.window
        .matchMedia('(display-mode: standalone)')
        .matches;

    // iOS Safari
    final navigator = html.window.navigator;
    bool isIosStandalone =
        (navigator as dynamic).standalone == true;

    bool isInstalled =
        isStandalone || isIosStandalone;

    // Nếu đã cài -> không hiện nữa
    if (isInstalled) return;

    // =========================
    // 2. Kiểm tra thời gian hiện gần nhất
    // =========================

    final prefs = await SharedPreferences.getInstance();

    String? lastShown =
    prefs.getString('install_banner_last_shown');

    // Nếu chưa từng hiện -> hiện luôn
    bool shouldShow = true;

    if (lastShown != null) {

      DateTime lastShownTime =
      DateTime.parse(lastShown);

      Duration diff =
      DateTime.now().difference(lastShownTime);

      // Chỉ hiện lại sau 3 ngày
      if (diff.inDays < 3) {
        shouldShow = false;
      }
    }

    if (!shouldShow) return;

    // Lưu thời gian hiện
    await prefs.setString(
      'install_banner_last_shown',
      DateTime.now().toIso8601String(),
    );

    // =========================
    // 3. Hiển thị banner iOS
    // =========================

    if (defaultTargetPlatform == TargetPlatform.iOS) {

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Cài ứng dụng vào màn hình chính",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 15),

              const ListTile(
                leading: Icon(
                  Icons.ios_share,
                  color: Colors.blue,
                ),
                title: Text(
                  "Nhấn nút Chia sẻ trên Safari",
                ),
              ),

              const ListTile(
                leading: Icon(Icons.add_box_outlined),
                title: Text(
                  "Chọn 'Add to Home Screen'",
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Đã hiểu"),
              ),
            ],
          ),
        ),
      );
    }
  }
}