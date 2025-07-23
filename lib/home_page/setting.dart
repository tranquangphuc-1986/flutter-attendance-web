import 'package:app_02/service/email_auth_service.dart';
import 'package:app_02/email/email_login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  String currentRole = '';
  String currentClass = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance
              .collection('userLogin')
              .doc(uid)
              .get();
      setState(() {
        currentRole = doc['role'];
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      }); // Cập nhật giao diện
    }
  }

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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Đăng ký tài khoản'),
            onTap: () {
              if (currentRole == 'Admin') {
                Navigator.pushNamed(context, '/signup');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn không có quyền truy cập.'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 1),
                  ),
                );
                return;
              }
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text('Đổi mật khẩu'),
            onTap: () => Navigator.pushNamed(context, '/account'),
          ),
          // Divider(),
          // ListTile(
          //   leading: const Icon(Icons.lock),
          //   title: const Text('Bảo mật'),
          //   onTap: () => Navigator.pushNamed(context, '/security'),
          // ),
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
            leading: const Icon(Icons.phonelink_ring_rounded, color: Colors.blueAccent,),
            title: const Text('Điện thoại hỗ trợ   0978823579'),
          ),
          // ListTile(
          //   leading: const Icon(Icons.language),
          //   title: const Text('Hướng dẫn'),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.image),
          //   title: const Text('Thay đổi hình nền'),
          //   onTap: () => Navigator.pushNamed(context, '/wallpaper'),
          // ),
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
                              MaterialPageRoute(
                                builder: (context) => const EmailLoginScreen(),
                              ), //PhoneLoginScreen()),
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
