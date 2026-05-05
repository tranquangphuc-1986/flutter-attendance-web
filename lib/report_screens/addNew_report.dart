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
  // final TextEditingController reportTimeCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();
  final TextEditingController createdAtCtrl = TextEditingController();
  final TextEditingController fullNameCtrl = TextEditingController();
  DateTime? reportTime;
  bool _isLoading = false;

  @override
  void dispose() {
    contentCtrl.dispose();
    fullNameCtrl.dispose();
    // reportTimeCtrl.dispose();
    super.dispose();
  }

  //Hàm viết hoa chữ cái đầu mỗi từ
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

  void _addReport() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(today);
    _capitalizeFullName();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final report = DailyReport(
          id: '',
          reportTime: reportTime!,
          fullName: fullNameCtrl.text.trim(),
          content: contentCtrl.text.trim(),
          createdAt: FieldValue.serverTimestamp() as Timestamp,
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
        // createdAtCtrl.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),));
      }
    }
  }

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    DateTime initialDate =
    isFrom ? reportTime ?? DateTime.now() : reportTime ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          reportTime = picked;
        } else {
          reportTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Thêm mới báo cáo"),
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
                    // SizedBox(height: 40),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            reportTime == null
                                ? 'Tình hình ngày'
                                : DateFormat('dd/MM/yyyy').format(reportTime!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: contentCtrl,
                      maxLines: 50,
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

                    // const SizedBox(height: 16),
                    // TextFormField(
                    //   controller: createdAtCtrl,
                    //   decoration: const InputDecoration(
                    //     labelText: "Ngày tạo (dd/MM/yyyy)",
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   validator: (v) {
                    //     if (v == null || v.trim().isEmpty) {
                    //       return "Nhập ngày tạo";
                    //     }
                    //     // Kiểm tra định dạng ngày
                    //     if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(v)) {
                    //       return "Định dạng ngày không hợp lệ";
                    //     }
                    //     return null;
                    //   },
                    // ),

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
            heroTag: "Tổng hợp",
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportListScreen()),
            ),
            child: const Icon(Icons.groups),
            tooltip: "Tổng hợp",
          ),
        ],
      ),
    );
  }
}
