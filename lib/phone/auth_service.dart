import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Tạo email ảo từ số điện thoại
  String _phoneToEmail(String phone) {
    // Chuẩn hóa đầu số (ví dụ 090 → +8490)
    if (phone.startsWith("0")) {
      phone = "+84${phone.substring(1)}";
    }
    return "$phone@phone.myapp";
  }

  /// Đăng ký bằng SĐT + password
  Future<String?> signup({
    required String phone,
    required String password,
  }) async {
    try {
      final email = _phoneToEmail(phone);

      // Tạo user Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Lưu thông tin vào Firestore
      await _db.collection("users_phone").doc(uid).set({
        "uid": uid,
        "phone": phone,
        "emailAlias": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Đăng nhập bằng SĐT + password
  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final email = _phoneToEmail(phone);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> logout() => _auth.signOut();
}
