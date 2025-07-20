import 'package:flutter/material.dart';
import 'package:app_02/cax/cax_model.dart';

class DetailScreen extends StatelessWidget {
  final DonVi cax;
  const DetailScreen({required this.cax, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cax.ten),
      backgroundColor: Colors.blue,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: cax.ten,
              child: Image.asset(cax.hinhAnh),
            ),
            const SizedBox(height: 2),
            buidInfo("Đơn vị:", cax.ten),
            buidInfo("Sáp nhập từ:", cax.sapNhap),
            buidInfo("Trụ sở chính:", cax.diaChi),
            buidInfo("Điện thoại:", cax.dienThoai),
            buidInfo("Trưởng Công an:", cax.tenTCA),
            buidInfo("Số điện thoại TCA:", cax.dtTCA),
            buidInfo("Facebook:", cax.fb),
          ],
        ),
      ),
    );
  }
  Widget buidInfo(String title, String? value)
  => ListTile(
    title: Text(title, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold) ,),
    subtitle: Text(value?? ""),
    leading: Icon(Icons.gamepad_outlined, color: Colors.red,),
  );
}
