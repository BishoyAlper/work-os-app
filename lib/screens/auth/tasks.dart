import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_os_app/constant/constants.dart';
import 'package:work_os_app/widgets/drawer_widget.dart';
import 'package:work_os_app/widgets/tasks_widgets.dart';

class TasksScreen extends StatefulWidget{

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String taskCategory;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.pink),
        // leading: Builder(
        //   builder: (ctx){
        //     return IconButton(
        //       onPressed: (){
        //         Scaffold.of(ctx).openDrawer();
        //       },
        //       icon: Icon(Icons.menu, color: Colors.pink,),
        //     );
        //   },
        // ),
        title: Text(
          'Tasks',
          style: TextStyle(color: Colors.pink),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
              onPressed: () {
                showTaskCategoryDialog(context, size);
              },
              icon: Icon(Icons.filter_list_outlined),
              color: Colors.black),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("tasks").where("taskCategory", isEqualTo: taskCategory).orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (snapshot.connectionState == ConnectionState.active){
            if(snapshot.data.docs.isNotEmpty){
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    return TaskWidget(
                        taskId: snapshot.data.docs[index]['taskId'],
                        taskTitle: snapshot.data.docs[index]['taskTitle'],
                        taskCategory: snapshot.data.docs[index]['taskCategory'],
                        taskDescription: snapshot.data.docs[index]['taskDescription'],
                        uploayBy: snapshot.data.docs[index]['uploadedBy'],
                        isDone: snapshot.data.docs[index]['isDone'],
                        deadlineDate: snapshot.data.docs[index]['deadlineDate']);
                  });
            }
            else{
              return Center(child:Text("no employee enter yet!"));
            }
          }
          return Center(child:Text("something went wrong!"));
        },
      )

    );
  }

  void showTaskCategoryDialog(context, size){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Task Category",
              style: TextStyle(
                  color: Colors.pink.shade300, fontSize: 20),
            ),
            content: Container(
              width: size.width*0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.taskCategoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: ()
                      {
                        setState(() {
                          taskCategory = Constants.taskCategoryList[index];
                        });
                        Navigator.canPop(context)? Navigator.pop(context) : null;

                        print("you pressed on  ${Constants.taskCategoryList[index]}");
                        },
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.red[200],),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Constants.taskCategoryList[index],
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic
                              ),
                            ),
                          ),
                        ],),
                    );
                  }),
            ),
            actions: [
              TextButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  }),
              TextButton(
                child: Text("cancel filter", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  setState(() {
                    taskCategory = null;
                  });
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
              ),
            ],
          );
        });
  }
}