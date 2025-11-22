import 'package:flutter/material.dart';
import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final phoneController = TextEditingController();
  final passController = TextEditingController();

  final auth = AuthService();

  bool loading = false;
  String message = "";

  void doSignup() async {
    setState(() => loading = true);

    final phone = phoneController.text.trim();
    final pass = passController.text.trim();

    final error = await auth.signup(phone: phone, password: pass);

    setState(() => loading = false);

    if (error == null) {
      setState(() => message = "Đăng ký thành công!");
    } else {
      setState(() => message = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
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
                onPressed: loading ? null : doSignup,
                child: Text(loading ? "Đang xử lý..." : "Đăng ký"),
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
