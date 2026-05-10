import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

Future<List<Map<String, dynamic>>> parseExcelToLeaderboard() async {
  List<Map<String, dynamic>> excelData = [];

  // 1. Cho phép người dùng chọn file từ thiết bị
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
  );

  if (result != null) {
    var bytes = File(result.files.single.path!).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // 2. Lặp qua từng Sheet (thông thường lấy sheet đầu tiên)
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      // 3. Lặp qua các hàng dữ liệu (bỏ qua hàng tiêu đề index = 0)
      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];

        // Tạo map khớp với cấu trúc biểu đồ đã thiết kế
        excelData.add({
          "rank": row[0]?.value.toString() ?? "",
          "name": row[1]?.value.toString() ?? "",
          "unit": row[2]?.value.toString() ?? "",
          "score": int.tryParse(row[3]?.value.toString() ?? "0") ?? 0,
        });
      }
      break; // Chỉ lấy sheet đầu tiên rồi dừng
    }
  }

  return excelData;
}