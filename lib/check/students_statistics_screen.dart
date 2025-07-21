import 'package:app_02/student_screens/students_add_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class StudentStatisticsScreen extends StatefulWidget {
  const StudentStatisticsScreen({Key? key}) : super(key: key);

  @override
  _StudentStatisticsScreenState createState() =>
      _StudentStatisticsScreenState();
}
bool _isloading = false;
class _StudentStatisticsScreenState extends State<StudentStatisticsScreen> {
  List<Map<String, dynamic>> students = [];
  String selectedClass = 'Tất cả';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isloading=true;
    });
    final snapshot =
        await FirebaseFirestore.instance.collection('students').get();

    final List<Map<String, dynamic>> loadedStudents = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final attendanceSnapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('studentId', isEqualTo: doc.id)
              .get();

      int present = 0;
      int sick = 0;
      int work = 0;
      int np = 0;
      int dh = 0;
      int vcn = 0;
      int kld = 0;
      int dt = 0;

      for (var record in attendanceSnapshot.docs) {
        final status = record['status'];
        if (status == 'Có mặt') present++;
        if (status == 'Vắng do ốm') sick++;
        if (status == 'Vắng do công tác') work++;

        if (status == 'Vắng do nghỉ phép') np++;
        if (status == 'Vắng do đi học') dh++;
        if (status == 'Vắng việc cá nhân') vcn++;
        if (status == 'Vắng không lý do') kld++;
        if (status == 'Đi trễ') dt++;
      }

      loadedStudents.add({
        'id': doc.id,
        'name': data['name'],
        'className': data['className'],
        'present': present,
        'sick': sick,
        'work': work,
        'np': np,
        'dh': dh,
        'vcn': vcn,
        'kld': kld,
        'dt': dt,
      });
    }
    setState(() {
      students = loadedStudents;
      _isloading=false;
    });
  }

  Widget buildStatusIcon(String status) {
    switch (status) {
      case 'Có mặt':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Vắng do ốm':
        return const Icon(Icons.healing, color: Colors.orange);
      case 'Vắng do công tác':
        return const Icon(Icons.work, color: Colors.orange);

      case "Vắng do nghỉ phép":
        return const Icon(Icons.book_outlined, color: Colors.orange);
      case "Vắng do đi học":
        return const Icon(Icons.edit_outlined, color: Colors.orange);
      case "Vắng việc cá nhân":
        return const Icon(Icons.person, color: Colors.yellow);
      case "Vắng không lý do":
        return const Icon(Icons.close, color: Colors.red);
      case "Đi trễ":
        return const Icon(Icons.hourglass_bottom, color: Colors.red);

      default:
        return const Icon(Icons.help_outline);
    }
  }

  List<String> getAllClasses() {
    final Set<String> classes = {'Tất cả'};
    for (var student in students) {
      classes.add(student['className']);
    }
    return classes.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents =
        selectedClass == 'Tất cả'
            ? students
            : students.where((s) => s['className'] == selectedClass).toList();

    // int totalPresent = filteredStudents.fold(0,(sum, s) => sum + (s['present'] as int),
    // );
    // int totalSick = filteredStudents.fold(0,(sum, s) => sum + (s['sick'] as int),
    // );
    // int totalWork = filteredStudents.fold(0, (sum, s) => sum + (s['work'] as int),
    // );
    // int totalnp = filteredStudents.fold(0, (sum, s) => sum + (s['np'] as int),
    // );
    // int totaldh = filteredStudents.fold(0, (sum, s) => sum + (s['dh'] as int),
    // );
    // int totalvcn = filteredStudents.fold(0, (sum, s) => sum + (s['vcn'] as int),
    // );
    // int totalkld = filteredStudents.fold(0, (sum, s) => sum + (s['kld'] as int),
    // );
    // int totaldt = filteredStudents.fold(0, (sum, s) => sum + (s['dt'] as int));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thống kê tổng hợp'),
        backgroundColor: Colors.cyan,
        actions: [
          DropdownButton<String>(
            icon: Icon(Icons.search, color: Colors.white),
            value: selectedClass,
            underline: const SizedBox(),
            onChanged: (value) {
              setState(() {
                selectedClass = value!;
              });
            },
            items:
                getAllClasses()
                    .map(
                      (cls) => DropdownMenuItem(value: cls, child: Text(cls)),
                    )
                    .toList(),
          ),
        ],
      ),
      body: _isloading
      ? Center(child: CircularProgressIndicator(color: Colors.blue,),)
      : Column(

        children: [
          // Container(
          //   margin: const EdgeInsets.all(10),
          //   color: Colors.blue.shade100,
          //   child: ListTile(
          //     leading: const Icon(Icons.bar_chart, color: Colors.blue),
          //     title: Text('Tổng quan'),
          //     subtitle: Text(
          //       'Có mặt: $totalPresent | Công tác: $totalWork | Ốm: $totalSick | '
          //       'Nghỉ phép: $totalnp | Đi học: $totaldh | '
          //       'Việc cá nhân: $totalvcn | Không lý do: $totalkld | Đi trễ: $totaldt',
          //     ),
          //   ),
          // ),
          SizedBox(height: 40,),
          Expanded(
            child: ListView.separated(
              itemCount: filteredStudents.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Card(
                  child: ListTile(
                    title: Text('${student['name']} (${student['className']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildStatusIcon('Có mặt'),
                            const SizedBox(width: 4),
                            Text('Có mặt: ${student['present']}'),
                            const SizedBox(width: 10),
                            buildStatusIcon('Vắng do công tác'),
                            const SizedBox(width: 4),
                            Text('Công tác: ${student['work']}'),
                            const SizedBox(width: 10),
                            buildStatusIcon('Vắng do ốm'),
                            const SizedBox(width: 4),
                            Text('Ốm: ${student['sick']}'),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            buildStatusIcon('Vắng do nghỉ phép'),
                            const SizedBox(width: 4),
                            Text('Nghỉ phép: ${student['np']}'),
                            const SizedBox(width: 10),
                            buildStatusIcon('Vắng do đi học'),
                            const SizedBox(width: 4),
                            Text('Đi học: ${student['dh']}'),
                            const SizedBox(width: 10),
                            buildStatusIcon('Đi trễ'),
                            const SizedBox(width: 4),
                            Text('Đi trễ: ${student['dt']}'),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            buildStatusIcon('Vắng việc cá nhân'),
                            const SizedBox(width: 4),
                            Text('Việc cá nhân: ${student['vcn']}'),
                            const SizedBox(width: 10),
                            buildStatusIcon('Vắng không lý do'),
                            const SizedBox(width: 4),
                            Text('Không lý do: ${student['kld']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
                  MaterialPageRoute(builder: (_) => const AddNewstudens()),
                ),
            child: const Icon(Icons.add),
            tooltip: "Tổng hợp",
          ),
        ],
      ),
    );
  }
}
