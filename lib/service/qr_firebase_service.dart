// import 'package:app_02/models/police.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirebaseService {
//   final CollectionReference policeCollection = FirebaseFirestore.instance
//       .collection('userLogin');
//   final CollectionReference attendanceCollectionQr = FirebaseFirestore.instance
//       .collection('attendanceqr');
//
//   Future<void> addPolice(Police police, String uid) async {
//     await policeCollection.doc(uid).set(police.toMap());
//   }
//
//   Future<void> updateData(Police police) async {
//     await policeCollection.doc(police.id).update(police.toMap());
//   }
//
//   Future<void> deleteData(String id) async {
//     try {
//       await policeCollection.doc(id).delete();
//     } catch (e) {
//       print("Lỗi khi xóa dữ liệu: $e");
//       rethrow;
//     }
//   }
//
//   //Lấy danh sách dưới dạng Stream
//   Stream<List<Police>> getPolice() {
//     return policeCollection.snapshots().map((snapshot) {
//       return snapshot.docs
//           .map(
//             (doc) =>
//             Police.fromMap(doc.id, doc.data() as Map<String, dynamic>),
//       )
//           .toList();
//     });
//   }
// //Lấy danh sách dưới dạng List
//   Future<List<Police>> fetchPolice() async {
//     QuerySnapshot snapshot = await policeCollection.get();
//     return snapshot.docs
//         .map((doc) => Police.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
//         .toList();
//   }
//   // 🔍 Tìm user theo email
//   Future<Police?> getUserByEmail(String email) async {
//     final snapshot =
//     await policeCollection.where('email', isEqualTo: email).limit(1).get();
//     if (snapshot.docs.isNotEmpty) {
//       final doc = snapshot.docs.first;
//       return Police.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//     }
//     return null;
//   }
//
//
//   Future<void> markAttendanceQr(String phone, String status) async {
//     // final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     DateTime now = DateTime.now();
//     DateTime today = DateTime(now.year, now.month, now.day);
//     Timestamp timestampToday = Timestamp.fromDate(today);
//     await attendanceCollectionQr.doc('$today-$phone').set({
//       'phone': phone,
//       'status': status,
//       'date': timestampToday,
//     });
//    }
//
//   Stream<Map<String, String>> getTodayAttendanceQr() {
//     DateTime now = DateTime.now();
//     DateTime today = DateTime(now.year, now.month, now.day);
//     Timestamp timestampToday = Timestamp.fromDate(today);
//     return attendanceCollectionQr
//         .where('date', isEqualTo: timestampToday)
//         .snapshots()
//         .map(
//           (snapshot) => {
//         for (var doc in snapshot.docs)
//           doc['phone']: doc['status'] as String,
//       },
//     );
//   }
//
//   Future<String?> getTodayAttendanceFutureQr (String phone) async {
//     DateTime now = DateTime.now();
//     DateTime today = DateTime(now.year, now.month, now.day);
//     Timestamp timestampToday = Timestamp.fromDate(today);
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('attendanceqr')
//         .where('phone', isEqualTo: phone)
//         .where('date', isEqualTo: timestampToday)
//         .limit(1)
//         .get();
//     if (querySnapshot.docs.isNotEmpty) {
//       return querySnapshot.docs.first['status'];
//     } else {
//       return null;
//     }
//   }
//
//   //thống kê theo thời gian và tên và đơn vị
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Future<List<Map<String, dynamic>>> getStudentStatisticsFilteredQr({
//     required DateTime fromDate,
//     required DateTime toDate,
//     String? className,
//     String? nameKeyword,
//   }) async {
//     List<Map<String, dynamic>> result = [];
//
//     try {
//       final attendanceSnapshot =
//       await _firestore
//           .collection('attendanceqr')
//           .where(
//         'date',
//         isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
//       )
//           .where('date',
//           isLessThanOrEqualTo: Timestamp.fromDate(toDate))
//           .get();
//
//       Map<String, Map<String, dynamic>> statisticsMap = {};
//       for (var doc in attendanceSnapshot.docs) {
//         final data = doc.data();
//         final phone = data['phone'];
//         final status = data['status'];
//         if (!statisticsMap.containsKey(phone)) {
//           statisticsMap[phone] = {
//             'phone': phone,
//             'present': 0,
//             'work': 0,
//             'sick': 0,
//             'np': 0,
//             'dh': 0,
//             'vcn': 0,
//             'kld': 0,
//             'dt': 0,
//           };
//         }
//
//         if (status == 'Có mặt') {
//           statisticsMap[phone]!['present'] += 1;
//         } else if (status == 'Vắng do công tác') {
//           statisticsMap[phone]!['work'] += 1;
//         } else if (status == 'Vắng mặt') {
//           statisticsMap[phone]!['sick'] += 1;
//         } else if (status == 'Nghỉ phép') {
//           statisticsMap[phone]!['np'] += 1;
//         } else if (status == 'Vắng do đi học') {
//           statisticsMap[phone]!['dh'] += 1;
//         } else if (status == 'Vắng việc cá nhân') {
//           statisticsMap[phone]!['vcn'] += 1;
//         } else if (status == 'Vắng không lý do') {
//           statisticsMap[phone]!['kld'] += 1;
//         } else {
//           statisticsMap[phone]!['dt'] += 1;
//         }
//       }
//
//       // Lấy thông tin sinh viên theo phone
//       for (var stat in statisticsMap.values) {
//         final policeDoc =
//         await _firestore
//             .collection('userLogin')
//             .doc(stat['phone'])
//             .get();
//
//         if (!policeDoc.exists) continue;
//
//         final policeData = policeDoc.data()!;
//         final policeName = policeData['name']?.toString().toLowerCase() ?? '';
//         final policeClass = policeData['email'] ?? '';
//
//         // Lọc theo tên
//         if (nameKeyword != null && nameKeyword.isNotEmpty) {
//           final keyword = nameKeyword.toLowerCase();
//           if (!policeName.contains(keyword)) continue;
//         }
//
//         // Lọc theo lớp
//         if (className != null &&
//             className.isNotEmpty &&
//             policeClass != className) {
//           continue;
//         }
//         result.add({
//           'phone': stat['phone'],
//           'name': policeData['name'],
//           'email': policeClass,
//           'present': stat['present'],
//           'work': stat['work'],
//           'sick': stat['sick'],
//           'np': stat['np'],
//           'dh': stat['dh'],
//           'vcn': stat['vcn'],
//           'kld': stat['kld'],
//           'dt': stat['dt'],
//         });
//       }
//     } catch (e) {
//       print('Error loading statistics: $e');
//     }
//     return result;
//   }
//
// }
