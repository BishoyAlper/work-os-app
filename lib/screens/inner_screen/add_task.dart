import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:work_os_app/constant/constants.dart';
import 'package:work_os_app/widgets/drawer_widget.dart';

import '../../services.dart';

class AddTaskScreen extends StatefulWidget{
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}
class _AddTaskScreenState extends State<AddTaskScreen>{
  TextEditingController _taskcategoryController = TextEditingController(text: "Task Category");
  TextEditingController _taskTitleController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  TextEditingController _deadlineDateController = TextEditingController(text: "Deadline Date");
  final _formKey = GlobalKey<FormState>();
  DateTime picked;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timestamp _deadlineDateTimestamp;
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _taskcategoryController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _deadlineDateController.dispose();
    super.dispose();
  }

  void uploadFct(){
    User user = _auth.currentUser;
    String _uid = user.uid;

    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if(isValid){
      if(_deadlineDateController.text == "Deadline Date" || _taskcategoryController.text == "Task Category"){
        GlobalMethods.showErrorDialog(error: "please pck up everything", context: context);
      return;
      }

      setState(() {
        _isLoading = true;
      });

      final taskId = Uuid().v4();
     try{
       FirebaseFirestore.instance.collection("tasks").doc(taskId).set({
         'taskId': taskId,
         'uploadedBy': _uid,
         'taskCategory': _taskcategoryController.text,
         'taskTitle': _taskTitleController.text,
         'taskDescription': _taskDescriptionController.text,
         'deadlineDate': _deadlineDateController.text,
         'deadlineDateTimestamp': _deadlineDateTimestamp,
         'taskComments':[],
         "isDone": false,
         'createdAt': Timestamp.now(),
       });
       Fluttertoast.showToast(
           msg: "Task has been uploaded succefuly",
           toastLength: Toast.LENGTH_LONG,
           //gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           fontSize: 18.0
       );
       _taskTitleController.clear();
       _taskDescriptionController.clear();
       setState(() {
         _taskcategoryController.text = "Task Category";

         _deadlineDateController.text = "pick up a date";

       });
     }catch (error){

     }finally {
       setState(() {
         _isLoading = false;
       });
      }

    }else{
      print("is not valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black54),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.center,
                  child: Text("All Fields Are Require",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),
            ),
                ),
                Divider(thickness: 1.0,),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textCategory(text: "Task Category*"),
                      textFormField(
                        fct: (){
                          showTaskCategoryDialog(size);
                        },
                        maxLength: 100,
                        controller: _taskcategoryController,
                        valueKey: "TaskCategory",
                        enabled: false,
                      ),
                      //for num2
                      textCategory(text: "Task title*"),
                      textFormField(
                        fct: (){},
                        maxLength: 100,
                        controller: _taskTitleController,
                        valueKey: "TaskTitle",
                        enabled: true,
                      ),
                      //for num3
                      textCategory(text: "Task Description*"),
                      textFormField(
                        fct: (){},
                        maxLength: 1000,
                        controller: _taskDescriptionController,
                        valueKey: "TaskDescriptionKey",
                        enabled: true,
                      ),
                      //for num3
                      textCategory(text: "Task DeadLine Date*"),
                      textFormField(
                        fct: (){
                          pickDate();
                        },
                        maxLength: 100,
                        controller: _deadlineDateController,
                        valueKey: "DeadlineDate",
                        enabled: false,
                      ),
                      SizedBox(height: 30,),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: _isLoading ? CircularProgressIndicator() :
                          MaterialButton(onPressed:(){
                            uploadFct();
                          },
                            color: Colors.pink,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide.none,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text("Upload",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Icon(Icons.upload_file , color: Colors.white,)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textFormField({
    @required TextEditingController controller,
    @required String valueKey,
    @required int maxLength,
    @required Function fct,
    @required bool enabled,
  }){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: (){
          fct();
        },
        child: TextFormField(
          controller: controller,
          validator: (value){
            if(value.isEmpty){
              return "Filled is missed";
            }
            return null;
          },
          key: ValueKey(valueKey),
          enabled: enabled,
          style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
          ),
          maxLines: valueKey=="TaskDescriptionKey" ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
          ),
        ),
      ),
    );
  }

  Widget textCategory({String text}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
          text,
          style: TextStyle(
              color: Colors.pink.shade800,
              fontSize: 18,
              fontWeight: FontWeight.bold
          )),
    );
  }

  void showTaskCategoryDialog(size){
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
                      onTap: (){
                        setState(() {
                          _taskcategoryController.text = Constants.taskCategoryList[index];
                        });
                        Navigator.pop(context);
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
              TextButton(onPressed: (){
                Navigator.canPop(context)?
                Navigator.pop(context)
                    : null;
              },
                  child: Text("close", style: TextStyle(fontSize:20),)),
            ],
          );
        });
  }

  void pickDate() async{
     picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days:0)),
      lastDate: DateTime(2100),
    );

     if(picked != null){
       setState(() {
         _deadlineDateTimestamp = Timestamp.fromMicrosecondsSinceEpoch(picked.microsecondsSinceEpoch);
         _deadlineDateController.text = "${picked.day}- ${picked.month}- ${picked.year}";
       });
     }
  }

}