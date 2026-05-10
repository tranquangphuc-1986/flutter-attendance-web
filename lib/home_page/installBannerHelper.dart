import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallBannerHelper {

  static Future<void> showInstallBanner(
      BuildContext context) async {

    if (!kIsWeb) return;

    // ============ Detect iOS ==============

    final userAgent =
    html.window.navigator.userAgent.toLowerCase();

    final isIOS =
        userAgent.contains('iphone') ||
            userAgent.contains('ipad');

    // Chỉ hiện trên iOS
    if (!isIOS) return;


    // =========== Kiểm tra đã cài PWA chưa =============

    bool isStandalone = html.window
        .matchMedia('(display-mode: standalone)')
        .matches;

    bool isIosStandalone = false;

    try {
      isIosStandalone =
      ((html.window.navigator as dynamic).standalone ?? false);
    } catch (_) {}

    bool isInstalled =
        isStandalone || isIosStandalone;

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

      // 3 ngày mới hiện lại
      if (diff.inMinutes < 2) {
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
    // HIỆN BOTTOM SHEET
    // =========================

    if (!context.mounted) return;

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

              const ListTile(
                leading: Icon(
                  Icons.ios_share,
                  color: Colors.blue,
                ),
                title: Text(
                  "Nhấn nút Share trên Safari",
                ),
              ),

              const ListTile(
                leading: Icon(Icons.add_box_outlined),
                title: Text(
                  "Chọn Add to Home Screen",
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
        );
      },
    );
  }
}