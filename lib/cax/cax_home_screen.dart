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
  List<Map<String, String>> filteredList = [];
  final TextEditingController searchController = TextEditingController();

  void _search(String query) {
    setState(() {
      filteredList = donViList
          .where((dv) => dv['ten']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Công an xã, phường, đặc khu')),
      backgroundColor: Colors.blue,
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
                  donVi: DonVi.fromMap(dv),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(donVi: dv, cax: DonVi.fromMap(dv),),
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
