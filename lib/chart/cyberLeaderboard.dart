import 'package:flutter/material.dart';

class CyberLeaderboard extends StatelessWidget {
  // Dữ liệu mẫu (Bạn có thể parse từ file Excel trên vào đây)
  final List<Map<String, dynamic>> teams = [
    {"rank": "01", "name": "Cyb3r_Gu4rdians", "unit": "T07", "score": 986},
    {"rank": "02", "name": "The Wings of Seagulls", "unit": "PA05 Hải Phòng", "score": 885},
    {"rank": "03", "name": "Aegis IV", "unit": "PA05 Tuyên Quang", "score": 879},
    {"rank": "04", "name": "r00t_m4st3r", "unit": "T07", "score": 819},
    {"rank": "05", "name": "C500_TDĐQ", "unit": "T01", "score": 806},
    {"rank": "06", "name": "PSA_sudo", "unit": "T01", "score": 806},
    {"rank": "07", "name": "Bắc Ninh", "unit": "PA05 Bắc Ninh", "score": 786},
    // ... thêm các đội khác
  ];

  final double maxScore = 1000; // Giả định điểm tối đa để tính tỷ lệ thanh progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D21), // Màu nền tối giống trong ảnh
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("HÀNH TRÌNH TRUY VẾT TỘI PHẠM",
            style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
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
          Text("RANK / TEAM", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text("SCORE", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> team) {
    double progressWidth = team['score'] / maxScore; // Tính % thanh xanh

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
                            TextSpan(
                              text: "${team['name']} ",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            TextSpan(
                              text: "(${team['unit']})",
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "${team['score']}",
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
    if (rank == "01") return Colors.amber;
    if (rank == "02") return Colors.grey;
    if (rank == "03") return Colors.orange;
    return Colors.blueAccent;
  }
}