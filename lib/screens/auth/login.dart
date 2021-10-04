import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:work_os_app/screens/auth/foget_password.dart';
import 'package:work_os_app/screens/auth/register.dart';
import 'package:work_os_app/screens/auth/tasks.dart';

import '../../services.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

//بستخدم mixin عشان اعرف استخدم الanimation
class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin{

  AnimationController _animationController;
  Animation<double> _animation;
  TextEditingController _emailTextController = TextEditingController(text: "");
  TextEditingController _passTextController = TextEditingController(text: "");
  bool obsecure = true;
  final _loginFormKey = GlobalKey<FormState>();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;


  //dispose عشان الغي شغل هذا الكونترال داخل الميموري لو انا هنتقل لصفحة تانية
  @override
  void dispose(){
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _emailFocusNode.dispose();

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

  void submitionFormOnLogin() async{
    final isValid = _loginFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if(isValid){
      setState(() {
        _isLoading = true;
      });
      try{
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.toLowerCase().trim(),
            password: _passTextController.text.trim());
        Navigator.canPop(context) ? Navigator.pop(context) : null;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>TasksScreen()));
      } catch(error) {
        setState(() {
          _isLoading = false;
        });
        print("error occured $error");
        GlobalMethods.showErrorDialog(error: error.toString(), context: context);
      }
    }
    else{
      print("is not valid");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
                Text('Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),),
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "Don\'t have an account?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white
                          )),
                      TextSpan(text: " "),
                      TextSpan(text: "Register",
                          recognizer: TapGestureRecognizer()..onTap=()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RegisterScreen())),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              color: Colors.blue.shade300)),
                    ],
                  ),
                ),
                SizedBox(height: size.height*0.05,),
                //E-mail form field
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: ()=> FocusScope.of(context).requestFocus(_passFocusNode),
                        validator: (value){
                          if(value.isEmpty || !value.contains('@')){
                            return 'please enter valid email num';
                          }
                          return null;
                        },
                        key : ValueKey("email"),
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
                      SizedBox(height: 10,),
                      //password form field
                      TextFormField(
                        focusNode: _passFocusNode,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: ()=> submitionFormOnLogin(),
                        validator: (value){
                          if(value.isEmpty || value.length>7){
                            return 'please enter valid password num';
                          }
                          return null;
                        },
                        obscureText: obsecure,
                        key: ValueKey("passwordValueKey"),
                        controller: _passTextController,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: (){
                              setState(() {
                                obsecure= !obsecure;
                              });
                            },
                            child: obsecure? Icon(Icons.visibility_off):Icon(Icons.visibility),
                          ),
                          hintText: 'password',
                          hintStyle: TextStyle(color: Colors.black, fontSize: 20),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.pink.shade700)),
                          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                Align(
                  alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: ()
                      {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ForgetPasswordScreen()));
                      },
                      child: Text("Forget Password",
                          style:TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic)
                      ),
                    ),
                ),
                SizedBox(height: 40,),
            _isLoading ? Center(child: Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ))
                : MaterialButton(onPressed:(){
              submitionFormOnLogin();
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
                    child: Text("Sigin",
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Icon(Icons.person_add, color: Colors.white,)
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

  void showErrorDialog(context,error){
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