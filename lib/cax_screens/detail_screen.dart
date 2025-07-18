
import 'package:flutter/material.dart';
import 'package:app_02/models/cax_model.dart';

class DetailScreen extends StatelessWidget {
  final DonVi donVi;
  const DetailScreen({required this.donVi, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(donVi.ten)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: donVi.ten,
              child: Image.asset(donVi.hinhAnh),
            ),
            const SizedBox(height: 20),
            Text(donVi.moTa, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
