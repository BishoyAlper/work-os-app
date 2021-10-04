import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:work_os_app/screens/auth/tasks.dart';
import 'package:work_os_app/services.dart';
import 'package:work_os_app/widgets/comments_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;
  final String uploadedBy;

  const TaskDetailScreen(
      {@required this.taskId, @required this.taskTitle, @required this.uploadedBy});

  @override
  TaskDetailScreenState createState() => TaskDetailScreenState();
}

class TaskDetailScreenState extends State<TaskDetailScreen> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  var contentInfo = TextStyle(
      color: Colors.blue.shade800, fontSize: 15, fontWeight: FontWeight.bold);

  String _authorName;

  bool _isLoading = false;

  String _authorPossition;
  String taskDescription;
  String taskTitle;

  bool _isDone;
  String userImageUrl;
  Timestamp postedDateTimeStamp;
  Timestamp deadlineDateTimeStamp;
  String postedDate;
  String deadlineDate;

  bool isDeadlineAvailabe = false;

  TextEditingController _commentedBodyController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _commentedBodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try{
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users").doc(widget.uploadedBy).get();

      if (userDoc == null) {
        return;
      } else {
        setState(() {
          _authorName = userDoc.get("name");
          _authorPossition = userDoc.get("possisionInCompany");
          userImageUrl = userDoc.get("userImageURL");
        });
      }

      final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
          .collection("tasks").doc(widget.taskId).get();

      if (taskDatabase == null) {
        return;
      } else {
        setState(() {
          taskTitle = taskDatabase.get("taskTitle");
          _isDone = taskDatabase.get("isDone");
          postedDateTimeStamp = taskDatabase.get("createdAt");
          deadlineDateTimeStamp = taskDatabase.get("deadlineDateTimestamp");
          var postDate = postedDateTimeStamp.toDate();
          postedDate = "${postDate.year}-${postDate.month}-${postDate.day}";
          deadlineDate = taskDatabase.get("deadlineDate");
          var date = deadlineDateTimeStamp.toDate();
          isDeadlineAvailabe = date.isAfter(DateTime.now());
        });
      }
    }catch (error){
      GlobalMethods.showErrorDialog(error: "something wrong", context: context);
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        elevation: 0,
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Back",
            style: TextStyle(
                fontSize: 20, color: Colors.blue, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                widget.taskTitle,
                style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Uploaed by",
                            style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),),
                          Spacer(),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.red),
                              shape: BoxShape.circle,
                              image: DecorationImage(image: NetworkImage(
                                userImageUrl == null
                                    ? "https://jlg.ro/wp-content/uploads/2020/09/empty-avatar.png"
                                    : userImageUrl,
                              ),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _authorName == null ? "" : _authorName,
                                style: contentInfo,
                              ),
                              Text(
                                _authorPossition == null
                                    ? ""
                                    : _authorPossition,
                                style: contentInfo,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(thickness: 1,),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Uploaded On",
                                style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Text(
                                "DeadLine Date",
                                style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                postedDate == null ? "" : postedDate,
                                style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic),),
                              SizedBox(height: 5,),
                              Text(
                                deadlineDate == null ? "" : deadlineDate,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Center(
                        child: Text(
                          isDeadlineAvailabe
                              ? "Still have enough time"
                              : "no time left",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              fontStyle: FontStyle.italic),),
                      ),
                      SizedBox(height: 10,),
                      Divider(thickness: 1,),
                      SizedBox(height: 10,),
                      Text(
                        "Done State",
                        style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          Flexible(
                            child: TextButton(
                                onPressed: () {
                              User user = _auth.currentUser;
                              String id = user.uid;
                              if (id == widget.uploadedBy) {
                                FirebaseFirestore.instance.collection("tasks")
                                    .doc(widget.taskId)
                                    .update({"isDone": true});
                                     getData();
                              } else {
                                    GlobalMethods.showErrorDialog(
                                        error: "you can't make change in this task ",
                                        context: context);
                                  }
                                },
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontSize: 15,
                                      decoration: _isDone == true
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      fontWeight: FontWeight.bold),)
                            ),
                          ),
                          Opacity(
                              opacity: _isDone == true ? 1 : 0,
                              child: Icon(Icons.check_box, color: Colors.green,)
                          ),
                          SizedBox(width: 40,),
                          Flexible(
                            child: TextButton(
                              
                              onPressed: () {
                              User user = _auth.currentUser;
                              String id = user.uid;
                              if (id == widget.uploadedBy) {
                                FirebaseFirestore.instance.collection("tasks")
                                    .doc(widget.taskId)
                                    .update({"isDone": false});
                                getData();
                              }else{
                                GlobalMethods.showErrorDialog(error: "you can't make change in this task ", context: context);
                              }
                            },
                              child: Text(
                                "Not Done Yet",
                                style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontSize: 15,
                                    decoration: _isDone == false
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Opacity(
                              opacity: _isDone == false ? 1 : 0,
                              child: Icon(Icons.check_box, color: Colors.red,)
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(thickness: 1,),
                      SizedBox(height: 10,),
                      Text(
                        "Task Description",
                        style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      Text(
                        taskDescription == null ? "" : taskDescription,
                        style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.normal),),
                      SizedBox(height: 20,),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: _isCommenting ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              flex: 3,
                              child: TextField(
                                maxLength: 200,
                                maxLines: 6,
                                controller: _commentedBodyController,
                                style: TextStyle(color: Colors.blueAccent),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Theme
                                      .of(context)
                                      .scaffoldBackgroundColor,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    MaterialButton(onPressed: () async{
                                     if(_commentedBodyController.text.length < 4){
                                       GlobalMethods.showErrorDialog(error: "please enter more than 4 charachter", context: context);
                                     }else{
                                       final _generatedId = Uuid().v4();
                                       await FirebaseFirestore
                                           .instance
                                           .collection("tasks")
                                           .doc(widget.taskId)
                                           .update({
                                         "taskComments": FieldValue.arrayUnion([{
                                           'uploadedBy': widget.uploadedBy,
                                           'commentedId' : _generatedId,
                                           'name' : _authorName,
                                           'commentedBody' : _commentedBodyController.text,
                                           'time' : Timestamp.now(),
                                           'userImageURL' : userImageUrl,
                                         }]),
                                       });

                                       await Fluttertoast.showToast(
                                           msg: "Task has been uploaded succefuly",
                                           toastLength: Toast.LENGTH_LONG,
                                           //gravity: ToastGravity.CENTER,
                                           timeInSecForIosWeb: 1,
                                           fontSize: 18.0
                                       );
                                       _commentedBodyController.clear();
                                       setState(() {});
                                     }
                                    },
                                      color: Colors.pink,
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide.none,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text("Post",
                                          style: TextStyle(
                                              color: Colors.white,
                                              //fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isCommenting = !_isCommenting;
                                        });
                                      },
                                      child: Text(
                                        "cancel",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ) : Center(
                          child: MaterialButton(onPressed: () {
                            setState(() {
                              _isCommenting = !_isCommenting;
                            });
                          },
                            color: Colors.pink,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text("Add a comment",
                                style: TextStyle(
                                    color: Colors.white,
                                    //fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("tasks").doc(widget.taskId).get(),
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if(snapshot == null){
                              return Container();
                            }
                            return ListView.separated(
                                reverse: true,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (ctx, index) {
                                  return CommentsWidget(
                                    ImageUrl: snapshot.data['taskComments'][index]['userImageURL'],
                                    name: snapshot.data['taskComments'][index]['name'],
                                    commentBody: snapshot.data['taskComments'][index]['commentedBody'],
                                    commenterId: snapshot.data['taskComments'][index]['uploadedBy'],
                                    commentId: snapshot.data['taskComments'][index]['commentedId'],
                                  );
                                },
                                separatorBuilder: (ctx, index) => Divider(thickness: 1,),
                                itemCount: snapshot.data['taskComments'].length);
                        }},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
