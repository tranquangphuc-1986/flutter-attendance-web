import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport {
  final String id;
  final String title;
  final String content;
  final Timestamp createdAt;
  final String fullName;
  DailyReport({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.fullName});

  //Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'fullName': fullName,
    };
  }
  // Tạo Report từ Map (lấy từ Firestore)
  factory DailyReport.fromMap(String id, Map<String, dynamic> map) {
    return DailyReport(
      id: id,
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
      fullName: map['fullName'],
    );
  }
//lấy toàn bộ danh sách report từ collection ('dailyReport') trong firestore - dạng list
  factory DailyReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DailyReport(
      id: doc.id,
      title: data['title'],
      content: data['content'],
      createdAt: data['createdAt'],
      fullName: data['fullName'],
    );
  }
}