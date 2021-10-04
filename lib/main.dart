import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work_os_app/screens/auth/login.dart';
import 'package:work_os_app/screens/auth/register.dart';
import 'package:work_os_app/screens/auth/tasks.dart';
import 'package:work_os_app/screens/inner_screen/add_task.dart';
import 'package:work_os_app/screens/inner_screen/profile.dart';
import 'package:work_os_app/screens/inner_screen/task_details.dart';
import 'package:work_os_app/user_state.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatefulWidget{
  @override
  MyAppState createState()=>MyAppState();

}

class MyAppState extends State<MyApp>{
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Worksos Arabic',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFEDE7DC),
        primarySwatch: Colors.blue,
      ),
      home: UserState(),
    );
  }
}
