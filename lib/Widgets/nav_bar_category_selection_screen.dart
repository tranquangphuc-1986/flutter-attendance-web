import 'dart:ffi';

import 'package:flutter/material.dart';
class NavBarCategorySelectionScreen extends StatefulWidget{
  const NavBarCategorySelectionScreen({super.key});
  @override
  State<NavBarCategorySelectionScreen> createState() => _NavBarCategorySelectionScreenState();
}
class _NavBarCategorySelectionScreenState extends State<NavBarCategorySelectionScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,),

    );
  }
}