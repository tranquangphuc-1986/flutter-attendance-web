import 'package:app_02/Service/students_firebase_service.dart';
import 'package:app_02/check/attendance_screen1.dart';
import 'package:app_02/student_screens/students_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_02/models/student.dart';


class SummaryScreen1 extends StatelessWidget {
   const SummaryScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
          title: const Text("Tổng hợp điểm danh hôm nay"),
      automaticallyImplyLeading: false,),
      body: StreamBuilder<List<Student>>(
        stream: service.getStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data!;
          return StreamBuilder<Map<String, String>>(
            stream: service.getTodayAttendance(),
            builder: (context, attSnapshot) {
              if (!attSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              final attendance = attSnapshot.data!;
              return ListView(
                children: students.map((s) {
                  final status = attendance[s.id] ?? "Chưa điểm danh";
                  return ListTile(
                    title: Text(s.name),
                    subtitle: Text("Lớp: ${s.className}"),
                    trailing: Text(status),
                  );
                }).toList(),
              );
            },
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "attendance",
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceScreen1()),
            ),
            child: const Icon(Icons.how_to_reg),
            tooltip: "Điểm danh",
          ),
          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "Danh sách",
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentsListScreen()),
            ),
            child: const Icon(Icons.list),
            tooltip: "Danh sách",
          ),
        ],
      ),
    );
  }
}