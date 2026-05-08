import 'dart:async';
import 'package:app_02/models/dailyReport.dart';
import 'package:app_02/report_screens/list_report.dart';
import 'package:app_02/service/report_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class AddnewReport extends StatefulWidget {
  const AddnewReport({super.key});
  @override
  State<AddnewReport> createState() => _AddnewReportState();
}

class _AddnewReportState extends State<AddnewReport> {
  final ReportFirebaseService service = ReportFirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();
  final TextEditingController createdAtCtrl = TextEditingController();
  final TextEditingController fullNameCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    contentCtrl.dispose();
    fullNameCtrl.dispose();
    titleCtrl.dispose();
    super.dispose();
  }

  //Hàm viết hoa chữ toàn bộ
  void _capitalizeFullName() {
    String input = fullNameCtrl.text;
    //Tách từng từ theo dấu cách
    List<String> words = input.trim().split('');
    //Viết hoa
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

  //Hàm viết hoa chữ toàn bộ
  void _capitalizeTitle() {
    String input = titleCtrl.text;
    //Tách từng từ theo dấu cách
    List<String> words = input.trim().split('');
    //Viết hoa
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

  void _addReport() async {
    DateTime now = DateTime.now();
    //DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(now);
    _capitalizeFullName();
    _capitalizeTitle();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final report = DailyReport(
          id: '',
          title: titleCtrl.text.trim(),
          fullName: fullNameCtrl.text.trim(),
          content: contentCtrl.text.trim(),
          createdAt: timestampToday, //FieldValue.serverTimestamp() as Timestamp,
        );
        await service.addReport(report);

        if(!mounted) return; //tránh lỗi khi context bị dispose
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm mới thành công"), backgroundColor: Colors.green,),
        );
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isLoading = false);
        fullNameCtrl.clear();
        contentCtrl.clear();
        titleCtrl.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue,
        title: const Text("Thêm mới báo cáo", style: TextStyle(color: Colors.white),),
        centerTitle: true,
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
                      maxLines: 19,
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

                    ElevatedButton(
                      onPressed: _isLoading ? null : _addReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.red)
                          : const Text("Lưu", style: TextStyle(color: Colors.white)),
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
            heroTag: "Danh sách",
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportListScreen()),
            ),
            child: const Icon(Icons.list),
            tooltip: "Danh sách",
          ),
        ],
      ),
    );
  }
}
