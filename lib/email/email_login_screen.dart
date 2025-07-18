import 'package:app_02/home_page/my_home_screen.dart';
import 'package:app_02/Widgets/my_button.dart';
import 'package:app_02/email/email_signup_screen.dart';
import 'package:app_02/email/email_forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_02/service/email_auth_service.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State <EmailLoginScreen> createState() => _EmailLoginScreenState();
}
class _EmailLoginScreenState extends State<EmailLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; //vòng tròn quay loading
  bool isPasswordHidden=true;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService =AuthService();

  void _login() async {
    setState(() {
      isLoading=true;
    });
    final result = await _authService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    if ((result == "Thành công") & (_formKey.currentState!.validate())) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyPage(),
        ),
      );
    }else{
      setState(() {
        isLoading=false;
      });
     // Thông báo đăng nhập thất bại hoặc thành công
      //showSnackBAR(context, "Đăng nhập $result");
      //hoặc cách 2
     ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Đăng nhập $result"),
         duration: const Duration(seconds: 2),)
     );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
               child: SingleChildScrollView(
                 child: Column(
                children: [
                  Image.asset("img/logocand.png"),
                  const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("PHÒNG THAM MƯU",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                    ),
                    ),
                  ],
                ),
                  const SizedBox(height: 80,),
                  //Tạo hàng đăng nhập email
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                    TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "abc@gmail",
                      border: OutlineInputBorder()
                    ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Nhập Email";
                        }
                        final emailRegex = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        );
                        if (!emailRegex.hasMatch(v.trim())) {
                          return "Email không hợp lệ";
                        }
                        return null;
                      },
                  ),

                  //Tạo hàng đăng nhập mật khẩu
                  const SizedBox(height: 30,),
                    TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      hintText: "Nhập mật khẩu của bạn",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden=!isPasswordHidden;
                          });
                        },
                      ),
                    ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty || v.length < 6) {
                          return "Mật khẩu không đúng";
                        }
                        return null;
                      },
                    obscureText: isPasswordHidden,
                    obscuringCharacter: '*',
                  ),
                  //tạo một vòng tròn xoay loading
                  const SizedBox(height: 50,),
                  isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue),)
                  //Tạo nút button đăng nhập
                  : SizedBox(
                      width: double.infinity,
                      child: MyButton(
                          onTap: _login,
                          buttontext: "Đăng nhập")
                  ),
                  SizedBox(height: 20,),
                  const EmailForgotPasswordScreen(),
                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text("Bạn chưa có tài khoản?",
                    style: TextStyle(fontSize: 18),
                    ),
                    GestureDetector(
                        child: Text(
                          " Đăng ký",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              letterSpacing: -1
                          ),
                        ),
                        onTap: () { //xử lý khi click vào chữ đăng ký, sẽ ra form đăng ký
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                           builder: (context) => EmailSignupScreen(),
                          ),
                        );
                      },
                    )
                  ],
                  ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          )
      )
    );

     }

}