import 'package:flutter/material.dart';

class CyberLeaderboard extends StatelessWidget {
  // Dữ liệu mẫu (Bạn có thể parse từ file Excel trên vào đây)
  // final List<Map<String, dynamic>> teams = [
  //   {"rank": "01", "name": "Cyb3r_Gu4rdians", "unit": "T07", "score": 986},
  //   {"rank": "02", "name": "The Wings of Seagulls", "unit": "PA05 Hải Phòng", "score": 885},
  //   {"rank": "03", "name": "Aegis IV", "unit": "PA05 Tuyên Quang", "score": 879},
  //   {"rank": "04", "name": "r00t_m4st3r", "unit": "T07", "score": 819},
  //   {"rank": "05", "name": "C500_TDĐQ", "unit": "T01", "score": 806},
  //   {"rank": "06", "name": "PSA_sudo", "unit": "T01", "score": 806},
  //   {"rank": "07", "name": "Bắc Ninh", "unit": "PA05 Bắc Ninh", "score": 786},
  //   // ... thêm các đội khác
  // ];
  final List<Map<String, dynamic>> teams = [
  {"rank": "1", "unit": "Xã la Tơi", "acreage": 762.1},
  {"rank": "2", "unit": "Xã Mô Rai", "acreage": 583.92},
  {"rank": "3", "unit": "Xã Kon Plông", "acreage": 556.8},
  {"rank": "4", "unit": "Xã Đăk Kôi", "acreage": 450.48},
  {"rank": "5", "unit": "Xã Đăk Plô", "acreage": 433.41},
  {"rank": "6", "unit": "Xã Măng Bút", "acreage": 417.53},
  {"rank": "7", "unit": "Xã Măng Ri", "acreage": 401.18},
  {"rank": "8", "unit": "Xã Măng Đen", "acreage": 396.93},
  {"rank": "9", "unit": "Xã Đăk Pxi", "acreage": 325.35},
  {"rank": "10", "unit": "Xã Dục Nông", "acreage": 321.99},
  {"rank": "11", "unit": "Xã Rờ Kơi", "acreage": 298.29},
  {"rank": "12", "unit": "Xã Đăk Long", "acreage": 280.5},
  {"rank": "13", "unit": "Xã Sa Loong", "acreage": 275.26},
  {"rank": "14", "unit": "Xã Ba Tô", "acreage": 274.4},
  {"rank": "15", "unit": "Xã Ya Ly", "acreage": 271.31},
  {"rank": "16", "unit": "Xã Xốp", "acreage": 265.86},
  {"rank": "17", "unit": "Xã Kon Braih", "acreage": 250.89},
  {"rank": "18", "unit": "Xã Bờ Y", "acreage": 242.11},
  {"rank": "19", "unit": "Xã Đăk Tô", "acreage": 218.38},
  {"rank": "20", "unit": "Xã la Đal", "acreage": 218.11},
  {"rank": "21", "unit": "Xã Đăk Rve", "acreage": 212.54},
  {"rank": "22", "unit": "Xã Đặng Thùy Trâm", "acreage": 199.4},
  {"rank": "23", "unit": "Xã Sơn Kỳ", "acreage": 188.07},
  {"rank": "24", "unit": "Xã Đăk Pék", "acreage": 182.72},
  {"rank": "25", "unit": "Xã Ngọc Linh", "acreage": 180.35},
  {"rank": "26", "unit": "Xã Đăk Sao", "acreage": 172.29},
  {"rank": "27", "unit": "Xã Tây Trà", "acreage": 170.86},
  {"rank": "28", "unit": "Xã Ngọk Réo", "acreage": 170.29},
  {"rank": "29", "unit": "Xã Sơn Hà", "acreage": 163.44},
  {"rank": "30", "unit": "Xã Ngọk Tụ", "acreage": 160.97},
  {"rank": "31", "unit": "Xã Đăk Rơ Wa", "acreage": 157.98},
  {"rank": "32", "unit": "Xã Sơn Hạ", "acreage": 154.29},
  {"rank": "33", "unit": "Xã Tu Mơ Rông", "acreage": 152.13},
  {"rank": "34", "unit": "Xã Đăk Môn", "acreage": 150.8},
  {"rank": "35", "unit": "Xã Sa Bình", "acreage": 140.32},
  {"rank": "36", "unit": "Xã Trà Bồng", "acreage": 139.43},
  {"rank": "37", "unit": "Xã Sa Thầy", "acreage": 137.89},
  {"rank": "38", "unit": "Xã Sơn Tây Hạ", "acreage": 136.15},
  {"rank": "39", "unit": "Xã Thanh Bồng", "acreage": 133.88},
  {"rank": "40", "unit": "Xã Đăk Ui", "acreage": 132.52},
  {"rank": "41", "unit": "Xã Đăk Tờ Kan", "acreage": 131.84},
  {"rank": "42", "unit": "Xã Kon Đào", "acreage": 129.34},
  {"rank": "43", "unit": "Xã Tây Trà Bồng", "acreage": 129.05},
  {"rank": "44", "unit": "Xã Bình Minh", "acreage": 128.6},
  {"rank": "45", "unit": "Xã Sơn Tây", "acreage": 127.06},
  {"rank": "46", "unit": "Xã Sơn Linh", "acreage": 126.7},
  {"rank": "47", "unit": "Xã Ba Vì", "acreage": 125.4},
  {"rank": "48", "unit": "Xã Minh Long", "acreage": 124.74},
  {"rank": "49", "unit": "Xã Sơn Tây Thượng", "acreage": 122.43},
  {"rank": "50", "unit": "Xã Ba Tơ", "acreage": 120.91},
  {"rank": "51", "unit": "Xã Đông Sơn", "acreage": 115.83},
  {"rank": "52", "unit": "Xã la Chim", "acreage": 115.49},
  {"rank": "53", "unit": "Xã Ba Vinh", "acreage": 115},
  {"rank": "54", "unit": "Xã Đăk Mar", "acreage": 112.79},
  {"rank": "55", "unit": "Xã Sơn Mai", "acreage": 112.56},
  {"rank": "56", "unit": "Xã Cà Đam", "acreage": 112.35},
  {"rank": "57", "unit": "Xã Vạn Tường", "acreage": 109.28},
  {"rank": "58", "unit": "Xã Đăk Hà", "acreage": 104.08},
  {"rank": "59", "unit": "Xã Khánh Cường", "acreage": 103.98},
  {"rank": "60", "unit": "Xã Ba Động", "acreage": 103.01},
  {"rank": "61", "unit": "Xã Ba Xa", "acreage": 102.79},
  {"rank": "62", "unit": "Xã Bình Sơn", "acreage": 100.07},
  {"rank": "63", "unit": "Xã Thiện Tín", "acreage": 99.1},
  {"rank": "64", "unit": "Xã Ba Dinh", "acreage": 97.05},
  {"rank": "65", "unit": "Xã Sơn Thủy", "acreage": 95.77},
  {"rank": "66", "unit": "Xã Nguyễn Nghiêm", "acreage": 95.33},
  {"rank": "67", "unit": "Xã Trà Giang", "acreage": 91.72},
  {"rank": "68", "unit": "Xã Mộ Đức", "acreage": 76.17},
  {"rank": "69", "unit": "Xã Đông Trà Bồng", "acreage": 74.83},
  {"rank": "70", "unit": "Phường Đức Phổ", "acreage": 69.33},
  {"rank": "71", "unit": "Xã Thọ Phong", "acreage": 66.64},
  {"rank": "72", "unit": "Phường Đăk Cấm", "acreage": 66.33},
  {"rank": "73", "unit": "Xã Ba Gia", "acreage": 66.14},
  {"rank": "74", "unit": "Xã Ngọk Bay", "acreage": 62.09},
  {"rank": "75", "unit": "Xã Sơn Tịnh", "acreage": 59.78},
  {"rank": "76", "unit": "Xã Phước Giang", "acreage": 57.02},
  {"rank": "77", "unit": "Xã Lân Phong", "acreage": 57.01},
  {"rank": "78", "unit": "Phường Trà Câu", "acreage": 54.46},
  {"rank": "79", "unit": "Xã Đình Cương", "acreage": 53.96},
  {"rank": "80", "unit": "Xã Trường Giang", "acreage": 51.3},
  {"rank": "81", "unit": "Phường Sa Huỳnh", "acreage": 49.95},
  {"rank": "82", "unit": "Xã Nghĩa Giang", "acreage": 47.74},
  {"rank": "83", "unit": "Xã Tịnh Khê", "acreage": 46.05},
  {"rank": "84", "unit": "Xã Mỏ Cày", "acreage": 44.8},
  {"rank": "85", "unit": "Xã Tư Nghĩa", "acreage": 41.93},
  {"rank": "86", "unit": "Xã Long Phụng", "acreage": 36.1},
  {"rank": "87", "unit": "Phường Trương Quang Trọng", "acreage": 34.65},
  {"rank": "88", "unit": "Xã An Phú", "acreage": 33.93},
  {"rank": "89", "unit": "Xã Bình Chương", "acreage": 30.79},
  {"rank": "90", "unit": "Xã Nghĩa Hành", "acreage": 24.4},
  {"rank": "91", "unit": "Xã Vệ Giang", "acreage": 24.21},
  {"rank": "92", "unit": "Phường Kon Tum", "acreage": 19.14},
  {"rank": "93", "unit": "Phường Nghĩa Lộ", "acreage": 17.07},
  {"rank": "94", "unit": "Phường Đăk Bla", "acreage": 14.99},
  {"rank": "95", "unit": "Đặc khu Lý Sơn", "acreage": 10.4},
  {"rank": "96", "unit": "Phường Cẩm Thành", "acreage": 7.93},];


