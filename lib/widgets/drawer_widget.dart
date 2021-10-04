import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_os_app/screens/all_workers.dart';
import 'package:work_os_app/screens/auth/tasks.dart';
import 'package:work_os_app/screens/inner_screen/add_task.dart';
import 'package:work_os_app/screens/inner_screen/profile.dart';

import '../user_state.dart';

class DrawerWidget extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User user = _auth.currentUser;
    final uid = user.uid;
    // TODO: implement build
    return Drawer(
      elevation: 8.0,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan),
            child: Column(
              children: [
                Flexible(child: Image.network("https://project-management.com/wp-content/uploads/2020/01/top-5-work-os-software-and-tools-2.png")),
                SizedBox(height: 20,),
                Flexible(child: Text("Work os Arabic",
                  style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                  ),
                ),
                ),
              ],
            ),
          ),
          _listTile(fun: (){_navigateToAnotherScreen(context, TasksScreen());}, icon: Icons.local_taxi_sharp , text: "All Tasks"),
          _listTile(fun: (){ _navigateToAnotherScreen(context, ProfileScreen(uid));}, icon: Icons.settings , text: "My Acount"),
          _listTile(fun: (){_navigateToAnotherScreen(context, AllWorkersScreen());}, icon: Icons.workspaces_outline, text: "Registered Workers"),
          _listTile(fun: (){_navigateToAnotherScreen(context, AddTaskScreen());}, icon: Icons.add, text: "Add Task"),
          Divider(thickness: 1,),
          _listTile(fun: (){
            logOut(context);
          }, icon: Icons.logout, text: "Log Out"),
        ],
      ),
    );
  }

  void logOut(context){
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
      context: context, builder: (context){
        return AlertDialog(
          title: Row(
            children: [
              Image.network("https://www.pikpng.com/pngl/m/519-5199120_logout-icon-png-sign-out-icon-png-clipart.png",
                width: 20,
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Sign Out"),
              ),
            ],
          ),
          content: Text("Do you wanna Sign Out", style: TextStyle(fontSize: 20, color: Colors.pink, fontStyle: FontStyle.italic),),
          actions: [
            TextButton(onPressed: (){
              Navigator.canPop(context) ? Navigator.pop(context) : null;
            }, child: Text("cancel", style: TextStyle(fontSize: 20),),),
            TextButton(onPressed: () async{
              await _auth.signOut();
              Navigator.canPop(context) ? Navigator.pop(context) : null;
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>UserState()));
            }, child: Text("ok", style: TextStyle(color: Colors.red, fontSize: 20),),)
          ],
        );
    }
    );
  }

  void _navigateToAnotherScreen(context, Widget widget){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
 }

  Widget _listTile({Function fun, IconData icon, String text}){
    return ListTile(
      onTap: fun,
      leading: Icon(icon , color: Colors.pink,),
      title: Text(text,
        style: TextStyle(
            color: Colors.pink,
            fontSize: 20,
            fontStyle: FontStyle.italic
        ),
      ),
    );
  }
}