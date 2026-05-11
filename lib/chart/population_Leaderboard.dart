import 'package:flutter/material.dart';

class PopulationLeaderboard extends StatelessWidget {
  // Dữ liệu mẫu (Bạn có thể parse từ file Excel trên vào đây)
  final List<Map<String, dynamic>> teams = [
    {"rank": "1", "unit": "Xã Bình Sơn", "population": 90109},
    {"rank": "2", "unit": "Phường Kon Tum", "population": 78327},
    {"rank": "3", "unit": "Phường Nghĩa Lộ", "population": 74447},
    {"rank": "4", "unit": "Xã An Phú", "population": 71021},
    {"rank": "5", "unit": "Phường Cẩm Thành", "population": 61559},
    {"rank": "6", "unit": "Xã Vạn Tường", "population": 61275},
    {"rank": "7", "unit": "Xã Tư Nghĩa", "population": 59110},
    {"rank": "8", "unit": "Xã Đông Sơn", "population": 56499},
    {"rank": "9", "unit": "Xã Tịnh Khê", "population": 55956},
    {"rank": "10", "unit": "Phường Trương Quang Trọng", "population": 50315},
    {"rank": "11", "unit": "Phường Trà Câu", "population": 45027},
    {"rank": "12", "unit": "Xã Sơn Tịnh", "population": 42422},
    {"rank": "13", "unit": "Phường Đức Phổ", "population": 41232},
    {"rank": "14", "unit": "Xã Long Phụng", "population": 39645},
    {"rank": "15", "unit": "Xã Nghĩa Giang", "population": 39628},
    {"rank": "16", "unit": "Xã Vệ Giang", "population": 38406},
    {"rank": "17", "unit": "Xã Mỏ Cày", "population": 38386},
    {"rank": "18", "unit": "Xã Bờ Y", "population": 36005},
    {"rank": "19", "unit": "Xã Đăk Hà", "population": 35975},
    {"rank": "20", "unit": "Xã Lân Phong", "population": 35920},
    {"rank": "21", "unit": "Xã Đình Cương", "population": 35859},
    {"rank": "22", "unit": "Xã Đăk Tô", "population": 35797},
    {"rank": "23", "unit": "Xã Mộ Đức", "population": 35724},
    {"rank": "24", "unit": "Phường Sa Huỳnh", "population": 32298},
    {"rank": "25", "unit": "Xã Nghĩa Hành", "population": 31578},
    {"rank": "26", "unit": "Phường Đăk Cấm", "population": 30553},
    {"rank": "27", "unit": "Xã Khánh Cường", "population": 28222},
    {"rank": "28", "unit": "Xã Thọ Phong", "population": 27970},
    {"rank": "29", "unit": "Xã Đăk Rơ Wa", "population": 26083},
    {"rank": "30", "unit": "Xã Sơn Hạ", "population": 24971},
    {"rank": "31", "unit": "Đặc khu Lý Sơn", "population": 24658},
    {"rank": "32", "unit": "Xã Ngọk Bay", "population": 23982},
    {"rank": "33", "unit": "Xã Phước Giang", "population": 23718},
    {"rank": "34", "unit": "Phường Đăk Bla", "population": 22736},
    {"rank": "35", "unit": "Xã Trường Giang", "population": 21947},
    {"rank": "36", "unit": "Xã Ia Chim", "population": 21589},
    {"rank": "37", "unit": "Xã Ba Gia", "population": 21529},
    {"rank": "38", "unit": "Xã Trà Giang", "population": 20777},
    {"rank": "39", "unit": "Xã Sơn Hà", "population": 20370},
    {"rank": "40", "unit": "Xã Đăk Mar", "population": 19802},
    {"rank": "41", "unit": "Xã Bình Minh", "population": 19772},
    {"rank": "42", "unit": "Xã Sa Thầy", "population": 19607},
    {"rank": "43", "unit": "Xã Trà Bồng", "population": 18939},
    {"rank": "44", "unit": "Xã Kon Braih", "population": 18912},
    {"rank": "45", "unit": "Xã Nguyễn Nghiêm", "population": 17839},
    {"rank": "46", "unit": "Xã Đăk Pék", "population": 17654},
    {"rank": "47", "unit": "Xã Sơn Linh", "population": 17281},
    {"rank": "48", "unit": "Xã Thiện Tín", "population": 17230},
    {"rank": "49", "unit": "Xã Sa Bình", "population": 17017},
    {"rank": "50", "unit": "Xã Bình Chương", "population": 16521},
    {"rank": "51", "unit": "Xã Dục Nông", "population": 15966},
    {"rank": "52", "unit": "Xã Kon Đào", "population": 13593},
    {"rank": "53", "unit": "Xã Sa Loong", "population": 13075},
    {"rank": "54", "unit": "Xã Sơn Thủy", "population": 12759},
    {"rank": "55", "unit": "Xã Ba Tơ", "population": 12356},
    {"rank": "56", "unit": "Xã Đăk Môn", "population": 12317},
    {"rank": "57", "unit": "Xã Ngọk Réo", "population": 12301},
    {"rank": "58", "unit": "Xã Đăk Ui", "population": 12230},
    {"rank": "59", "unit": "Xã Sơn Kỳ", "population": 12199},
    {"rank": "60", "unit": "Xã Tây Trà", "population": 11856},
    {"rank": "61", "unit": "Xã Ba Vì", "population": 11558},
    {"rank": "62", "unit": "Xã Đăk Pxi", "population": 11549},
    {"rank": "63", "unit": "Xã Đông Trà Bồng", "population": 11115},
    {"rank": "64", "unit": "Xã Ya Ly", "population": 10704},
    {"rank": "65", "unit": "Xã Măng Đen", "population": 10146},
    {"rank": "66", "unit": "Xã Minh Long", "population": 10074},
    {"rank": "67", "unit": "Xã Sơn Mai", "population": 10005},
    {"rank": "68", "unit": "Xã Sơn Tây", "population": 9918},
    {"rank": "69", "unit": "Xã Ba Tô", "population": 9624},
    {"rank": "70", "unit": "Xã Kon Plông", "population": 9476},
    {"rank": "71", "unit": "Xã Đăk Tờ Kan", "population": 9261},
    {"rank": "72", "unit": "Xã Măng Bút", "population": 9132},
    {"rank": "73", "unit": "Xã Măng Ri", "population": 8909},
    {"rank": "74", "unit": "Xã Ngọk Tụ", "population": 8725},
    {"rank": "75", "unit": "Xã Đăk Rve", "population": 8305},
    {"rank": "76", "unit": "Xã Tây Trà Bồng", "population": 8184},
    {"rank": "77", "unit": "Xã Ba Động", "population": 7714},
    {"rank": "78", "unit": "Xã Sơn Tây Thượng", "population": 7567},
    {"rank": "79", "unit": "Xã Ia Tơi", "population": 7541},
    {"rank": "80", "unit": "Xã Thanh Bồng", "population": 7521},
    {"rank": "81", "unit": "Xã Ba Dinh", "population": 7299},
    {"rank": "82", "unit": "Xã Đăk Long", "population": 7096},
    {"rank": "83", "unit": "Xã Tu Mơ Rông", "population": 6906},
    {"rank": "84", "unit": "Xã Đăk Sao", "population": 6825},
    {"rank": "85", "unit": "Xã Xốp", "population": 6563},
    {"rank": "86", "unit": "Xã Ngọc Linh", "population": 6553},
    {"rank": "87", "unit": "Xã Rờ Kơi", "population": 6507},
    {"rank": "88", "unit": "Xã Ba Vinh", "population": 6433},
    {"rank": "89", "unit": "Xã Đăk Kôi", "population": 6055},
    {"rank": "90", "unit": "Xã Mô Rai", "population": 5939},
    {"rank": "91", "unit": "Xã Sơn Tây Hạ", "population": 5806},
    {"rank": "92", "unit": "Xã Đăk Plô", "population": 5576},
    {"rank": "93", "unit": "Xã Ba Xa", "population": 5522},
    {"rank": "94", "unit": "Xã Ia Đal", "population": 5106},
    {"rank": "95", "unit": "Xã Đặng Thùy Trâm", "population": 4522},
    {"rank": "96", "unit": "Xã Cà Đam", "population": 4421},
  ];


  final double maxAcreage = 90109; // Giả định điểm tối đa để tính tỷ lệ thanh progress

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
        title: const Text("DÂN SỐ (Thường trú và Tạm trú)",
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
          Text("DÂN SỐ (Người)", style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> team) {
    double progressWidth = team['population'] / maxAcreage; // Tính % thanh xanh

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
                  "${team['population']}",
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