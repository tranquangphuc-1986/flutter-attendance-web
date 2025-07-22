import 'dart:convert';
import 'dart:html' as htmt;
import 'dart:io';
import 'package:app_02/models/student.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/service/students_firebase_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StudentsStatisticsPage extends StatefulWidget {
  @override
  _StudentsStatisticsPageState createState() => _StudentsStatisticsPageState();
}

class _StudentsStatisticsPageState extends State<StudentsStatisticsPage> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedClass;
  TextEditingController nameController = TextEditingController();

  bool isLoading = false;
  List<Map<String, dynamic>> studentsData = [];
  List<String> classList = [
    'LĐ',
    'TMCS',
    'TMAN',
    'TMTH',
    'CNTT',
    'XDPT',
    'PC',
    'CY',
    'TTCH',
  ];

  Future<void> fetchFilteredData() async {
    if (fromDate == null || toDate == null) return;
    setState(() => isLoading = true);
    final data = await FirebaseService().getStudentStatisticsFiltered(
      fromDate: fromDate!,
      toDate: toDate!,
      className: selectedClass,
      nameKeyword: nameController.text.trim(),
    );
    setState(() {
      studentsData = data;
      isLoading = false;
    });
  }

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    DateTime initialDate =
        isFrom ? fromDate ?? DateTime.now() : toDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  //Hàm xuất Excel
  Future<void> exportToExcel(
    BuildContext context,
    List<Map<String, dynamic>> studentsData,
  ) async {
    try {
      // Tạo workbook Excel
      final ex = excel.Excel.createExcel();
      final excel.Sheet sheet = ex['Tổng hợp điểm danh'];

      // Tiêu đề
      sheet.appendRow([
        'Họ và tên',
        'Đơn vị',
        'Có mặt',
        'Công tác',
        'Bị ốm',
        'Nghỉ phép',
        'Việc riêng',
        'Đi học',
        'Đi trễ',
        'Không lý do',
        'Tổng số vắng',
      ]);

      // Ghi dữ liệu từng cán bộ
      for (var student in studentsData) {
        final String name = student['name'] ?? '';
        final String className = student['className'] ?? '';
        final int present = student['present'] ?? 0;
        final int work = student['work'] ?? 0;
        final int sick = student['sick'] ?? 0;
        final int np = student['np'] ?? 0;
        final int vcn = student['vcn'] ?? 0;
        final int dh = student['dh'] ?? 0;
        final int dt = student['dt'] ?? 0;
        final int kld = student['kld'] ?? 0;
        final int total = work + sick + np + vcn + dh + dt + kld;
        sheet.appendRow([
          name,
          className,
          present,
          work,
          sick,
          np,
          vcn,
          dh,
          dt,
          kld,
          total,
        ]);
      }
      // Lưu file vào thiết bị
      if (kIsWeb) {
        final bytes = ex.encode();
        final content = base64Encode(bytes!);
        final anchor =
            htmt.AnchorElement(
                href:
                    "data:application/octet-stream;charset=utf-16le;base64,$content",
              )
              ..setAttribute("download", "THONG_KE_DIEM_DANH.xlsx")
              ..click();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/THỐNG_KÊ_ĐIỂM_DANH.xlsx';
        final fileBytes = ex.encode();
        final file = File(filePath);
        await file.writeAsBytes(fileBytes!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File Excel đã lưu tại: $filePath"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        await Share.shareXFiles([XFile(filePath)], text: 'Thống kê điểm danh');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi xuất Excel: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Tổng hợp điểm danh'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
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
                            fromDate == null
                                ? 'Từ ngày'
                                : DateFormat('dd/MM/yyyy').format(fromDate!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickDate(context, false),
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
                            toDate == null
                                ? 'Đến ngày'
                                : DateFormat('dd/MM/yyyy').format(toDate!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedClass,
                        hint: const Text('Chọn đơn vị'),
                        items:
                            classList.map((String className) {
                              return DropdownMenuItem<String>(
                                value: className,
                                child: Text(className),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm theo tên',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: fetchFilteredData,
                      icon: const Icon(Icons.filter_alt, color: Colors.blue),
                      label: const Text(
                        'Lọc',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        nameController.clear();
                        setState(() {
                          selectedClass = null;
                          fromDate = null;
                          toDate = null;
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Làm mới',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => exportToExcel(context, studentsData),
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Xuất excel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : studentsData.isEmpty
                    ? const Center(child: Text('Không có dữ liệu'))
                    : ListView.builder(
                      itemCount: studentsData.length,
                      itemBuilder: (context, index) {
                        final student = studentsData[index];
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              '${student['name']} (${student['className']})',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Có mặt: ${student['present']}'),
                                Text('Vắng do công tác: ${student['work']}'),
                                Text('Vắng do ốm: ${student['sick']}'),
                                Text('Vắng do nghỉ phép: ${student['np']}'),
                                Text('Vắng việc cá nhân: ${student['vcn']}'),
                                Text('Vắng do đi học: ${student['dh']}'),
                                Text('Đi trễ: ${student['dt']}'),
                                Text('Vắng không lý do: ${student['kld']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
