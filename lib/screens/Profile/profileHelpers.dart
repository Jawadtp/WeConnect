import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import '../../database/auth.dart';
import '../login/login.dart';
import 'dart:developer';

class ProfileHelpers with ChangeNotifier
{
  ConstantColors constColors = ConstantColors();

  Widget HeaderProfile(BuildContext context, dynamic snapshot)
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,12,0,0),
      child: SizedBox(

        height: MediaQuery.of(context).size.height*0.23,
        width: MediaQuery.of(context).size.width,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
          [

            Container(
              height: 200,
              width: 160,
          //    color: Colors.white,
              child: Column(
                children:
                [
                  GestureDetector(
                    onTap: ()
                    {
                      // To implement: Profile picture to be changed
                    },
                    child: CircleAvatar(
                      backgroundColor: constColors.transparent,
                      radius: 60.0,
                      backgroundImage: NetworkImage(snapshot.data.get('userimage')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        snapshot.data.get('username'),
                      style: TextStyle(
                          color: constColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Column(
                children: [

                  Row(
                    children:
                    [

                      Container(
                        decoration: BoxDecoration(
                          color: constColors.darkColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 70,
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(

                            children:
                            [
                              Text(
                                '0',
                                style: TextStyle(
                                    color: constColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                    color: constColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        height: 70,
                        width: 80,
                        decoration: BoxDecoration(
                          color: constColors.darkColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children:
                            [
                              Text(
                                '0',
                                style: TextStyle(
                                    color: constColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28
                                ),
                              ),
                              Text(
                                'Following',
                                style: TextStyle(
                                    color: constColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],),
                  SizedBox(height: 10,),
                  Container(
                    height: 70,
                    width: 80,
                    decoration: BoxDecoration(
                      color: constColors.darkColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children:
                        [
                          Text(
                            '0',
                            style: TextStyle(
                                color: constColors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 28
                            ),
                          ),
                          Text(
                            'Posts',
                            style: TextStyle(
                                color: constColors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customDivider(context)
  {
    return Container(
      width: MediaQuery.of(context).size.width*0.82,
      height: 0.5,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget middleProfile(context, dynamic snapshot)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children:
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(children:
            [
              Icon(FontAwesomeIcons.userAstronaut, color: constColors.yellowColor, size: 15,),
              SizedBox(width: 6,),
              Text('Recently added', style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold),),
            ],),
          ),
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width*0.9,
            decoration: BoxDecoration(
              color: constColors.darkColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10)
            ),
          )
        ],
      ),
    );
  }
  Widget lowerProfile(context, dynamic snapshot)
  {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
          color: constColors.darkColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)
      ),
    );
  }

  Widget logoutDialog(context)
  {

    return AlertDialog(
      backgroundColor: constColors.darkColor,
      title: Text(
          'Log out of WeConnect?',
          style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      actions: 
      [
        MaterialButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          child: Text(
            'No',
            style: TextStyle(
                color: constColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,

            ),
          ),
        ),
        MaterialButton(
          onPressed: ()
          {
            Provider.of<Authentication>(context, listen: false).emailLogOut().whenComplete(()
            {
              Navigator.pushReplacement(context, PageTransition(child: Login(), type: PageTransitionType.leftToRight));

            });
          },
          child: Text(
            'Yes',
            style: TextStyle(
              color: constColors.redColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,

            ),
          ),
        ),
      ],

    );
  }
}