import 'package:app_02/service/email_auth_service.dart';
import 'package:app_02/email/email_login_screen.dart';
import 'package:flutter/material.dart';

//class SettingsScreen extends StatelessWidget {
   //SettingsScreen({super.key});

   class SettingsScreen extends StatefulWidget {
   const SettingsScreen({super.key});

   @override
   State <SettingsScreen> createState() => _SettingsScreenState();
   }
class _SettingsScreenState extends State<SettingsScreen> {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Cài đặt'), leading: const BackButton()),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text(
          "Cài đặt",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

      ),

      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Quản lý tài khoản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Đăng ký tài khoản'),
            onTap: () => Navigator.pushNamed(context, '/signup'),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text('Đổi mật khẩu'),
            onTap: () => Navigator.pushNamed(context, '/account'),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Bảo mật'),
            onTap: () => Navigator.pushNamed(context, '/security'),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Cài đặt thanh toán trực tuyến'),
            onTap: () => Navigator.pushNamed(context, '/payment'),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Chia sẻ'),
            onTap: () => Navigator.pushNamed(context, '/share'),
          ),
          Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Hỗ trợ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Điện thoại hỗ trợ   0978823579'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Hướng dẫn'),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Thay đổi hình nền'),
            onTap: () => Navigator.pushNamed(context, '/wallpaper'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text(
                        'Bạn có chắc chắn muốn đăng xuất không?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Huỷ'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const EmailLoginScreen()), //PhoneLoginScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
