import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/login/loginUtils.dart';
import '../../database/auth.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import '../Home/home.dart';
import 'dart:developer';
import '../login/loginServices.dart';
import 'dart:io';
import 'dart:core';

class LoginHelpers with ChangeNotifier
{
  ConstantColors constColors = ConstantColors();

  Widget Logo(BuildContext context)
  {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("We",style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 30),),
            Text("Connect",style: TextStyle(color: constColors.blueColor, fontSize: 40),)
          ],
        ),

      ],
    );
  }

  Widget HelperText(BuildContext context)
  {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kickstart your ',  style: TextStyle(fontSize: 30, color: constColors.whiteColor ),),
        Text('social experience', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: constColors.lightBlueColor ),),
        Text('now!', style: TextStyle(fontSize: 35, color: constColors.whiteColor ),),

      ],
    );
  }

  Widget googleButton(BuildContext context)
  {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: ()
          {
            log('Tapped');
            Provider.of<Authentication>(context, listen: false).signInWithGoogle().whenComplete(()
            {
              if( Provider.of<Authentication>(context, listen: false).getUserUid()==null) return;
              Navigator.pushReplacement(context, PageTransition(child: Home(), type: PageTransitionType.leftToRight));

            });

          },
          child: Container(padding: EdgeInsets.all(8),

            decoration: BoxDecoration(color: Color(0xFFDB4437), borderRadius: BorderRadius.circular(10)),

            child: Row(
              children: [
                Icon(EvaIcons.google, size: 40, color: constColors.whiteColor,),
                SizedBox(width: 10,),
                Text('Sign in with Google', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: constColors.whiteColor ),),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget EmailLoginButton(BuildContext context)
  {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: ()
          {
            log('Tapped');
            emailAuthSheet(context);

          },
          child: Container(padding: EdgeInsets.all(8),

            decoration: BoxDecoration(color: Color(0xFFDB4437), borderRadius: BorderRadius.circular(10)),

            child: Row(
              children: [
                Icon(EvaIcons.email, size: 40, color: constColors.whiteColor,),
                SizedBox(width: 10,),
                Text('Email Sign In', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: constColors.whiteColor ),),

              ],
            ),
          ),
        ),
      ],
    );
  }
  
  emailAuthSheet(BuildContext context)
  {
    return showModalBottomSheet(context: context, builder: (context)
    {
      return Container(child: Column(children:
      [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150.0),
          child: Divider(thickness: 4.0, color: constColors.whiteColor,),
        ),
        Provider.of<LoginServices>(context, listen: false).PasswordLessSignIn(context),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
        [
          MaterialButton(onPressed: ()
          {
            LoginSheet(context);

          }, child: Text('Login', style: TextStyle(color: constColors.blueColor, fontSize: 18.0, fontWeight: FontWeight.bold),),),
          MaterialButton(onPressed: ()
          {
            SignInSheet(context);

          }, child: Text('Sign Up', style: TextStyle(color: constColors.redColor, fontSize: 18.0, fontWeight: FontWeight.bold),),)

        ],),
      ],),
        height: MediaQuery.of(context).size.height*0.5,
      width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constColors.blueGreyColor,
         borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      );
    });
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  SignInSheet(BuildContext context)
  {
    return showModalBottomSheet(context: context, isScrollControlled: true, builder: (context)
    {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*0.55,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: constColors.darkColor),
          child: Column(
            children:
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
            child: Divider(thickness: 4, color: constColors.whiteColor,),
          ),
          GestureDetector(onTap:()
          {

            Provider.of<LoginUtils>(context, listen: false).pickUserAvatar(context, ImageSource.gallery);

            },child: Provider.of<LoginUtils>(context, listen: false).pickedFile!=null?CircleAvatar(backgroundColor: constColors.redColor, radius: 60.0,  backgroundImage:
              FileImage(
              File(Provider.of<LoginUtils>(context, listen: false).pickedFile!.path)
      ),):CircleAvatar(backgroundColor: constColors.redColor, radius: 60.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: TextField(controller: usernameController,style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Please enter your name', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)),),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: TextField(controller: emailController, style: TextStyle(color: Colors.white),decoration: InputDecoration(hintText: 'Please enter your email ID', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)),),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
            child: TextField(controller: passwordController, obscureText: true, style: TextStyle(color: Colors.white),decoration: InputDecoration(hintText: 'Please enter your password', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)),),
          ),
          FloatingActionButton(backgroundColor: constColors.redColor,
            onPressed: ()
          {
            if(emailController.text.isNotEmpty)
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
                    Provider.of<FirebaseOperations>(context, listen: false).createUserCollection(context, data).whenComplete(()
                    {
                      if( Provider.of<Authentication>(context, listen: false).getUserUid()==null) return;
                      Navigator.pushReplacement(context, PageTransition(child: Home(), type: PageTransitionType.leftToRight));
                    });


                  });

              });
            else WarningSheet(context, 'Please enter a valid email ID');
            }, child: Icon(FontAwesomeIcons.check, color: constColors.whiteColor,),)
        ],),),
      );
    });
  }


  WarningSheet(BuildContext context, String warning)
  {
    return showModalBottomSheet(context: context, builder: (context)
    {
      return Container(decoration: BoxDecoration(color: constColors.darkColor, borderRadius: BorderRadius.circular(15)),
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width,
        child: Text(warning, style: TextStyle(color: constColors.whiteColor, fontSize: 16, fontWeight: FontWeight.bold),),
      );
    });
  }

  LoginSheet(BuildContext context)
  {
    return showModalBottomSheet(context: context, isScrollControlled: true, builder: (context)
    {
      return Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*0.32,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: constColors.blueGreyColor, borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12))),
          child: Column(children:
          [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
              child: Divider(thickness: 4, color: constColors.whiteColor,),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: TextField(controller: emailController, style: TextStyle(color: constColors.whiteColor), decoration: InputDecoration(hintText: 'Please enter your email ID', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 16.0)),),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 20),
              child: TextField(controller: passwordController,  style: TextStyle(color: constColors.whiteColor),obscureText: true, decoration: InputDecoration(hintText: 'Please enter your password', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 16.0)),),
            ),
            FloatingActionButton(backgroundColor: constColors.blueColor,
              onPressed: ()
            {
              if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty)
                Provider.of<Authentication>(context, listen: false).logIntoAccount(emailController.text, passwordController.text).whenComplete(()
                {
                  if(Provider.of<Authentication>(context, listen: false).getUserUid()==null) WarningSheet(context, 'Invalid user name or password');
                  else Navigator.pushAndRemoveUntil(context, PageTransition(child: Home(), type: PageTransitionType.leftToRight), (Route<dynamic> route) => false);

                });
              else WarningSheet(context, 'Please enter a valid email ID');
            }, child: Icon(FontAwesomeIcons.check, color: constColors.whiteColor,),)
          ],),
        ),
      );
    });
  }
}