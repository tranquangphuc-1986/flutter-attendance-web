import 'dart:async';
import 'dart:io';
import 'package:app_02/service/students_firebase_service.dart';
import 'package:app_02/student_screens/students_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_02/Widgets/my_button.dart';

class AddNewstudens extends StatefulWidget {
  const AddNewstudens({super.key});
  @override
  State<AddNewstudens> createState() => _AddNewstudensState();
}

class _AddNewstudensState extends State<AddNewstudens> {
  final FirebaseService service = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController classCtrl = TextEditingController();
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
  String? selectedClass;
  String? phoneError;
  bool _isLoading = false;
  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
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
    return querySnapshot.docs.isNotEmpty;
  }
  void _addStudent() async {
    final nameStudent = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    if (await checkphone(phone)) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Số điện thoại đã được đăng ký")));
      setState(() => _isLoading = false);
      return;
    }
    _capitalizeFullName();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final student = Student(
          id: '',
          name: nameStudent,
          phone: phone,
          className: selectedClass ?? '',
        );
        await service.addStudent(student);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Thêm mới thành công"),
            ),
        );
        Navigator.pop(context); //quay lại sau khi thêm
        nameCtrl.clear();
        phoneCtrl.clear();
        setState(() {
          selectedClass = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
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

                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        border: const OutlineInputBorder(),
                          errorText: phoneError, //thay thế cho validator check phone
                      ),
                      validator: (v)  {
                        if (v == null || v.trim().isEmpty) {
                          return "Nhập số điện thoại";
                        } else if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                      onChanged: (v) async {
                        setState(() {
                          phoneError=null;
                          _isLoading=true;
                        });
                        if(await checkphone(v)){
                          phoneError="Số điện thoại đã được đăng ký";
                        }
                        setState(() {
                          _isLoading = false;
                        });
                       // return;
                      },
                    ),
                    const SizedBox(height: 16),
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

                    //tạo một vòng tròn xoay loading
                    const SizedBox(height: 50),
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                        //Tạo nút button lưu từ button code trước
                        : SizedBox(
                          width: double.infinity,
                          child: MyButton(
                            onTap: _addStudent,
                            buttontext: "Lưu",
                          ),
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
