import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<String>signUpUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
}) async{
    String res ="Lỗi";
    try{
      if(email.isNotEmpty && password.isNotEmpty
          && name.isNotEmpty&&phone.isNotEmpty&&role.isNotEmpty){
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore.collection("userLogin").doc(credential.user!.uid).set({
          'name': name,
          'uid': credential.user!.uid,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
          'score': 0,
        });
        res="Thành công";
      }else{
       res="Thất bại";
      }
    }catch(err){
      return err.toString();
    }
    return res;
  }

  Future<String>loginUser({
    required String email,
    required String password,
  }) async{
    String res ="Lỗi";
    try{
      if(email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res="Thành công";
      }else{
        res="Thất bại";
      }
    }
   catch(err){
      return err.toString();
   }
    return res;
  }
Future<void> signOut()async{
   await _auth.signOut();
  }
  //Cập nhật lại Mật khẩu
  Future<void> updatePassword(String email, String newPassword) async {
    final userRef = FirebaseFirestore.instance.collection('userLogin');
    final snapshot = await userRef.where('email', isEqualTo: email).get();
    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await userRef.doc(docId).update({'password': newPassword});
    }
  }
}

