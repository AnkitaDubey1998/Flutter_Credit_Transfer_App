import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/MainPage.dart';
import 'package:fluttercredittransferapp/screens/authentication/SignIn.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<FirebaseUser>(context);
    
    // return either home or authenticate
    if(user ==  null) {
      return SignIn();
    } else {
      return MainPage();
    }

  }
}
