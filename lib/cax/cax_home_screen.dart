import 'dart:js' as js;
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
    checkAndShowAndroidInstall(context);
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

  void checkAndShowAndroidInstall(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Đợi 5-10 giây sau khi vào App mới hiện Snackbar để tránh phiền
      Future.delayed(Duration(seconds: 10), () {
        // Kiểm tra biến canInstallApp từ JS
        final canInstall = js.context.hasProperty('canInstallApp') &&
            js.context['canInstallApp'] == true;

        if (canInstall) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cài đặt App Tham mưu để sử dụng thuận tiện hơn'),
              duration: Duration(seconds: 10),
              action: SnackBarAction(
                label: 'CÀI ĐẶT',
                onPressed: () {
                  // Gọi hàm JS để hiện bảng hỏi cài đặt gốc
                  js.context.callMethod('triggerAndroidInstall');
                },
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        backgroundColor: Colors.red,
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
