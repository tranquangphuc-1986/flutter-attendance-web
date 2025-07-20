import 'package:app_02/data_diaban/diaban_card.dart';
import 'package:app_02/data_diaban/diaban_dulieu.dart';
import 'package:flutter/material.dart';

class CAXScreen extends StatefulWidget {
  const CAXScreen({super.key});

  @override
  State<CAXScreen> createState() => _CAXScreenState();
}

class _CAXScreenState extends State<CAXScreen> {
  String searchQuery = '';
  int currentPage = 0;
  final int itemsPerPage = 9; //số card (đơn vị) tối đa mỗi màn hình

  @override
  Widget build(BuildContext context) {
    final filtered = units
        .where((u) => u.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    final paginated = filtered.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();
    final totalPages = (filtered.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn vị'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm đơn vị',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: paginated.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,//mỗi hàng chia làm 3 ô (cột) card
                mainAxisSpacing: 12, //khoảng cách các hàng
                crossAxisSpacing: 12, //khoảng cách các cột
                childAspectRatio: 0.9, //chiều cao card gấp 0,9 rộng
              ),
              itemBuilder: (context, index) {
                return UnitCard(unit: paginated[index]);
              },
            ),
          ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => currentPage = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index ? Colors.blue : Colors.grey,
                      ),
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}