import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_02/Widgets/my_button.dart';

class DanSoFormScreen extends StatefulWidget {
  @override
  _DanSoFormScreenState createState() => _DanSoFormScreenState();
}

class _DanSoFormScreenState extends State<DanSoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dansoController = TextEditingController();
  final TextEditingController _namController = TextEditingController();
  final TextEditingController _nuController = TextEditingController();
  final TextEditingController _tamtruController = TextEditingController();
  final TextEditingController _thuongtruController = TextEditingController();

  Future <void> _saveDataFirebase() async {

    final danso = int.tryParse(_dansoController.text);
    final nam = int.tryParse(_namController.text);
    final nu = int.tryParse(_nuController.text);
    final tamtru = int.tryParse(_tamtruController.text);
    final thuongtru = int.tryParse(_thuongtruController.text);

    if (danso == null || nam == null || nu == null || tamtru == null ||
        thuongtru == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thông tin nhập không phải số hoặc để trống')),
      );
      return;
    }
    if (nam + nu != danso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tổng nam và nữ không bằng dân số')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection("dancuData").add({
        'danso': danso,
        'nam': nam,
        'nu': nu,
        'thuongtru': thuongtru,
        'tamtru': tamtru,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dữ liệu đã được lưu vào CSDL')),
      );
      _dansoController.clear();
      _namController.clear();
      _nuController.clear();
      _tamtruController.clear();
      _thuongtruController.clear();

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu dữ liệu: $e')),
      );
    }

  }

  //Tạo textformfield chung để sử dụng
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Nhập $label',
          suffixIcon: IconButton( //tạo 1 icon buton để xử lý sự kiện xóa chữ
            onPressed: (){
              controller.clear(); //ấn vào icon x sẽ xóa chữ nhập vào
            },
            icon: Icon(Icons.dangerous),
          ),
          border: OutlineInputBorder(
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nhập thông tin dân số')),
      body:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Tổng dân số', _dansoController),
              SizedBox(height: 20,),
              _buildTextField('Số nam', _namController),
              SizedBox(height: 20,),
              _buildTextField('Số nữ', _nuController),
              SizedBox(height: 20,),
              _buildTextField('Tạm trú', _tamtruController),
              SizedBox(height: 20,),
              _buildTextField('Thường trú', _thuongtruController),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveDataFirebase,
              child: const Text('Lưu'),
            ),
              SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  child: MyButton(onTap: _saveDataFirebase,
                      buttontext: "Lưu")
              ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}