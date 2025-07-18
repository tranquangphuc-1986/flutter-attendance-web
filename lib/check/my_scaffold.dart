import 'package:flutter/material.dart';

class Myscaffold extends StatelessWidget{
  const Myscaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Myapp"),
        ),
        
        backgroundColor: Colors.lightGreenAccent,
      
        body: 
            Center(child: Text("Nội dung chính"),),
        
        floatingActionButton: FloatingActionButton(
            onPressed: (){print("xin chao");},
                child: const Icon(Icons.import_export),
        ),
            
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "home"),
        ]),

    );
  }
}