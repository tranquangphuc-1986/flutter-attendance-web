import 'package:cloud_firestore/cloud_firestore.dart';

class Police {
  final String id;
  final String name;
  final String phone;
  final String className;
  final String email;
  final String password;
  final String role;
  final int score;
  Police({
    required this.id,
    required this.name,
    required this.phone,
    required this.className,
    required this.email,
    required this.password,
    required this.role,
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
      'score': score,
    };
  }
  // Tạo Student từ Map (lấy từ Firestore)
  factory Police.fromMap(String id, Map<String, dynamic> map) {
    return Police(
      id: id,
      name: map['name'],
      phone: map['phone'],
      className: map['className'],
      email: map['email'],
      password: map['password'],
      role: map['role'],

    );
  }
//lấy toàn bộ danh sách sinh viêm từ collection ('userLogin') trong firestore - dạng list
  factory Police.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Police(
      id: doc.id,
      name: data['name'],
      phone: data['phone'],
      className: data['className'],
      email: data['email'],
      password: data['password'],
      role: data['role'],
    );
  }
}