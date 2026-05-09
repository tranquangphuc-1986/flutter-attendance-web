import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_02/cax/cax_model.dart';
import 'package:app_02/cax/cax_data.dart';
import 'package:app_02/cax/cax_card.dart';
import 'package:app_02/cax/cax_detail_screen.dart';

class HomeScreenCAX extends StatefulWidget {
  const HomeScreenCAX({super.key});

  @override
  State<HomeScreenCAX> createState() => _HomeScreenCAXState();
}

class _HomeScreenCAXState extends State<HomeScreenCAX> {

  @override
  void initState() {
    super.initState();
    // Hiển thị banner cài đặt ứng dụng nếu cần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInstallBanner(context);
    });
  }

  List<DonVi> filteredList = donViList;
  final TextEditingController searchController = TextEditingController();

  void _search(String query) {
    setState(() {
      filteredList = donViList
          .where((dv) => dv.ten.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


//Tạo 1 hàm để hiển thị banner cài đặt ứng dụng trên iOS
  void showInstallBanner(BuildContext context) {
    // 1. Kiểm tra nếu đã là App (Standalone) thì không hiện nữa
    bool isStandalone = html.window
        .matchMedia('(display-mode: standalone)')
        .matches;
    if (isStandalone) return;
    // 2. Xử lý cho iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) =>
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Cài đặt ứng dụng Tham mưu", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 15),
                  ListTile(
                    leading: Icon(Icons.ios_share, color: Colors.blue),
                    title: Text(
                        "Bấm vào nút Chia sẻ trên thanh công cụ Safari"),
                  ),
                  ListTile(
                    leading: Icon(Icons.add_box_outlined),
                    title: Text(
                        "Chọn 'Thêm vào màn hình chính' (Add to Home Screen)"),
                  ),
                  ElevatedButton(onPressed: () => Navigator.pop(context),
                      child: Text("Đã hiểu"))
                ],
              ),
            ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Công an xã, phường, đặc khu', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm đơn vị...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3/4,
              ),
              itemBuilder: (context, index) {
                final dv = filteredList[index];
                return DonViCard(
                  donVi: dv,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(cax: dv,),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
