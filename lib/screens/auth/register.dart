import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_os_app/constant/constants.dart';
import 'package:work_os_app/screens/auth/login.dart';
import 'package:work_os_app/screens/auth/tasks.dart';

import '../../services.dart';

class RegisterScreen extends StatefulWidget {


  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

//بستخدم mixin عشان اعرف استخدم الanimation
class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin{

  AnimationController _animationController;
  Animation<double> _animation;
  TextEditingController _emailTextController = TextEditingController(text: "");
  TextEditingController _passwordTextController = TextEditingController(text: "");
  TextEditingController _phoneNumController = TextEditingController(text: "");
  TextEditingController _fullNameTextController = TextEditingController(text: "");
  TextEditingController _cpPositionTextController = TextEditingController(text: "company position");


  FocusNode _fullNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _cpPositionFocusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  
  File fileImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool obsecure = true;
  final _loginFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String url;

  //dispose عشان الغي شغل هذا الكونترال داخل الميموري لو انا هنتقل لصفحة تانية
  @override
  void dispose(){
    _animationController?.dispose();
    _emailTextController?.dispose();
    _passwordTextController?.dispose();
    _phoneNumController?.dispose();
    _fullNameTextController?.dispose();
    _cpPositionTextController?.dispose();

    _fullNameFocusNode?.dispose();
    _phoneFocusNode?.dispose();
    _emailFocusNode?.dispose();
    _passwordFocusNode?.dispose();
    _cpPositionFocusNode?.dispose();

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
      if(fileImage == null){
        GlobalMethods.showErrorDialog(error: "please enter an image", context: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try{
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.toLowerCase().trim(),
            password: _passwordTextController.text.trim());

        final User user = _auth.currentUser;
        final _uid = user.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child("userImage")
            .child(_uid + ".jpg");
        await ref.putFile(fileImage);
        url = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection("users").doc(_uid).set(
            {
              "id": _uid,
              "name": _fullNameTextController.text,
              "email": _emailTextController.text,
              "password" : _passwordTextController.text,
              "userImageURL": url,
              "phoneNumber": _phoneNumController.text,
              "possisionInCompany": _cpPositionTextController.text,
              "createdAt": Timestamp.now(),
            }
        );

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
                Text('Register', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),),
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "I Already have an account?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white
                          )),
                      TextSpan(text: " "),
                      TextSpan(text: "LogIn",
                          recognizer: TapGestureRecognizer()..onTap=()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen())),
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
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: textFormField(
                                focusNode: _fullNameFocusNode,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: (){FocusScope.of(context).requestFocus(_fullNameFocusNode);},
                                valueKey: "FullName",
                                controller: _fullNameTextController,
                                textInputTpe: TextInputType.text,
                                text: "Full Name"),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width:100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1, color: Colors.white),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: fileImage == null? Image.network("https://jlg.ro/wp-content/uploads/2020/09/empty-avatar.png", fit: BoxFit.fill,)
                                            : Image.file(fileImage, fit: BoxFit.fill,),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: (){
                                        showImageDialog();
                                        },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                          border: Border.all(width: 2, color:Colors.white),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Icon(fileImage == null ? Icons.add_a_photo : Icons.edit, size: 18, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      textFormField(
                          focusNode: _emailFocusNode,
                          onEditingComplete:(){FocusScope.of(context).requestFocus(_emailFocusNode);},
                          textInputAction: TextInputAction.next,
                          valueKey: "emailValueKey",
                          controller: _emailTextController,
                          textInputTpe: TextInputType.emailAddress,
                          text: 'Email'),
                      SizedBox(height: 10),
                      //password form field
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: ()=> FocusScope.of(context).requestFocus(_cpPositionFocusNode),
                        validator: (value){
                          if(value.isEmpty || value.length>7){
                            return 'please enter valid password num';
                          }
                          return null;
                        },
                        obscureText: obsecure,
                        key: ValueKey("password"),
                        controller: _passwordTextController,
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
                      SizedBox(height: 10,),
                      //phone num
                      textFormField(
                          focusNode: _phoneFocusNode,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=> FocusScope.of(context).requestFocus(_phoneFocusNode),
                          valueKey: "PhoneNumber",
                          controller: _phoneNumController,
                          textInputTpe: TextInputType.phone,
                          text: 'Phone Num'),
                      SizedBox(height: 10,),
                      textFormField(
                          fun: ()
                          {
                            showTaskCategoryDialog(size);
                            },
                          focusNode: _cpPositionFocusNode,
                          enabled: false,
                          valueKey: "CompanyPosition",
                          textInputAction: TextInputAction.done,
                          onEditingComplete: (){submitionFormOnLogin();},
                          controller: _cpPositionTextController,
                          text: "Company Position"),
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(onPressed: (){},
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
                _isLoading ? Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    )) :
                MaterialButton(onPressed:(){
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
                        child: Text("SignUp",
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

  Widget textFormField({
    Function fun,
    bool enabled,
    @required Function onEditingComplete,
    @required FocusNode focusNode,
    @required String valueKey,
    @required TextInputAction textInputAction,
    @required TextEditingController controller,
    @required TextInputType textInputTpe,
    @required String text,
  }){
     return GestureDetector(
       onTap: (){
         fun();
       },
       child: TextFormField(
        focusNode: focusNode,
        enabled: enabled,
        textInputAction: textInputAction,
        onEditingComplete: ()=> onEditingComplete,
        validator: (value){
          if(value.isEmpty){
            return 'Field can\'t be missed';
          }
          return null;
        },
        controller: controller,
         key: ValueKey(valueKey),
         style: TextStyle(color: Colors.black, fontSize: 20),
        keyboardType: textInputTpe,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(color: Colors.black, fontSize: 20),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.pink.shade700)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        ),
    ),
     );
  }
  
  void _pickedImageWithCamera() async {
    try
    {
      final pickedFile = await _picker.getImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      // setState(() {
      //   fileImage = File(pickedFile.path);
      // });
      imageCropper(pickedFile.path);
    } catch(error)
    {
      GlobalMethods.showErrorDialog(error: "$error", context: context);
    }


    Navigator.pop(context);
  }

  void imageCropper(pathImage) async{
    File cropImage = await ImageCropper.cropImage(sourcePath: pathImage, maxHeight: 1080, maxWidth: 1080);

    if(cropImage != null){
      setState(() {
        fileImage = cropImage;
      });
    }
  }

  void _pickedImageWithGallury() async {
    try{
      final pickedFlie = await _picker.getImage(
          source: ImageSource.gallery,
          maxWidth: 1080,
          maxHeight: 1080);
      // setState(() {
      //   fileImage = File(pickedFlie.path);
      // });
      imageCropper(pickedFlie.path);
    } catch(error){
      GlobalMethods.showErrorDialog(error: "$error", context: context);
    }
    Navigator.pop(context);
  }

  void showImageDialog(){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("please choose an option", style: TextStyle(fontSize: 22),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                  InkWell(
                    onTap: (){
                      _pickedImageWithCamera();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.purple, size: 25,),
                        SizedBox(width: 5,),
                        Text("Camera", style: TextStyle(color: Colors.purple, fontSize: 25),),
                      ],
              ),
                  ),
                  InkWell(
                    onTap: (){
                      _pickedImageWithGallury();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image, color: Colors.purple, size: 25),
                        SizedBox(width: 5,),
                        Text("Gallery", style: TextStyle(color: Colors.purple, fontSize: 25),),
                      ],
              ),
                  ),
            ],
          ),
        );
      }
    );
  }

  void showTaskCategoryDialog(size){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Jobs",
              style: TextStyle(
                  color: Colors.pink.shade300, fontSize: 20),
            ),
            content: Container(
              width: size.width*0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.jobList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: (){
                        setState(() {
                          _cpPositionTextController.text = Constants.jobList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.red[200],),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Constants.jobList[index],
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
}