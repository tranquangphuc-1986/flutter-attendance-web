import 'package:app_02/home_page/my_home_screen.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passController = TextEditingController();

  final auth = AuthService();

  bool loading = false;
  String message = "";

  void doLogin() async {
    setState(() => loading = true);

    final phone = phoneController.text.trim();
    final pass = passController.text.trim();

    final error = await auth.login(phone: phone, password: pass);

    setState(() => loading = false);

    if (error == null) {
      setState(() => message = "Đăng nhập thành công!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPage()),
      );
    } else {
      setState(() => message = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : doLogin,
                child: Text(loading ? "Đang xử lý..." : "Đăng nhập"),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
