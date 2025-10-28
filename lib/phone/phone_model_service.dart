import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ============================================================
/// 🧩 MODEL: UserModel
/// ============================================================
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String className;
  final String email;
  final String password;
  final String role;
  final String uid;
  final int score;
  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.className,
    required this.email,
    required this.password,
    required this.role,
    required this.uid,
    this.score = 0,
  });

  //Chuyển Student thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'className': className,
      'email': email,
      'password': password,
      'role': role,
      'uid': uid,
      'score': score,
    };
  }
  // Tạo Student từ Map (lấy từ Firestore)
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      className: map['className'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      uid: map['uid'] ?? '',
      score: map['score'] ?? 0,
    );
  }
//lấy toàn bộ danh sách sinh viêm từ collection ('userLogin') trong firestore - dạng list
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'],
      phone: data['phone'],
      className: data['className'],
      email: data['email'],
      password: data['password'],
      role: data['role'],
      uid: data['uid'],
      score: data['score'],
    );
  }
}

/// ============================================================
/// 🧩 SERVICE: FirebaseUserService (CRUD Firestore)
/// ============================================================
class FirebaseUserService {
  final CollectionReference userCollection =  FirebaseFirestore.instance.collection('userLogin');
  final CollectionReference attendanceCollectionQr = FirebaseFirestore.instance.collection('attendanceqr');

  // ➕ Thêm user (sử dụng UID tạo bởi FirebaseAuth)
  Future<void> addUser(UserModel user) async {
    await userCollection.doc(user.uid).set(user.toMap());
  }

  // 🔁 Cập nhật user
  Future<void> updateUser(UserModel user) async {
    if (user.uid.isEmpty) throw Exception("UID không được để trống");
   // if (user.id.isEmpty) throw Exception("User ID không được để trống");
    await userCollection.doc(user.uid).update(user.toMap());
  }

  // ❌ Xóa user
  Future<void> deleteUser(String id) async {
    try {
      await userCollection.doc(id).delete();
    } catch (e) {
      print("Lỗi khi xóa user: $e");
      rethrow;
    }
  }

  // 📡 Lấy danh sách user dạng Stream
  Stream<List<UserModel>> getAllUsersStream() {
    return userCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
          UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  //Lấy danh sách dưới dạng List
  Future<List<UserModel>> getAllUsersList() async {
    QuerySnapshot snapshot = await userCollection.get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // 🔍 Lấy user theo email
  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot =
    await userCollection.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 🛠️ Cập nhật mật khẩu
  Future<void> updatePassword(String email, String newPassword) async {
    final snapshot =
    await userCollection.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await userCollection.doc(docId).update({'password': newPassword});
    }
  }

  Future<void> markAttendanceQr(String phone, String status) async {
    // final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(today);
    await attendanceCollectionQr.doc('$today-$phone').set({
      'phone': phone,
      'status': status,
      'timestamp': timestampToday,
    });
  }

  Stream<Map<String, String>> getTodayAttendanceQr() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(today);
    return attendanceCollectionQr
        .where('timestamp', isEqualTo: timestampToday)
        .snapshots()
        .map(
          (snapshot) => {
        for (var doc in snapshot.docs)
          doc['phone']: doc['status'] as String,
      },
    );
  }

  Future<String?> getTodayAttendanceFutureQr (String phone) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Timestamp timestampToday = Timestamp.fromDate(today);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('attendanceqr')
        .where('timestamp', isEqualTo: phone)
        .where('date', isEqualTo: timestampToday)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['status'];
    } else {
      return null;
    }
  }

  //thống kê theo thời gian và tên và đơn vị
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getStudentStatisticsFilteredQr({
    required DateTime fromDate,
    required DateTime toDate,
    String? className,
    String? nameKeyword,
  }) async {
    List<Map<String, dynamic>> result = [];

    try {
      final attendanceSnapshot =
      await _firestore
          .collection('attendanceqr')
          .where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
      )
          .where('timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(toDate))
          .get();

      Map<String, Map<String, dynamic>> statisticsMap = {};
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final phone = data['phone'];
        final status = data['status'];
        if (!statisticsMap.containsKey(phone)) {
          statisticsMap[phone] = {
            'phone': phone,
            'present': 0,
            'work': 0,
            'sick': 0,
            'np': 0,
            'dh': 0,
            'vcn': 0,
            'cdd': 0,
            'dt': 0,
          };
        }

        if (status == 'Có mặt') {
          statisticsMap[phone]!['present'] += 1;
        } else if (status == 'Công tác') {
          statisticsMap[phone]!['work'] += 1;
        } else if (status == 'Bị ốm') {
          statisticsMap[phone]!['sick'] += 1;
        } else if (status == 'Nghỉ phép') {
          statisticsMap[phone]!['np'] += 1;
        } else if (status == 'Đi học') {
          statisticsMap[phone]!['dh'] += 1;
        } else if (status == 'Việc riêng') {
          statisticsMap[phone]!['vcn'] += 1;
        } else if (status == 'Chưa điểm danh') {
          statisticsMap[phone]!['cdd'] += 1;
        } else {
          statisticsMap[phone]!['dt'] += 1;
        }
      }

      // Lấy thông tin sinh viên theo phone
      for (var stat in statisticsMap.values) {
        final policeDoc =
        await _firestore
            .collection('userLogin')
            .doc(stat['phone'])
            .get();

        if (!policeDoc.exists) continue;

        final policeData = policeDoc.data()!;
        final policeName = policeData['name']?.toString().toLowerCase() ?? '';
        final policeClass = policeData['className'] ?? '';

        // Lọc theo tên
        if (nameKeyword != null && nameKeyword.isNotEmpty) {
          final keyword = nameKeyword.toLowerCase();
          if (!policeName.contains(keyword)) continue;
        }

        // Lọc theo lớp
        if (className != null &&
            className.isNotEmpty &&
            policeClass != className) {
          continue;
        }
        result.add({
          'phone': stat['phone'],
          'name': policeData['name'],
          'className': policeClass,
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

/// ============================================================
/// 🧩 SERVICE: AuthService (FirebaseAuth logic)
/// ============================================================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUserService _userService = FirebaseUserService();

  // 🟩 Đăng ký tài khoản
  Future<String> signUpUser(UserModel user) async {
    String res = "Lỗi";
    try {
      if (user.email.isNotEmpty &&
          user.password.isNotEmpty &&
          user.name.isNotEmpty &&
          user.className.isNotEmpty &&
          user.phone.isNotEmpty &&
          user.role.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: user.email,
          password: user.password,
        );

        final registeredUser = UserModel(
          id: '',
          uid: credential.user!.uid,
          name: user.name,
          className: user.className,
          email: user.email,
          phone: user.phone,
          role: user.role,
          password: user.password,
          score: user.score,
        );

        await _userService.addUser(registeredUser);
        res = "Thành công";
      } else {
        res = "Thiếu thông tin";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // 🟨 Đăng nhập
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Lỗi";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "Thành công";
      } else {
        res = "Thiếu thông tin";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // 🟥 Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
