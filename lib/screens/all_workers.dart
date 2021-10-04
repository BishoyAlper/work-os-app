import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_os_app/constant/constants.dart';
import 'package:work_os_app/widgets/drawer_widget.dart';
import 'package:work_os_app/widgets/tasks_widgets.dart';
import 'package:work_os_app/widgets/workers_widget.dart';

class AllWorkersScreen extends StatelessWidget{

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'All worker',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
         stream: FirebaseFirestore.instance.collection("users").snapshots(),
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
                     return AllWorkersWidget(
                       userId: snapshot.data.docs[index]['id'],
                       name: snapshot.data.docs[index]['name'],
                       imagURL: snapshot.data.docs[index]['userImageURL'],
                       phoneNumber: snapshot.data.docs[index]['phoneNumber'],
                       CMposition: snapshot.data.docs[index]['possisionInCompany'],
                       email:snapshot.data.docs[index]['email']
                     );
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
}