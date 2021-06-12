import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/screens/Profile/profileHelpers.dart';
import '../../database/firebaseops.dart';
import '../../database/auth.dart';
import 'dart:developer';
import 'package:page_transition/page_transition.dart';
import 'package:socialmedia/screens/login/login.dart';

class Profile extends StatelessWidget {
  ConstantColors constColors  = ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: Icon(EvaIcons.settings2Outline),
        color: constColors.lightBlueColor,
        onPressed: ()
        {

        },
      ),
      actions:
      [
        IconButton(
          icon: Icon(EvaIcons.logOutOutline),
          color: constColors.redColor,
          onPressed: ()
          {
            showDialog(context: context, builder: (BuildContext context)
            {
              return Provider.of<ProfileHelpers>(context, listen: false).logoutDialog(context);

            });
          },
        ),

      ],
      backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
      title: RichText(
          text: TextSpan(
              text: 'My ',
              style: TextStyle(
                  color: constColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
              ),
              children:
              [
                TextSpan(
                  text: 'Profile',
                  style: TextStyle(
                    color: constColors.blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),)
              ]
          ),
      ),),body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: constColors.blueGreyColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).snapshots(),
                  builder: (context, snapshot)
                  {
                    if(snapshot.connectionState==ConnectionState.waiting)
                      {
                        return Center(child: CircularProgressIndicator());
                      }
                    else
                      {
                        log(snapshot.toString());
                        return Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                        [
                          Provider.of<ProfileHelpers>(context, listen: false).HeaderProfile(context, snapshot),
                          Provider.of<ProfileHelpers>(context, listen: false).userDescription(context, snapshot),

                          Provider.of<ProfileHelpers>(context, listen: false).customDivider(context),
                         // Provider.of<ProfileHelpers>(context, listen: false).middleProfile(context, snapshot),
                          SizedBox(height: 40),

                          Provider.of<ProfileHelpers>(context, listen: false).lowerProfile(context, snapshot),



                        ],);
                      }
                  },
                ),
      ),
            ),),);
  }
}
