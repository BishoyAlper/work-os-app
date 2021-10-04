import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:work_os_app/widgets/drawer_widget.dart';

import '../../services.dart';
import '../../user_state.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  ProfileScreen(@required this.userId);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>{
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String phoneNumber = "";
  String name = "";
  String job = "";
  String mail = "";
  String imageURL;
  String joinAt = "";
  bool isSameUser = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  void getUserData() async{
    _isLoading = true;

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(widget.userId).get();

      if(userDoc == null)
      {
        return;
      }
      else
      {
        setState(() {
          name = userDoc.get("name");
          mail = userDoc.get("email");
          imageURL = userDoc.get("userImageURL");
          phoneNumber = userDoc.get("phoneNumber");
          job = userDoc.get("possisionInCompany");
          Timestamp joinAtTimeStamp = userDoc.get("createdAt");
          var joinDate = joinAtTimeStamp.toDate();
          joinAt = "${joinDate.year}-${joinDate.month}-${joinDate.day}";
        });
        User user = _auth.currentUser;
        String id = user.uid;

        setState(() {
          isSameUser = widget.userId==id;
        });
        print("is same id ${isSameUser}");
      }
    } catch (error){
      GlobalMethods.showErrorDialog(error: "$error", context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black54),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top:0.0),
          child: Center(
            child: Stack(
              children: [
                Card(
                  margin: EdgeInsets.all(30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 80,),
                        Center(
                          child: Text("$name",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal
                              )),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text("$job Since joined at $joinAt)",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal
                              )),
                        ),
                        SizedBox(height: 15,),
                        Divider(thickness: 1,),
                        SizedBox(height: 15,),
                        Text("Contact Info",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal
                            )),
                        SizedBox(height: 10),
                        socialInfo(label: "Email", content: mail),
                        SizedBox(height: 10),
                        socialInfo(label: "Phone nummber", content: phoneNumber),
                        SizedBox(height: 30),
                        isSameUser ? Container() :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            socialButton(
                                color: Colors.green,
                                icon: FontAwesome.whatsapp,
                                fun:(){
                                  _openWhatsAppChat();
                                }),
                            socialButton(
                                color: Colors.red,
                                icon: Icons.mail_outline_outlined,
                                fun:(){
                                  _mailTo();
                                }),
                            socialButton(
                                color: Colors.purple,
                                icon: Icons.call_outlined,
                                fun:(){
                                  _callsPhoneNumber();
                                }),
                          ],
                        ),
                        SizedBox(height: 20),
                        !isSameUser ? Container():
                        Divider(thickness: 1,),
                        SizedBox(height: 20,),
                        !isSameUser ? Container():
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: MaterialButton(
                              onPressed:() async{
                              await _auth.signOut();
                              Navigator.canPop(context) ? Navigator.pop(context) : null;
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>UserState()));
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
                                  Icon(Icons.logout , color: Colors.white,),
                                  SizedBox(width: 10,),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text("LogOut",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                     ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(width: 5, color: Theme.of(context).scaffoldBackgroundColor),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(imageURL==null ? "https://www.pngfind.com/pngs/m/110-1102775_download-empty-profile-hd-png-download.png": imageURL),
                          fit: BoxFit.fill
                )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget socialInfo({@required String label, @required String content}){
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: TextStyle(
                color: Colors.blueAccent,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                ),
          ),
        ),
      ],
    );
  }

  void _openWhatsAppChat() async{
    var whatsAppURL = 'https://wa.me/$phoneNumber?text=helloThere';
    if(await canLaunch(whatsAppURL)){
      await launch(whatsAppURL);
    }else{
      throw 'Error occured coldun\'topen link';
    }

  }

  void _mailTo() async{
    var url = "mailto:$mail";

    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Error occured coldun\'topen link';
    }
  }

  void _callsPhoneNumber() async {
    var phoneUrl = "tel://$phoneNumber";

    if (await canLaunch(phoneUrl)) {
      launch(phoneUrl);
    } else {
      throw 'Error occured coldun\'topen link';
    }
  }

  Widget socialButton({@required Color color, @required IconData icon, @required Function fun}){
    return CircleAvatar(
      radius: 25,
      backgroundColor: color,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: color,),
          onPressed: (){
            fun();
            },
        ),
      ),
    );
  }
}