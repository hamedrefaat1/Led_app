// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/auth/mainpage.dart';
import 'package:led/firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
     home: ScreenUtilInit(designSize: Size(375, 812),child:
     MainPage()
      ),
        //  home:Responsive(myMobileScreen: MobileScreen(), myWebScreen: WebScreen(),) ,
        );
  } 
}
