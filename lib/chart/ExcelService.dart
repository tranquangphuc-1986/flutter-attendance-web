import 'dart:io';
import 'package:app_02/chart/TeamModel.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb

class ExcelService {
  static Future<List<TeamModel>> pickAndParseExcel() async {
    List<TeamModel> teams = [];

    try {
      // 1. Mở trình chọn file (chỉ lọc file excel)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Quan trọng để đọc được byte file
      );

      if (result != null) {
        var bytes = result.files.single.bytes;

        // Nếu chạy trên Mobile/Desktop, đôi khi phải đọc từ Path nếu bytes null
        if (bytes == null && result.files.single.path != null) {
          bytes = File(result.files.single.path!).readAsBytesSync();
        }

        if (bytes != null) {
          // 2. Decode file Excel
          var excel = Excel.decodeBytes(bytes);

          // 3. Lấy dữ liệu từ Sheet đầu tiên
          for (var table in excel.tables.keys) {
            var sheet = excel.tables[table];
            if (sheet == null) continue;

            // Bỏ qua hàng 0 (Header), bắt đầu từ hàng 1
            for (int i = 1; i < sheet.maxRows; i++) {
              var row = sheet.rows[i];

              // Kiểm tra nếu hàng có dữ liệu (không bị null hết cả hàng)
              if (row.any((cell) => cell?.value != null)) {
                teams.add(TeamModel.fromExcelRow(row));
              }
            }
            // Chỉ đọc sheet đầu tiên rồi thoát
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi khi parse Excel: $e");
    }

    return teams;
  }
}