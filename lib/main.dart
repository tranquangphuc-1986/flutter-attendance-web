import 'package:app_02/email/email_signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_02/email/email_login_screen.dart';
import 'package:flutter/material.dart';
import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, //là một thuộc tính được sử dụng để ẩn biểu ngữ “DEBUG” màu đỏ ở góc trên bên phải của ứng dụng khi chạy ở chế độ debug.
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        //textTheme: GoogleFonts.playfairDisplayTextTheme(),
        fontFamily: 'Roboto',
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.green,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const EmailLoginScreen(),
      // initialRoute: '/',
      routes: {
        '/signup': (context) => EmailSignupScreen(),
        //'/myhome':(context)=>MyPage(),
      },

      // giữ đăng nhập cho đến khi đăng xuất
      //  home: StreamBuilder<User?>(
      //      stream: FirebaseAuth.instance.authStateChanges(),
      //      builder: (context, snapshot) {
      //        if(snapshot.connectionState==ConnectionState.active){
      //          if (snapshot.hasError) {
      //            return Scaffold(
      //              body: Center(child: Text("Đã xảy ra lỗi!")),
      //            );
      //          }
      //          if(snapshot.hasData==true){
      //              return const MyPage();
      //          }else{
      //           return const EmailLoginScreen();
      //           // return const PhoneLoginScreen();
      //          }
      //        }
      //        return const Scaffold(
      //          body: Center(
      //            child: CircularProgressIndicator(),
      //          ),
      //        );
      //      },
      //  ),
    );
  }
}
