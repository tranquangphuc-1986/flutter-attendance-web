import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> previewData = [];

  Future<void> pickAndImportExcel() async {
    try {
      setState(() => isLoading = true);

      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (picked == null) {
        setState(() => isLoading = false);
        return;
      }

      final bytes = picked.files.single.bytes;
      if (bytes == null) throw Exception("Không đọc được file");

      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) throw Exception("Sheet trống");

      previewData.clear();

      String safeCell(dynamic cell) {
        if (cell == null) return "";
        return cell.value.toString().trim();
      }

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);

        String name = safeCell(row[0]);
        String unit = safeCell(row[1]);
        String phone = safeCell(row[2]);

        if (name.isEmpty || unit.isEmpty || phone.isEmpty) continue;

        previewData.add({
          "name": name,
          "unit": unit,
          "phone": phone,
        });
      }

      setState(() {});

      await uploadToFirebase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> uploadToFirebase() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    final col = FirebaseFirestore.instance.collection('cax');

    for (var item in previewData) {
      final doc = col.doc();
      batch.set(doc, item);
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nhập dữ liệu thành công!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nhập Excel lên Firebase"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
            ElevatedButton(
            onPressed: isLoading ? null : pickAndImportExcel,
              child: const Text("Chọn file Excel và nhập dữ liệu"),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
    if (previewData.isNotEmpty)
    Expanded(
      child: ListView.builder(
        itemCount: previewData.length,
        itemBuilder: (context, index) {
          final item = previewData[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(item['name']),
            subtitle: Text(
              "Đơn vị: ${item['unit']}\nSDT: ${item['phone']}",
            ),
          );
        },
      ),
    ),
              ],
            ),
        ),
    );
  }
}