import 'package:app_02/home_page/my_home_screen.dart';
import 'package:app_02/Widgets/my_button.dart';
import 'package:app_02/email/email_signup_screen.dart';
import 'package:app_02/email/email_forgot_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_02/service/email_auth_service.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; //vòng tròn quay loading
  bool isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  Future<bool> checkphone(String phone) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('students')
            .where("phone", isEqualTo: phone)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });
    final phone = phoneController.text.trim();
    if (await checkphone(phone) & _formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPage()),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Số điện thoại đã được đăng ký")));
      setState(() => isLoading = false);
      return;
    }

    // Thông báo đăng nhập thất bại hoặc thành công
    //showSnackBAR(context, "Đăng nhập $result");
    //hoặc cách 2
    // ScaffoldMessenger.of(context).showSnackBar(
    //    SnackBar(content: Text("Đăng nhập $result")));
    //}
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PHÒNG THAM MƯU",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                //Tạo hàng đăng nhập email
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "điện thoại",
                          hintText: "10 số",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Nhập điện thoại";
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),

                      //Tạo hàng đăng nhập mật khẩu
                      // const SizedBox(height: 30),
                      // TextFormField(
                      //   controller: passwordController,
                      //   decoration: InputDecoration(
                      //     labelText: "Mật khẩu",
                      //     hintText: "Nhập mật khẩu của bạn",
                      //     border: OutlineInputBorder(),
                      //     suffixIcon: IconButton(
                      //       icon: Icon(
                      //         isPasswordHidden
                      //             ? Icons.visibility_off
                      //             : Icons.visibility,
                      //       ),
                      //       onPressed: () {
                      //         setState(() {
                      //           isPasswordHidden = !isPasswordHidden;
                      //         });
                      //       },
                      //     ),
                      //   ),
                      //   validator: (v) {
                      //     if (v == null || v.trim().isEmpty) {
                      //       return "Mật khẩu không đúng";
                      //     }
                      //     return null;
                      //   },
                      //   obscureText: isPasswordHidden,
                      //   obscuringCharacter: '*',
                      // ),
                      //tạo một vòng tròn xoay loading
                      const SizedBox(height: 50),
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                          //Tạo nút button đăng nhập
                          : SizedBox(
                            width: double.infinity,
                            child: MyButton(
                              onTap: _login,
                              buttontext: "Đăng nhập",
                            ),
                          ),
                      SizedBox(height: 20),
                      const EmailForgotPasswordScreen(),
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
                                  builder: (context) => EmailSignupScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
