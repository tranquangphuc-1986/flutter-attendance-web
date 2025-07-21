import 'package:app_02/service/email_auth_service.dart';
import 'package:app_02/Widgets/my_button.dart';
import 'package:app_02/Widgets/snackbar.dart';
import 'package:app_02/email/email_login_screen.dart';
import 'package:flutter/material.dart';
class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final List<String> roleList = ['Admin', 'Lãnh đạo', 'Chỉ huy TMCS',
    'Chỉ huy TMAN','Chỉ huy TMTH','Chỉ huy PC','Chỉ huy XDPT',
    'Chỉ huy CNTT','Chỉ huy CY','Chỉ huy TTCH','Cán bộ'];
  String? selectedRole;
  bool isLoading = false; //vòng tròn quay loading
  bool isPasswordHidden = true;
  final AuthService _authService = AuthService();

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final result = await _authService.signUpUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        role: selectedRole ?? '',
      );
      if (result == "Thành công") {
        setState(() {
          isLoading = false;
        });
        showSnackBAR(context, "Đăng ký thành công. Hãy đăng nhập");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đăng nhập $result"),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,)
        );
        //showSnackBAR(context, "Đăng ký $result");
      }
    }
  }

  String? validatePass(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "Nhập mật khẩu";
    }
    final hasUppercase = v.contains(RegExp(r'[A-Z]'));
    final hasSpecialChar = v.contains(RegExp(r'[!@#\$%^&*()_+{}:;|<>,.?=/-]'));
    final hasMinLength = v.length >= 6;
    if (!hasUppercase || !hasSpecialChar || !hasMinLength) {
      return "Mật khẩu ít nhất 6 ký tự, có viết hoa và ký tự đặc biệt";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Đăng ký tài khoản"),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            //tạo thanh cuộn khi nhiều dòng
            child: Column(
              children: [
                //Image.asset("img/car.png"),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //Tạo hàng nhập họ và tên
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Họ và tên",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Nhập họ và tên";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      //Tạo hàng đăng nhập email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
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
                      const SizedBox(height: 30),

                      //Tạo hàng nhập phone
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Điện thoại",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Nhập số điện thoại";
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      //Tạo hàng đăng nhập mật khẩu
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          hintText: "Mật khẩu ít nhất 6 ký tự",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: validatePass,
                        obscureText: isPasswordHidden,
                        obscuringCharacter: '*',
                      ),
                      const SizedBox(height: 40),

                      //Tạo hàng Vai trò
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Vai trò",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            roleList
                                .map(
                                  (rls) => DropdownMenuItem(
                                    value: rls,
                                    child: Text(rls),
                                  ),
                                )
                                .toList(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Chọn vai trò";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedRole = value;
                              roleController.text = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 40),

                      //Tạo nút button đăng ký
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                          : SizedBox(
                            width: double.infinity,
                            child: MyButton(
                              onTap: _signUp,
                              buttontext: "Đăng ký",
                            ),
                          ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đăng nhập tại đây,",
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            onTap: () {
                              //xử lý khi click vào chữ đăng nhập, sẽ ra form đăng nhập
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailLoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              " Đăng nhập",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: -1,
                              ),
                            ),
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
