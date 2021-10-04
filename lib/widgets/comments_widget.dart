import 'package:flutter/material.dart';
import 'package:work_os_app/screens/inner_screen/profile.dart';

class CommentsWidget extends StatelessWidget{
  List<Color> _colors = [
    Colors.green.shade600,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.brown,
    Colors.blue,
  ];

  final String commentId;
  final String commenterId;
  final String ImageUrl;
  final String name;
  final String commentBody;

  CommentsWidget({
    @required this.ImageUrl,
    @required this.name,
    @required this.commentBody,
    @required this.commenterId,
    @required this.commentId
  });

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    // TODO: implement build
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder:(context)=> ProfileScreen(commenterId)));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 5,),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: _colors[0]),
              shape: BoxShape.circle,
              image: DecorationImage(image: NetworkImage(
                ImageUrl == null ? "https://jlg.ro/wp-content/uploads/2020/09/empty-avatar.png" : ImageUrl,
              ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      name == null ? "" : name,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(commentBody == null ? "" : commentBody),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}