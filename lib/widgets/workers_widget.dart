import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:work_os_app/screens/inner_screen/profile.dart';

class AllWorkersWidget extends StatefulWidget{
  final String userId;
  final String name;
  final String imagURL;
  final String phoneNumber;
  final String CMposition;
  final String email;

  const AllWorkersWidget({
    @required this.userId,
    @required this.name,
    @required this.imagURL,
    @required this.phoneNumber,
    @required this.CMposition,
    @required this.email
  });


  @override
  _AllWorkersWidgetState createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(widget.userId)));
        },
        title: Text(
          widget.name,
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
            Text("${widget.CMposition}/${widget.phoneNumber}",
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
            child: Image.network(
              widget.imagURL == null ?
              "https://sm.ign.com/ign_mear/news/p/psa-the-sp/psa-the-spider-man-no-way-home-trailer-has-seemingly-leaked_3jct.jpg" : widget.imagURL),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.mail_outline, color: Colors.pink[800],),
          onPressed: (){_mailTo();}),
      ),
    );
  }

  void _mailTo() async{
    var url = "mailto:${widget.email}";

    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Error occured coldun\'topen link';
    }
  }
}