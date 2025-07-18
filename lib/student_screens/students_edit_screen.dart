import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:app_02/service/students_firebase_service.dart';
class EditDataScreen extends StatefulWidget {
  final Student student;
  const EditDataScreen({super.key, required this.student});
  @override
  State<EditDataScreen> createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController classCtrl;
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
  String? selectedClass;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.student.name);
    phoneCtrl = TextEditingController(text: widget.student.phone);
    classCtrl = TextEditingController(text: widget.student.className);
    selectedClass = widget.student.className;
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
        .collection('students')
        .where("phone", isEqualTo: phone)
        .get();
    for (var doc in querySnapshot.docs){
      if(doc.id!=widget.student.id){
        return true;
      }
    }
    return false;
  }

  void _updateStudent() async {
    _capitalizeFullName();
    final nameStudent = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    if (await checkphone(phone)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Số điện thoại đã được đăng ký")));
      setState(() => _isLoading = false);
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final updatedData = Student(
        id: widget.student.id,
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        className: selectedClass!,
      );
      await FirebaseService().updateData(updatedData);
      Navigator.pop(context); // Quay lại màn hình trước
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa sinh viên")),
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
              const SizedBox(height: 50),
              //tạo một vòng tròn xoay loading - cách 1

              ElevatedButton(
                onPressed: _isLoading ? null : _updateStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.red)
                        : const Text("Cập nhật"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
