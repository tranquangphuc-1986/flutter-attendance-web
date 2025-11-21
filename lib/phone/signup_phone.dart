// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class SignUpPhoneScreen extends StatefulWidget {
//   @override
//   _SignUpPhoneScreenState createState() => _SignUpPhoneScreenState();
// }
//
// class _SignUpPhoneScreenState extends State<SignUpPhoneScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController fullnameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController unitController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   String? selectedRole;
//
//   bool isLoading = false;
//
//   Future<void> _signUpPhone() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => isLoading = true);
//
//     try {
//       String phone = phoneController.text.trim();
//
//       // Firebase Auth: tạo user bằng email giả (vì Firebase không cho tạo trực tiếp bằng phone+password)
//       String fakeEmail = "$phone@myapp.com";
//
//       UserCredential userCred = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//           email: fakeEmail, password: passwordController.text);
//
//       // Firestore: lưu thông tin người dùng
//       await FirebaseFirestore.instance
//           .collection("usersPhone")
//           .doc(userCred.user!.uid)
//           .set({
//         "fullname": fullnameController.text.trim(),
//         "phone": phone,
//         "unit": unitController.text.trim(),
//         "role": selectedRole,
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Đăng ký thành công")),
//       );
//
//       Navigator.pop(context); // Quay lại màn hình login
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Lỗi: ${e.message}")),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text("Đăng ký tài khoản")),
//         body: SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                   TextFormField(
//                   controller: fullnameController,
//                   decoration: InputDecoration(labelText: "Họ và tên"),
//                   validator: (val) =>
//                   val!.isEmpty ? "Nhập họ tên đầy đủ" : null,
//                 ),
//                 TextFormField(
//                   controller: phoneController,
//                   decoration: InputDecoration(labelText: "Số điện thoại"),
//                   keyboardType: TextInputType.phone,
//                   validator: (val) =>
//                   val!.isEmpty ? "Nhập số điện thoại" : null,
//                 ),
//                 TextFormField(
//                   controller: unitController,
//                   decoration: InputDecoration(labelText: "Đơn vị / Lớp học"),
//                   validator: (val) =>
//                   val!.isEmpty ? "Nhập đơn vị hoặc lớp" : null,
//                 ),
//                     TextFormField(
//                       controller: passwordController,
//                       decoration: InputDecoration(labelText: "Mật khẩu"),
//                       obscureText: true,
//                       validator: (val) {
//                         if (val == null || val.length < 6) {
//                           return "Mật khẩu ít nhất 6 ký tự";
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: selectedRole,
//                       items: ["admin", "chihuy", "canbo"]
//                           .map((role) => DropdownMenuItem(
//                         value: role,
//                         child: Text(role.toUpperCase()),
//                       ))
//                           .toList(),
//                       onChanged: (val) => setState(() => selectedRole = val),
//                       decoration: InputDecoration(labelText: "Vai trò"),
//                       validator: (val) => val == null ? "Chọn vai trò" : null,
//                     ),
//                     SizedBox(height: 24),
//                     isLoading
//                         ? CircularProgressIndicator()
//                         : ElevatedButton(
//                         onPressed: _signUpPhone, child: Text("Đăng ký")),
//                   ],
//                 ),
//             ),
//         ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:app_02/Widgets/snackbar.dart';
import 'package:app_02/email/email_login_screen.dart';
import 'package:app_02/phone/phone_model_service.dart';
import 'package:app_02/student_screens/students_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_02/Widgets/my_button.dart';

class SignUpPhoneScreen extends StatefulWidget {
  const SignUpPhoneScreen({super.key});
  @override
  State<SignUpPhoneScreen> createState() => _SignUpPhoneScreenState();
}

