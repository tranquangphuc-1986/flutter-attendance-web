import 'package:app_02/data_diaban/diaban_model.dart';
import 'package:flutter/material.dart';
class UnitCard extends StatelessWidget {
  final Unit unit;

  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Card(
        elevation: 3, //độ cao của card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: unit.name,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    unit.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(unit.name, style: const TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        alignment: Alignment.center,
        title: Text(unit.name, style: const TextStyle(fontSize: 18,
            fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center,),
        content: Text(unit.info),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          )
        ],
      ),
    );
  }
}