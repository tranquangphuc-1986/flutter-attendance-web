import 'package:app_02/home_page/my_home_screen.dart';
import 'package:app_02/phone/auth_service.dart';
import 'package:app_02/phone/signup_screen.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passController = TextEditingController();

  final auth = AuthServicePhone();

  bool loading = false;
  String message = "";

  void doLogin() async {
    setState(() => loading = true);

    final phone = phoneController.text.trim();
    final pass = passController.text.trim();

    final error = await auth.loginUser(phone: phone, password: pass);

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
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bạn chưa có tài khoản?",
                    style: TextStyle(fontSize: 18),
                  ),
                  GestureDetector(
                    child: Text(
                      " Đăng ký",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: -1,
                      ),
                    ),
                    onTap: () {
                      //xử lý khi click vào chữ đăng ký, sẽ ra form đăng ký
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPhoneScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
