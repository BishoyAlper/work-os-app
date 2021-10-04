import 'package:flutter/material.dart';

class GlobalMethods{
  static void showErrorDialog({@required String error,@required BuildContext context}){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Error occured"),
                ),
              ],
            ),
            content: Text(error, style: TextStyle(fontSize: 20, color: Colors.pink, fontStyle: FontStyle.italic),),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("cancel", style: TextStyle(fontSize: 20),),),
            ],
          );
        }
    );
  }

}