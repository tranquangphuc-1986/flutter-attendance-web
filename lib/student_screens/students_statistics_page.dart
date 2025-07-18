import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/service/students_firebase_service.dart';

class StudentsStatisticsPage extends StatefulWidget {
  @override
  _StudentsStatisticsPageState createState() =>
      _StudentsStatisticsPageState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
          title: const Text('Tổng hợp điểm danh')),
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
                ElevatedButton.icon(
                  onPressed: fetchFilteredData,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Lọc'),
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