class _SignUpPhoneScreenState extends State<SignUpPhoneScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController classCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController roleCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final List<String> classList = [
    'TMCS',
    'TMAN',
    'TMTH',
    'CNTT',
    'XDPT',
    'PC',
    'CY',
    'TTCH',
    'LĐ',
  ];

  final List<String> roleList = ['Admin', 'Cán bộ'];

  String? selectedClass;
  String? selectedRole;
  String? phoneError;
  bool _isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    classCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  //Hàm viết hoa chữ cái đầu mỗi từ
  void _capitalizeFullName() {
    String input = nameCtrl.text;
    //Tách từng từ theo dấu cách
    List<String> words = input.trim().split('');
    //Viết hoa chữ cái đầu mỗi từ
    List<String> capitalizeWords =
        words.map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).toList();
    //Ghép lại chuỗi
    String capitalizeName = capitalizeWords.join('');
    //Gán lại vào controller mà không làm nhảy con trỏ
    nameCtrl.value = nameCtrl.value.copyWith(
      text: capitalizeName,
      selection: TextSelection.collapsed(offset: capitalizeName.length),
    );
  }

  //Hàm điều kiện mật khẩu
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

  //Hàm kiểm tra số điện thoại bị trùng
  Future<bool> checkphone(String phone) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('userLogin')
            .where("phone", isEqualTo: phone)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }


  void _addUser() async {
    _capitalizeFullName();
    final namePolice = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (await checkphone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Số điện thoại đã được đăng ký"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = UserModel(
          id: '',//UniqueKey().toString(), // hoặc tạo ID bằng uuid
          uid: '', //FirebaseAuth.instance.currentUser?.uid ?? '',
          name: namePolice,
          phone: phone,
          email: email,
          password: password,
          className: selectedClass ?? '',
          role: selectedRole ?? '',
        );
        final result = await _authService.signUpUser(data);
        if (!mounted) return; //tránh lỗi khi context bị dispose
        if (result == "Thành công") {
          setState(() {
            _isLoading = false;
          });
          showSnackBAR(context, "Đăng ký thành công. Hãy đăng nhập");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đăng nhập $result"),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          //showSnackBAR(context, "Đăng ký $result");
        }
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isLoading = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Thêm mới cán bộ"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    //chọn ảnh đại diện
                    FormField<File>(
                      // validator: (v) {
                      //   if (v == null) {
                      //     return "Chọn ảnh đại diện";
                      //   }
                      //   return null;
                      // },
                      builder: (FormFieldState<File> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ảnh đại diện",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  final XFile? image = await showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Chọn nguồn"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.photo_library,
                                                ),
                                                title: Text("Thư viện"),
                                                onTap: () async {
                                                  Navigator.pop(
                                                    context,
                                                    await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    ),
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.camera_alt),
                                                title: Text("Máy ảnh"),
                                                onTap: () async {
                                                  Navigator.pop(
                                                    context,
                                                    await _picker.pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                  );
                                  if (image != null) {
                                    setState(() {
                                      _profileImage = File(image.path);
                                      state.didChange(_profileImage);
                                    });
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(60),
                                    border: Border.all(
                                      color:
                                          state.hasError
                                              ? Colors.red
                                              : Colors.grey.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      _profileImage != null
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              60,
                                            ),
                                            child: Image.file(
                                              _profileImage!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                ),
                              ),
                            ),
                            if (state.hasError)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    state.errorText!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    //kết thúc chọn ảnh đại diện
                    SizedBox(height: 40),

                    //Nhập họ và tên
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Họ tên",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Nhập họ và tên";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    //Nhập đơn vị
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: const InputDecoration(
                        labelText: "Đơn vị",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          classList
                              .map(
                                (cls) => DropdownMenuItem(
                                  value: cls,
                                  child: Text(cls),
                                ),
                              )
                              .toList(),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Nhập đơn vị";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedClass = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    //Nhập số điện thoại
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        border: const OutlineInputBorder(),
                        errorText:
                            phoneError, //thay thế cho validator check phone
                      ),
                      onChanged: (v) async {
                        setState(() {
                          phoneError = null;
                          _isLoading = true;
                        });
                        if (await checkphone(v)) {
                          phoneError = "Số điện thoại đã được đăng ký";
                        }
                        setState(() {
                          _isLoading = false;
                        });
                        // return;
                      },
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Nhập số điện thoại";
                        } else if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                          return 'Số điện thoại không hợp lệ hoặc đã đăng ký';
                        }
                        // return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    //Tạo hàng đăng nhập email
                    TextFormField(
                      controller: emailCtrl,
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
                    const SizedBox(height: 16),

                    //Tạo hàng đăng nhập mật khẩu
                    TextFormField(
                      controller: passwordCtrl,
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
                    const SizedBox(height: 16),

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
                            roleCtrl.text = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 30),

                    //Tạo nút button đăng ký
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                        : SizedBox(
                          width: double.infinity,
                          child: MyButton(
                            onTap: _addUser,
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
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "summary",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsListScreen()),
                ),
            child: const Icon(Icons.groups),
            tooltip: "Tổng hợp",
          ),
        ],
      ),
    );
  }
}
