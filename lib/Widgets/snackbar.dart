import 'package:flutter/material.dart';
void showSnackBAR(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
          ),
  );
}