  final double maxAcreage = 762.1; // Giả định điểm tối đa để tính tỷ lệ thanh progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D21), // Màu nền tối giống trong ảnh
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("DIỆN TÍCH TỰ NHIÊN",
            style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return _buildLeaderboardItem(team);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("THỨ TỰ / ĐƠN VỊ", style: TextStyle(color: Colors.white, fontSize: 12)),
          Text("DIỆN TÍCH (Km2)", style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> team) {
    double progressWidth = team['acreage'] / maxAcreage; // Tính % thanh xanh

    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), // Nền mờ của hàng
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
            children: [
            // 1. Thanh Progress (Màu xanh neon mờ lồng bên dưới)
            FractionallySizedBox(
            widthFactor: progressWidth,
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(right: BorderSide(color: Colors.cyan, width: 2)),
                ),
            ),
            ),
              // 2. Nội dung text đè lên trên
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      team['rank'],
                      style: TextStyle(
                        color: _getRankColor(team['rank']),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            // TextSpan(
                            //   text: "${team['name']} ",
                            //   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            // ),
                            TextSpan(
                              text: "(${team['unit']})",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "${team['acreage']}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
        ),
    );
  }

  Color _getRankColor(String rank) {
    if (rank == "1") return Colors.green;
    if (rank == "2") return Colors.yellowAccent;
    if (rank == "3") return Colors.orange;
    if (rank == "4") return Colors.redAccent;
    if (rank == "5") return Colors.cyanAccent;
    if (rank == "6") return Colors.pinkAccent;
    if (rank == "7") return Colors.purpleAccent;
    if (rank == "8") return Colors.white;
    if (rank == "9") return Colors.teal;
    if (rank == "10") return Colors.brown;
    return Colors.blueAccent;
  }
}