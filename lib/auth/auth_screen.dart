import 'package:flutter/material.dart';
import 'package:led/screens/login_screen.dart';
import 'package:led/screens/signup_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  bool a=true;
  void go(){
   setState(() {
      a=!a;
   });
  }
  @override
  Widget build(BuildContext context) {
 
    if(a){
      return LoginScreen(show: go);
    }else{
       return SignUpScreen(show: go);
    }
   
  }
}