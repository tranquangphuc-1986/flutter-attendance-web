import 'package:flutter/material.dart';
import 'package:app_02/cax/cax_model.dart';

class DetailScreen extends StatelessWidget {
  final DonVi cax;
  final Map <String, String> donVi;
  const DetailScreen({required this.cax, required this.donVi, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cax.ten)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: cax.ten,
              child: Image.asset(cax.hinhAnh),
            ),
            const SizedBox(height: 8),
            Text(cax.ten, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(cax.sapNhap, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(cax.diaChi, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(cax.dienThoai, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(cax.tenTCA, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(cax.dtTCA, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(cax.fb, style: const TextStyle(fontSize: 16, color: Colors.green)),

            const SizedBox(height: 8),
            buidInfo("Đơn vị:", donVi['ten']),
            buidInfo("Sáp nhập từ:", donVi['sapNhap']),
            buidInfo("Trụ sở chính:", donVi['diaChi']),
            buidInfo("Điện thoại:", donVi['dienThoai']),
            buidInfo("Trưởng Công an:", donVi['tenTCA']),
            buidInfo("Số điện thoại TCA:", donVi['dtTCA']),
            buidInfo("Facebook:", donVi['fb']),
          ],
        ),
      ),
    );
  }
  Widget buidInfo(String title, String? value)
  => ListTile(
    title: Text(title, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold) ,),
    subtitle: Text(value?? ""),
    leading: Icon(Icons.info_outline),
  );
}
