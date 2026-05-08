import 'package:app_02/models/dailyReport.dart';
import 'package:flutter/material.dart';

class ViewReport extends StatefulWidget {
  final DailyReport report;
  const ViewReport({super.key, required this.report});
  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {


  @override
  void initState() {
    super.initState();
      }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết báo cáo", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("img/logocand.png", height: 40),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("CÔNG AN TỈNH QUẢNG NGÃI"),
                  ],
                ),

                SizedBox(height: 25),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Kính gửi: Lãnh đạo Công an tỉnh",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 16),

                //Tiêu đề
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.report.title}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 16),

                //Nội dung
                Text(
                      "${widget.report.content}",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                SizedBox(height: 16),

                //Cán bộ báo cáo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Cán bộ báo cáo: ${widget.report.fullName}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Số: ${widget.report.id}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Ngày tạo: ${widget.report.createdAt.toDate().day}/${widget.report.createdAt.toDate().month}/${widget.report.createdAt.toDate().year}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),

                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
