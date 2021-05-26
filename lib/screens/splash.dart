import 'package:flutter/material.dart';
import 'package:socialmedia/constants/colors.dart';
import 'dart:async';
import 'package:page_transition/page_transition.dart';
import 'package:socialmedia/screens/login/login.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{
  ConstantColors constColors = ConstantColors();

  @override
  void initState()
  {
    Timer(Duration(seconds: 2), () =>
          Navigator.pushReplacement(context, PageTransition(child: Login(), type: PageTransitionType.leftToRight))
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
