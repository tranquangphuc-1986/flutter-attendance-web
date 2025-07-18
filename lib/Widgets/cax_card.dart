import 'package:flutter/material.dart';
import 'package:app_02/models/cax_model.dart';

class DonViCard extends StatelessWidget {
  final DonVi donVi;
  final VoidCallback onTap;

  const DonViCard({required this.donVi, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: donVi.ten,
                child: Image.asset(
                  donVi.hinhAnh,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                donVi.ten,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
