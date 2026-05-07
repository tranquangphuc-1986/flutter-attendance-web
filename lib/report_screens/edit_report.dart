import 'package:app_02/models/dailyReport.dart';
import 'package:app_02/service/report_firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class EditReport extends StatefulWidget {
  final DailyReport report;
  const EditReport({super.key, required this.report});
  @override
  State<EditReport> createState() => _EditReportState();
}

class _EditReportState extends State<EditReport> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleCtrl;
  late TextEditingController contentCtrl;
  late TextEditingController createdAtCtrl;
  late TextEditingController fullNameCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.report.title);
    contentCtrl = TextEditingController(text: widget.report.content);
    createdAtCtrl = TextEditingController(text: widget.report.createdAt.toDate().toString());
    fullNameCtrl = TextEditingController(text: widget.report.fullName);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    createdAtCtrl.dispose();
    fullNameCtrl.dispose();
    super.dispose();
  }

  //Hàm viết hoa toàn bộ chữ cái
  void _capitalizeFullName() {
    String input = fullNameCtrl.text;
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
    fullNameCtrl.value = fullNameCtrl.value.copyWith(
      text: capitalizeName,
      selection: TextSelection.collapsed(offset: capitalizeName.length),
    );
  }
  void _capitalizeTitle() {
    String input = titleCtrl.text;
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
    titleCtrl.value = titleCtrl.value.copyWith(
      text: capitalizeName,
      selection: TextSelection.collapsed(offset: capitalizeName.length),
    );
  }

  void _updateReport() async {
    _capitalizeFullName();
    _capitalizeTitle();
     if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final updatedData = DailyReport(
        id: widget.report.id,
        title: titleCtrl.text.trim(),
        content: contentCtrl.text.trim(),
        createdAt: Timestamp.fromDate(DateTime.now()),
        fullName: fullNameCtrl.text.trim(),
      );
      await ReportFirebaseService().updateReport(updatedData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã sửa dữ liệu"), backgroundColor: Colors.green,),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context); // Quay lại màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text("Sửa báo cáo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
          child:  Column(
            children: [

              SizedBox(height: 30),

              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Tiêu đề báo cáo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Nhập tiêu đề";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: contentCtrl,
                textAlign: TextAlign.justify,
                maxLines: 15,
                decoration: const InputDecoration(
                  labelText: "Nội dung báo cáo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Nhập nội dung";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(
                  labelText: "Cán bộ báo cáo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Nhập họ tên";
                  }
                  return null;
                },
              ),


              const SizedBox(height: 50),
              //tạo một vòng tròn xoay loading - cách 1

              ElevatedButton(
                onPressed: _isLoading ? null : _updateReport,
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
      ),
    );
  }
}
