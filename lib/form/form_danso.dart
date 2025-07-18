import 'package:flutter/material.dart';

class FormDanso extends StatefulWidget{
  const FormDanso({super.key});
  @override
  State<StatefulWidget> createState() => _FormDansoState();
}
class _FormDansoState extends State<FormDanso>{
  final _formKey = GlobalKey<FormState>();//Dùng để phân biệt form này với form khác
  final _dansoController = TextEditingController();
  final _thuongtruController = TextEditingController();
  final _tamtruController = TextEditingController();
  final _namController = TextEditingController();
  final _nuController = TextEditingController();
  final _cancuocController = TextEditingController();
  String? _value;

  void _handleSubmit() {
    int danso = int.tryParse(_dansoController.text) ?? 0;
    int nam = int.tryParse(_namController.text) ?? 0;
    int nu = int.tryParse(_nuController.text) ?? 0;
    int tamtru = int.tryParse(_tamtruController.text) ?? 0;
    int thuongtru = int.tryParse(_thuongtruController.text) ?? 0;

    print('Dân số: $danso');
    print('Nam: $nam');
    print('Nữ: $nu');
    print('Tạm trú: $tamtru');
    print('Thường trú: $thuongtru');

    // Bạn có thể xử lý lưu vào database hoặc gửi lên server ở đây
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dữ liệu đã được xử lý')),
    );
  }
  @override
  void dispose() {
    _dansoController.dispose();
    _namController.dispose();
    _nuController.dispose();
    _tamtruController.dispose();
    _thuongtruController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,
        title: Text("Dân số"),
      ),

      body:
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60,),
                TextFormField(
                  controller: _dansoController,
                  decoration: InputDecoration(
                    labelText: "Tổng dân số",
                    hintText: "Nhập dân số",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _thuongtruController,
                  decoration: InputDecoration(
                    labelText: "Tổng thường trú",
                    hintText: "Nhập nhân khẩu thường trú",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value= value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _namController,
                  decoration: InputDecoration(
                    labelText: "Nam",
                    hintText: "Nhập thông tin",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value= value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _namController,
                  decoration: InputDecoration(
                    labelText: "Nữ",
                    hintText: "Nhập thông tin",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value= value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _tamtruController,
                  decoration: InputDecoration(
                    labelText: "Tổng tạm trú",
                    hintText: "Nhập nhân khẩu tạm trú",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value=value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _cancuocController,
                  decoration: InputDecoration(
                    labelText: "Đã làm Căn cước",
                    hintText: "Nhập NK đã được cấp Căn cước",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value=value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _cancuocController,
                  decoration: InputDecoration(
                    labelText: "Đã làm định danh",
                    hintText: "Nhập NK đã được cấp ĐDĐT mức 2",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value=value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _cancuocController,
                  decoration: InputDecoration(
                    labelText: "Kích hoạt định danh",
                    hintText: "Đã kích hoạt ĐDĐT mức 2",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value=value;
                  },
                ),
                SizedBox(height: 30,),

                TextFormField(
                  controller: _cancuocController,
                  decoration: InputDecoration(
                    labelText: "Kích hoạt định danh",
                    hintText: "Đã kích hoạt ĐDĐT mức 2",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value=value;
                  },
                ),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _cancuocController,
                  decoration: InputDecoration(
                    labelText: "Kích hoạt định danh",
                    hintText: "Đã kích hoạt ĐDĐT mức 2",
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value){
                    _value=value;
                  },
                ),
                SizedBox(height: 30,),

                Row(
                  children: [
                    ElevatedButton(onPressed: (){
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Lưu dữ lệu thành công"))
                        );
                      }
                    }, child: Text("Lưu")),

                    SizedBox(width: 40,),
                    ElevatedButton(onPressed: (){
                      _formKey.currentState!.reset();
                      setState(() {//trở lại reset form
                        _value=null;
                      });
                    }, child: Text("Hủy")),
                  ],
                )
              ],
            )
          ),
      ),
      ),
    );
  }
}