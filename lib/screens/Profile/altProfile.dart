import 'package:flutter/material.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/screens/Profile/profileHelpers.dart';
class altProfile extends StatelessWidget
{
  ConstantColors constColors = ConstantColors();
  String? userid;
  altProfile({@required this.userid});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: constColors.blueGreyColor.withOpacity(0.6),
      leading: IconButton(onPressed: () {Navigator.of(context).pop();},icon: Icon(Icons.arrow_back_ios), color: constColors.whiteColor.withOpacity(0.4),),
      title: RichText(
      text: TextSpan(
        text: 'We',
        style: TextStyle(
          color: constColors.whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        children:
        [
          TextSpan(
            text: 'Connect',
            style: TextStyle(
            color: constColors.blueColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
        ),)
        ]
      ),
    ),),
        body: SingleChildScrollView(
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
                stream: FirebaseFirestore.instance.collection("users").doc(userid).snapshots(),
                builder: (context, snapshot)
                {
                  if(snapshot.connectionState==ConnectionState.waiting)
                  {
                    return Center(child: CircularProgressIndicator());
                  }
                  else
                  {

                    return Column(children:
                    [
                      Provider.of<ProfileHelpers>(context, listen: false).HeaderProfile(context, snapshot),
                    //  Provider.of<ProfileHelpers>(context, listen: false).customDivider(context),
                      userid==Provider.of<Authentication>(context, listen: false).getUserUid()?Container():
                      FollowMessageButtons(snapshot: snapshot),
                      Provider.of<ProfileHelpers>(context, listen: false).userDescription(context, snapshot),

                      //  Provider.of<ProfileHelpers>(context, listen: false).followMessageButtons(context, snapshot),
                    //  Provider.of<ProfileHelpers>(context, listen: false).middleProfile(context, snapshot),
                      SizedBox(height: 40),

                      Provider.of<ProfileHelpers>(context, listen: false).lowerProfile(context, snapshot),



                    ],);
                  }
                },
              ),
            ),
          ),));

  }
}
