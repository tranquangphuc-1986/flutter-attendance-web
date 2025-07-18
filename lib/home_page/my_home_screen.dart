import 'package:app_02/home_page/page_first.dart';
import 'package:app_02/home_page/setting.dart';
import 'package:app_02/travel/myhome_page.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

//Xuất hiện các màn hình khi onTap vào các icon BottomNvaBar
int selectedIndex = 1;
final List screens = [
  SettingsScreen(),
  const PageFirst(),
  const MyHomePage(),
  //const SignupScreen(),
  //const EmailChangePasswordScreen(),
];

class _MyPageState extends State<MyPage> {

  @override
  void initState() {
    super.initState();
    selectedIndex=1;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
      body: screens[selectedIndex],
    );
  }
}
