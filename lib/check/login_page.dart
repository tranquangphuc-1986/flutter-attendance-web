import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State <LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _textController = TextEditingController();
   String _input = '';


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          child: Center(
            child: Column(
              children: [
                //tao anh trang tri phia tren
                Container(
                  width: w,
                  height: h*0.23,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "img/anlystatis.png"
                          ),
                          fit: BoxFit.cover
                      )

                  ),
                ),
                //tao chu Xin chao
                SizedBox(height: 20,),
                Container(
                  //canh vi tri container cach trai, phai
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  width: w,
                  child: Column(
                    //dieu chinh vị tri cua chu Xin chao ve ben phai man hinh
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Xin chào",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        "Đăng nhập tài khoản và mật khẩu",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.indigo
                        ),
                      ),
                      SizedBox(height: 50,),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: "Tài khoản",
                          hintText: "Số điện thoại 09XXXXXXXX",
                          helperText: "Nhập vào số điện thoại",
                          prefixIcon: Icon(Icons.phone),
                          suffixIcon: IconButton( //tạo 1 icon buton để xử lý sự kiện xóa chữ
                              onPressed: (){
                                _textController.clear(); //ấn vào icon x sẽ xóa chữ nhập vào
                              },
                              icon: Icon(Icons.clear),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20), //Bo viền textfield
                          ),
                          filled: true,//có màu nền không
                          fillColor: Colors.cyanAccent,//màu nền bên trong textfield
                        ),
                        keyboardType: TextInputType.phone,//hiện bàn phím bấm số
                        onChanged: (value){
                          setState(() {//hàm này để vẽ lại giao diện
                            _input=value;
                          });
                        },
                      ),
                      SizedBox(height: 20,),

                      TextField(
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          hintText: "",
                          helperText: "Nhập mật khẩu của bạn",
                          prefixIcon: Icon(Icons.key_outlined),
                          suffixIcon: Icon(Icons.remove_red_eye_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        obscuringCharacter: '*',
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
      ),
    );
  }
}

