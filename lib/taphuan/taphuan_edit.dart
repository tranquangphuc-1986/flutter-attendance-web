import 'package:app_02/phone/phone_model_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTaphuanScreen extends StatefulWidget {
  final UserModel student;
  const EditTaphuanScreen({super.key, required this.student});
  @override
  State<EditTaphuanScreen> createState() => _EditTaphuanScreenState();
}

class _EditTaphuanScreenState extends State<EditTaphuanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController classCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController roleCtrl;
  late TextEditingController passCtrl;
  bool _isLoading = false;
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

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.student.name);
    phoneCtrl = TextEditingController(text: widget.student.phone);
    classCtrl = TextEditingController(text: widget.student.className);
    emailCtrl = TextEditingController(text: widget.student.email);
    roleCtrl = TextEditingController(text: widget.student.role);
    selectedClass = widget.student.className;
    selectedRole = widget.student.role;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    //classCtrl.dispose();
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
  //Hàm kiểm tra số điện thoại bị trùng
  Future<bool> checkphone(String phone) async {
    final querySnapshot =
    await FirebaseFirestore.instance
        .collection('userLogin')
        .where("phone", isEqualTo: phone)
        .get();
    for (var doc in querySnapshot.docs){
      if(doc.id!=widget.student.id){
        return true;
      }
    }
    return false;
  }

  void _updateData() async {
    _capitalizeFullName();
    final nameStudent = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    if (await checkphone(phone)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Số điện thoại đã được đăng ký"),
          backgroundColor: Colors.red));
      setState(() => _isLoading = false);
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final updatedData = UserModel(
        id: widget.student.id,
        uid: widget.student.uid,
        name: nameStudent,//nameCtrl.text.trim(),
        phone: phone, //phoneCtrl.text.trim(),
        email: email, //emailCtrl.text.trim(),
        password: password, //passCtrl.text.trim(),
        role: selectedRole!, //selectedRole!,
        className: selectedClass!, //selectedClass!,
      );
      await FirebaseUserService().updateUser(updatedData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thành công"), backgroundColor: Colors.green,),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context); // Quay lại màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cập nhật thông tin")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Họ tên"),
                validator: (v) => v!.isEmpty ? "Nhập họ tên" : null,
              ),
              const SizedBox(height: 16,),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Nhập số điện thoại";
                  } else if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16,),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: "Đơn vị",
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
              const SizedBox(height: 16,),
              //Tạo hàng Vai trò
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: "Vai trò",
                  //border: OutlineInputBorder(),
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
                      //roleCtrl.text = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 50),
              //tạo một vòng tròn xoay loading - cách 1
              ElevatedButton(
                onPressed: _isLoading ? null : _updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.red)
                    : const Text("Cập nhật", style: TextStyle(color: Colors.white)),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
