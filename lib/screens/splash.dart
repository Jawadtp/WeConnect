import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'dart:async';
import 'package:page_transition/page_transition.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmedia/sharedPref/sharedPref.dart';

import 'Home/home.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{
  ConstantColors constColors = ConstantColors();

  String getString(String? x)
  {
    return x==null?'':x;
  }

  @override
  void initState()
  {
    Timer(Duration(seconds: 2), () async
    {
          SharedPrefs.getName().then((id) async
          {
            if(getString(id).isEmpty)    Navigator.pushReplacement(context, PageTransition(child: Login(), type: PageTransitionType.leftToRight));
            else
              {
                Provider.of<Authentication>(context, listen: false).setUserUid(id);
                await Provider.of<FirebaseOperations>(context, listen: false).initUserData(context);
                Navigator.pushAndRemoveUntil(context, PageTransition(child:
                Home(), type: PageTransitionType.leftToRight), (Route<dynamic> route) => false);
              }
          });
    }
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
      backgroundColor: constColors.darkColor,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("We",style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 30),),
              Text("Connect",style: TextStyle(color: constColors.blueColor, fontSize: 40),)
            ],
          ),
          Container(padding: EdgeInsets.all(12),child: Text("Engage and Entertain",style: TextStyle(color: Colors.white, fontSize: 18),)),


        ],
      )),
    );
  }
}
