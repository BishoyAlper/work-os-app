import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_os_app/screens/auth/login.dart';
import 'package:work_os_app/screens/auth/tasks.dart';

class UserState extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapShot){
        if(userSnapShot.data == null){
          return LoginScreen();
        } else if (userSnapShot.hasData){
          return TasksScreen();
        } else if(userSnapShot.hasError){
          return Center(
            child: Text(
                "An error has been occurred",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 40),
            ),
          );
        }
        return Scaffold(
          body:Center(
            child: Text(
              "Something went wrong",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
        );
      },
    );
  }
}