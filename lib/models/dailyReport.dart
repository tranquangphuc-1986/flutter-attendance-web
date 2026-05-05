import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport {
  final String id;
  final DateTime reportTime;
  final String content;
  final Timestamp createdAt;
  final String fullName;
  DailyReport({
    required this.id,
    required this.reportTime,
    required this.content,
    required this.createdAt,
    required this.fullName});

  //Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'reportTime': reportTime,
      'content': content,
      'createdAt': createdAt,
      'fullName': fullName,
    };
  }
  // Tạo Report từ Map (lấy từ Firestore)
  factory DailyReport.fromMap(String id, Map<String, dynamic> map) {
    return DailyReport(
      id: id,
      reportTime: map['reportTime'],
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
      reportTime: data['reportTime'],
      content: data['content'],
      createdAt: data['createdAt'],
      fullName: data['fullName'],
    );
  }
}