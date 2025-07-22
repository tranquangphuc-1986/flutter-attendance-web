import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String phone;
  final String className;
  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.className});

  //Chuyển Student thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'className': className,
    };
  }
  // Tạo Student từ Map (lấy từ Firestore)
  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id,
      name: map['name'],
      phone: map['phone'],
      className: map['className'],
    );
  }
//lấy toàn bộ danh sách sinh viêm từ collection ('student') trong firestore - dạng list
  factory Student.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Student(
      id: doc.id,
      name: data['name'],
      phone: data['phone'],
      className: data['className'],
    );
  }
}