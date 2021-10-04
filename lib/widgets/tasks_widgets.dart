import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_os_app/screens/inner_screen/task_details.dart';

import '../services.dart';

class TaskWidget extends StatefulWidget{
  final String taskId;
  final String taskTitle;
  final String taskCategory;
  final String taskDescription;
  final String uploayBy;
  final bool isDone;
  final String deadlineDate;

  TaskWidget({
    @required this.taskId,
    @required this.taskTitle,
    @required this.taskCategory,
    @required this.taskDescription,
    @required this.uploayBy,
    @required this.isDone,
    @required this.deadlineDate});

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget>{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: ()
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(taskId: widget.taskId, taskTitle: widget.taskTitle, uploadedBy: widget.uploayBy,)));
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  actions: [
                    TextButton(
                      onPressed: () {
                        User user = _auth.currentUser;
                        String _uid = user.uid;
                        if(_uid == widget.taskId){
                          FirebaseFirestore.instance.collection("tasks").doc(widget.taskId).delete();
                          Navigator.pop(context);
                        } else{
                          GlobalMethods.showErrorDialog(error: "you not have access to delete this task", context: context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        },
        title: Text(widget.taskTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.linear_scale,
              color: Colors.pink.shade800,
            ),
            Text(widget.taskDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(width: 1.0))
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Image.network(widget.isDone
                ? "https://www.emojiall.com/images/60/skype/2714-fe0f.png"
                : "https://previews.123rf.com/images/muuraa/muuraa1404/muuraa140400162/27659154-sketch-of-the-arrow-and-clock-as-a-symbol-of-progress-isolated.jpg"
             ),
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_right, color: Colors.pink[800],),
      ),
    );
  }

}