import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPhoneScreen extends StatefulWidget {
  @override
  _SignUpPhoneScreenState createState() => _SignUpPhoneScreenState();
}

class _SignUpPhoneScreenState extends State<SignUpPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedRole;

  bool isLoading = false;

  Future<void> _signUpPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String phone = phoneController.text.trim();

      // Firebase Auth: tạo user bằng email giả (vì Firebase không cho tạo trực tiếp bằng phone+password)
      String fakeEmail = "$phone@myapp.com";

      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: fakeEmail, password: passwordController.text);

      // Firestore: lưu thông tin người dùng
      await FirebaseFirestore.instance
          .collection("usersPhone")
          .doc(userCred.user!.uid)
          .set({
        "fullname": fullnameController.text.trim(),
        "phone": phone,
        "unit": unitController.text.trim(),
        "role": selectedRole,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thành công")),
      );

      Navigator.pop(context); // Quay lại màn hình login
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.message}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Đăng ký tài khoản")),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                  TextFormField(
                  controller: fullnameController,
                  decoration: InputDecoration(labelText: "Họ và tên"),
                  validator: (val) =>
                  val!.isEmpty ? "Nhập họ tên đầy đủ" : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Số điện thoại"),
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                  val!.isEmpty ? "Nhập số điện thoại" : null,
                ),
                TextFormField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: "Đơn vị / Lớp học"),
                  validator: (val) =>
                  val!.isEmpty ? "Nhập đơn vị hoặc lớp" : null,
                ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: "Mật khẩu"),
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return "Mật khẩu ít nhất 6 ký tự";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: ["admin", "chihuy", "canbo"]
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.toUpperCase()),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => selectedRole = val),
                      decoration: InputDecoration(labelText: "Vai trò"),
                      validator: (val) => val == null ? "Chọn vai trò" : null,
                    ),
                    SizedBox(height: 24),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                        onPressed: _signUpPhone, child: Text("Đăng ký")),
                  ],
                ),
            ),
        ),
    );
  }
}