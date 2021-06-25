import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/Home/home.dart';
import 'package:socialmedia/sharedPref/sharedPref.dart';
import 'loginHelper.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'loginUtils.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with ChangeNotifier {
  final ConstantColors constColors = ConstantColors();
  TextEditingController emailController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();
  TextEditingController usernameController= new TextEditingController();
  bool isLoading=false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constColors.whiteColor,  body: Column(children:
    [
      bodyColor(Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            SizedBox(height: 100),
        Container(
          height: MediaQuery.of(context).size.height*0.8,
          padding: EdgeInsets.symmetric(horizontal: 30),
          margin: EdgeInsets.only(left: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white.withOpacity(0.8), size: 25,),
                    onPressed: ()
                  {
                    Navigator.pop(context);
                  },),
                  Text('Create an account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
                  Spacer()
                ],
              ),

              SizedBox(height: 30),


              Center(child: Provider.of<LoginHelpers>(context, listen: true).imagePickerAvatar(context),),

              SizedBox(height: 30),
              Text('Please enter details to continue', style: TextStyle(color: Colors.white.withOpacity(0.5),  fontSize: 16)),
              SizedBox(height: 30),
              Container(
                height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  width: MediaQuery.of(context).size.width*0.8,
                  child:
                  Row(children:
                  [
                    SizedBox(width: 10),
                    Icon(Icons.person, color: Colors.white.withOpacity(0.6),),
                    Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        child: TextFormField(
                          validator: (value)
                          {
                            if(value==null || value.length<3) return 'Username must have at least 3 characters';
                          },
                          controller: usernameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              errorStyle: TextStyle(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              border: InputBorder.none,
                              hintText: 'USERNAME',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)
                          ),

                        )
                    ),
                  ],)
              ),

              SizedBox(height: 20),

              Container(
                  height: 50,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  width: MediaQuery.of(context).size.width*0.8,
                  child:
                  Row(children:
                  [
                    SizedBox(width: 10),
                    Icon(Icons.email, color: Colors.white.withOpacity(0.7),),
                    Container(
                        width: MediaQuery.of(context).size.width*0.6,
                        child: TextFormField(
                          validator: (value)
                          {
                            if(value==null || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) return 'Enter a valid email address.';
                          },
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              border: InputBorder.none,
                              hintText: 'EMAIL',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)
                          ),

                        )
                    ),
                  ],)
              ),

              SizedBox(height: 20),

              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  width: MediaQuery.of(context).size.width*0.8,
                  child:
                  Row(children:
                  [
                    SizedBox(width: 10),
                    Icon(Icons.lock, color: Colors.white.withOpacity(0.7),),
                    Container(
                        width: MediaQuery.of(context).size.width*0.6,
                        child: TextFormField(
                          validator: (value)
                          {
                            if(value==null || value.length < 6) return 'At least 6 characters required';
                          },
                          controller: passwordController,
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(

                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              border: InputBorder.none,
                              hintText: 'PASSWORD',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)
                          ),

                        )
                    ),
                  ],)
              ),
              SizedBox(height: 50),
              Center(
                child: InkWell(
                  onTap: () async
                  {
                    if(!_formKey.currentState!.validate()) return;
                    if(Provider.of<LoginUtils>(context, listen: false).pickedFile==null)
                      return Provider.of<LoginHelpers>(context, listen: false).WarningSheet(context, 'Please pick a user avatar');
                    setState(() {
                      isLoading=true;
                    });
                    Provider.of<Authentication>(context, listen: false).createAccount(emailController.text, passwordController.text).whenComplete(()
                    {
                      if(Provider.of<Authentication>(context, listen: false).getUserUid()==null) log('Invalid email ID');

                      else Provider.of<FirebaseOperations>(context, listen: false).uploadUserAvatar(context).whenComplete(()
                      {
                        log('Photourl: ${Provider.of<LoginUtils>(context, listen: false).getAvatarURL()}');
                        Map<String, dynamic> data =
                        {
                          'userid': Provider.of<Authentication>(context, listen: false).getUserUid(),
                          'username':usernameController.text,
                          'useremail':emailController.text,
                          'userimage':Provider.of<LoginUtils>(context, listen: false).getAvatarURL(),
                          'followers':0,
                          'following':0,
                          'posts':0,
                          'description': "",
                        };
                        Provider.of<FirebaseOperations>(context, listen: false).createUserCollection(context, data).whenComplete(() async
                        {
                          if( Provider.of<Authentication>(context, listen: false).getUserUid()==null)
                            {
                              setState(() {
                                isLoading=false;
                              });
                              return;
                            }
                          SharedPrefs.saveUserID('${Provider.of<Authentication>(context, listen: false).getUserUid()}');
                          await Provider.of<FirebaseOperations>(context, listen: false).initUserData(context);
                          Navigator.pushReplacement(context, PageTransition(child: Home(), type: PageTransitionType.leftToRight));
                          setState(() {
                            isLoading=false;
                          });
                        });


                      });

                    });
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 55, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF45f7bf),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: !isLoading?Text('SIGN UP', style: TextStyle(color: Colors.black, fontSize: 16)):
                          CircularProgressIndicator()
                  ),
                ),
              ),
              Spacer(),
              Center(
                child: Row(
                  children:
                  [
                    Spacer(),
                    Text("Already have an account?  ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                    InkWell(
                        onTap: ()
                        {
                          Navigator.pop(context);
                        },
                        child: Text('Sign in', style: TextStyle(color: Color(0xFF45f7bf),fontSize: 16, fontWeight: FontWeight.bold))),
                    Spacer(),
                  ],),
              )
            ],),
        )
          ],),
      )),

    ],),);
  }

  Widget bodyColor(Widget child)
  {
    return Expanded(
      child: Container(decoration: BoxDecoration
        (gradient: LinearGradient
        (begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.5, 0.9],
          colors:
          [constColors.darkColor,
            constColors.blueGreyColor
          ]

      )),child: child,),
    );
  }
}
