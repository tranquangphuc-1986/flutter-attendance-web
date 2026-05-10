class TeamModel {
  final String rank;
  final String name;
  final String unit;
  final int score;

  TeamModel({
    required this.rank,
    required this.name,
    required this.unit,
    required this.score,
  });

  // Factory để chuyển đổi dữ liệu thô từ hàng trong Excel
  factory TeamModel.fromExcelRow(List<dynamic> row) {
    return TeamModel(
      // row[index]?.value lấy giá trị ô, ép kiểu về chuỗi hoặc số
      rank: row[0]?.value?.toString() ?? "",
      name: row[1]?.value?.toString() ?? "N/A",
      unit: row[2]?.value?.toString() ?? "",
      score: int.tryParse(row[3]?.value?.toString() ?? "0") ?? 0,
    );
  }
}