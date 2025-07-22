import 'dart:io';
import 'package:app_02/models/student.dart';
import 'package:app_02/student_screens/StatisticsExcel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/service/students_firebase_service.dart';
import 'package:path_provider/path_provider.dart';

class StudentsStatisticsPage2 extends StatefulWidget {
  @override
  _StudentsStatisticsPage2State createState() =>
      _StudentsStatisticsPage2State();
}

class _StudentsStatisticsPage2State extends State<StudentsStatisticsPage2> {
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

  Future<void> fetchFilteredStudentsData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('attendance')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();
    final data = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      studentsData = data;
    });
  }

  // Future<void> fetchFilteredData() async {
  //   if (fromDate == null || toDate == null) return;
  //   setState(() => isLoading = true);
  //   final data = await FirebaseService().getStudentStatisticsFiltered(
  //     fromDate: fromDate!,
  //     toDate: toDate!,
  //     className: selectedClass,
  //     nameKeyword: nameController.text.trim(),
  //   );
  //   setState(() {
  //     studentsData = data;
  //     isLoading = false;
  //   });
  // }

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
  //Future<void> exportToExcel(List<StatisticsExcel> data) async {
  Future<void> exportToExcel(List<Map<String, dynamic>> studentsData) async {
    final excell = excel.Excel.createExcel();
    final excel.Sheet sheet = excell['Tổng hợp điểm danh'];

    // Tiêu đề
    sheet.appendRow([
      'Họ và tên',
      'Đơn vị',
      'Có mặt',
      'Công tác',
      'Do ốm',
      'Nghỉ phép',
      'Đi học',
      'Việc riêng',
      'Không lý do',
      'Đi trễ',
    ]);

    // Dữ liệu
    for (var student in studentsData) {
      sheet.appendRow([
        student['ten'],
        student['donVi'],
        student['co_Mat'],
        student['cong_Tac'],
        student['bi_Om'],
        student['nghi_Phep'],
        student['di_Hoc'],
        student['viec_Rieng'],
        student['khong_Lydo'],
        student['di_Tre'],
      ]);
    }

    // Lưu file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/THỐNG_KÊ_ĐIỂM_DANH.xlsx';
    final fileBytes = excell.encode();
    final file =
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes!);
    print('✅ File lưu tại: $filePath');
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
                            //border: Border.all(),
                            border: BorderDirectional(),
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
                            //border: Border.all(),
                            border: BorderDirectional(),
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
                // Row(
                //   children: [
                //     Expanded(
                //       child: DropdownButtonFormField<String>(
                //         value: selectedClass,
                //         hint: const Text('Chọn đơn vị'),
                //         items:
                //             classList.map((String className) {
                //               return DropdownMenuItem<String>(
                //                 value: className,
                //                 child: Text(className),
                //               );
                //             }).toList(),
                //         onChanged: (value) {
                //           setState(() {
                //             selectedClass = value;
                //           });
                //         },
                //       ),
                //     ),
                //     const SizedBox(width: 10),
                //     Expanded(
                //       child: TextField(
                //         controller: nameController,
                //         decoration: const InputDecoration(
                //           hintText: 'Tìm theo tên',
                //           border: OutlineInputBorder(),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (fromDate != null && toDate != null) {
                          fetchFilteredStudentsData(fromDate!, toDate!);
                        }
                      },
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
                      onPressed: () => exportToExcel(studentsData),
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
                           // subtitle: Text('Trạng thái: ${student['Có mặt']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Có mặt: ${student['present']}'),
                                Text('Vắng do công tác: ${student['work']}'),
                                Text('Vắng do ốm: ${student['sick']}'),
                                Text('Vắng do nghỉ phép: ${student['np']}'),
                                Text('Vắng việc cá nhân: ${student['vcn']}'),
                                Text('Vắng không lý do: ${student['kld']}'),
                                Text('Vắng do đi học: ${student['dh']}'),
                                Text('Đi trễ: ${student['dt']}'),
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
