import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_02/models/student.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final CollectionReference studentCollection = FirebaseFirestore.instance
      .collection('students');
  final CollectionReference attendanceCollection = FirebaseFirestore.instance
      .collection('attendance');

  Future<void> addStudent(Student student) async {
    await studentCollection.add(student.toMap());
  }

  Future<void> updateData(Student student) async {
    await studentCollection.doc(student.id).update(student.toMap());
  }

  Future<void> deleteData(String id) async {
    try {
      await studentCollection.doc(id).delete();
    } catch (e) {
      print("Lỗi khi xóa dữ liệu: $e");
      rethrow;
    }
  }

  //Lấy danh sách sinh viên từ Firebase dưới dạng Stream
  Future<List<Student>> getStudents() async {
    QuerySnapshot snapshot = await studentCollection.get();
    return snapshot.docs
        .map(
          (doc) => Student.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  //Hàm ghi, truy cập điểm danh theo ngày
  Future<void> markAttendance(
    String studentId,
    String status, {
    String? note,
  }) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(today);
    final attendanceQuery =
        await attendanceCollection
            .where('studentId', isEqualTo: studentId)
            .where('date', isEqualTo: timestampToday)
            .limit(1)
            .get();
    if (attendanceQuery.docs.isNotEmpty) {
      // Cập nhật nếu đã tồn tại
      await attendanceQuery.docs.first.reference.update({
        'status': status,
        'note': note ?? '',
        'updatedAt': Timestamp.now(),
      });
    } else {
      // Tạo mới nếu chưa có
      await attendanceCollection.add({
        'studentId': studentId,
        'status': status,
        'note': note ?? '',
        'date': timestampToday,
        'createdAt': Timestamp.now(),
      });
    }
    //Thời gian điểm danh 13-13h15
    //   final now = TimeOfDay.now();
    // if((now.hour<13||(now.hour==13&&now.hour<0))||
    //     (now.hour>13||(now.hour==13&&now.hour>15)));
    //   return;
  }

  Future<String?> getTodayAttendance(String studentId) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(today);
    final querySnapshot =
        await attendanceCollection
            .where('studentId', isEqualTo: studentId)
            .where('date', isEqualTo: timestampToday)
            .limit(1)
            .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['status'] as String;
    }
    return null;
  }

  //thống kê theo thời gian và tên và đơn vị

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getStudentStatisticsFiltered({
    required DateTime fromDate,
    required DateTime toDate,
    String? className,
    String? nameKeyword,
  }) async {
    List<Map<String, dynamic>> result = [];

    try {
      final attendanceSnapshot =
          await _firestore
              .collection('attendance')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
              .get();

      Map<String, Map<String, dynamic>> statisticsMap = {};
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'];
        final status = data['status'];
        if (!statisticsMap.containsKey(studentId)) {
          statisticsMap[studentId] = {
            'studentId': studentId,
            'present': 0,
            'work': 0,
            'sick': 0,
            'np': 0,
            'dh': 0,
            'vcn': 0,
            'kld': 0,
            'dt': 0,
          };
        }

        if (status == 'Có mặt') {
          statisticsMap[studentId]!['present'] += 1;
        } else if (status == 'Vắng do công tác') {
          statisticsMap[studentId]!['work'] += 1;
        } else if (status == 'Vắng do ốm') {
          statisticsMap[studentId]!['sick'] += 1;
        } else if (status == 'Vắng do nghỉ phép') {
          statisticsMap[studentId]!['np'] += 1;
        } else if (status == 'Vắng do đi học') {
          statisticsMap[studentId]!['dh'] += 1;
        } else if (status == 'Vắng việc cá nhân') {
          statisticsMap[studentId]!['vcn'] += 1;
        } else if (status == 'Vắng không lý do') {
          statisticsMap[studentId]!['kld'] += 1;
        } else {
          statisticsMap[studentId]!['Đi trễ'] += 1;
        }
      }

      // Lấy thông tin sinh viên theo studentId
      for (var stat in statisticsMap.values) {
        final studentDoc =
            await _firestore
                .collection('students')
                .doc(stat['studentId'])
                .get();

        if (!studentDoc.exists) continue;

        final studentData = studentDoc.data()!;
        final studentName = studentData['name']?.toString().toLowerCase() ?? '';
        final studentClass = studentData['className'] ?? '';

        // Lọc theo tên
        if (nameKeyword != null && nameKeyword.isNotEmpty) {
          final keyword = nameKeyword.toLowerCase();
          if (!studentName.contains(keyword)) continue;
        }

        // Lọc theo lớp
        if (className != null &&
            className.isNotEmpty &&
            studentClass != className) {
          continue;
        }

        result.add({
          'studentId': stat['studentId'],
          'name': studentData['name'],
          'className': studentClass,
          'present': stat['present'],
          'work': stat['work'],
          'sick': stat['sick'],
          'np': stat['np'],
          'dh': stat['dh'],
          'vcn': stat['vcn'],
          'kld': stat['kld'],
          'dt': stat['dt'],
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }

    return result;
  }
}
