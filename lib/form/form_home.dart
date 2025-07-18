import 'package:flutter/material.dart';
class FormHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _FormHomeState();
}
class _FormHomeState extends State<FormHome>{
  final _formKey = GlobalKey<FormState>();//Dùng để phân biệt form này với form khác
  final _fullnamecontraller = TextEditingController();
  String? _hoten;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ"),
      ),

      body:
      Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 100,),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Họ và tên",
                    hintText: "Nhập họ tên đầy đủ",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value){
                    _hoten=value;
                  },
                ),

                SizedBox(height: 50,),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Đơn vị",
                    hintText: "Nhập đơn vị viết tắt",
                    border: OutlineInputBorder(
                    ),
                  ),
                  onSaved: (value){
                    _hoten=value;
                  },
                ),

            SizedBox(height: 50,),
                TextFormField(
                  controller: _fullnamecontraller,
                  decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    hintText: "09xxxxxxxxi",
                    border: OutlineInputBorder(
                    ),
                  ),
                  onSaved: (value){
                    _hoten=value;
                  },

                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    ElevatedButton(onPressed: (){
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Xin chào $_hoten"))
                        );
                      }
                    }, child: Text("Lưu")),

                    SizedBox(width: 40,),
                    ElevatedButton(onPressed: (){
                      _formKey.currentState!.reset();
                      setState(() {//trở lại reset form
                        _hoten=null;
                      });
                    }, child: Text("Trở lại")),


                  ],
                )
              ],
            )

          ),
      ),
    );
  }
}