import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:work_os_app/screens/auth/register.dart';

class ForgetPasswordScreen extends StatefulWidget {

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

//بستخدم mixin عشان اعرف استخدم الanimation
class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> with TickerProviderStateMixin{

  AnimationController _animationController;
  Animation<double> _animation;
  TextEditingController _emailTextController;
  bool obsecure = true;
  final _loginFormKey = GlobalKey<FormState>();

  FocusNode _emailFocusNode = FocusNode();

  //dispose عشان الغي شغل هذا الكونترال داخل الميموري لو انا هنتقل لصفحة تانية
  @override
  void dispose(){
    _animationController?.dispose();
    _emailTextController?.dispose();
    _emailFocusNode?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 30));
    _animation = CurvedAnimation(parent: _animationController ,curve: Curves.linear)..addListener(() {
      setState(() {});
    })..addStatusListener((animationStatus) {
      if(animationStatus == AnimationStatus.completed){
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
    super.initState();
  }

  void forgetPassword(){


  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text("ForgetPassword"),),
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: "https://i.stack.imgur.com/GsDIl.jpg",
            placeholder: (context, url)=> Image.asset("assets/images/wallpaper.jpg", fit: BoxFit.cover),
            errorWidget: (context, url, error)=> Icon(Icons.error),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: FractionalOffset(_animation.value, 0),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children:
              [
                SizedBox(height: size.height*0.1,),
                Text('Forget Password', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),),
                SizedBox(height: 16),
                SizedBox(height: size.height*0.05,),
                //E-mail form field
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: ()=> forgetPassword,
                        validator: (value){
                          if(value.isEmpty || !value.contains('@')){
                            return 'please enter valid email num';
                          }
                          return null;
                        },
                        controller: _emailTextController,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.black, fontSize: 20),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.pink.shade700)),
                          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                        ),
                      ),
                      //password form field
                    ],
                  ),
                ),
                SizedBox(height: 40,),
                MaterialButton(onPressed:(){
                  forgetPassword();
                },
                  color: Colors.pink,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide.none,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text("Reset Password",
                          style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Icon(Icons.login, color: Colors.white,)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}