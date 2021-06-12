import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/Chatroom/chatScreen.dart';
import 'package:socialmedia/screens/Home/home.dart';
import 'package:socialmedia/screens/Profile/altProfile.dart';
import 'package:socialmedia/screens/Profile/profileHelpers.dart';

import 'followButton.dart';

class Search extends StatefulWidget
{
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
{
  bool refresh=true;
  String textQuery="";
  ConstantColors constColors = ConstantColors();
  TextEditingController searchController = TextEditingController();
  QuerySnapshot? users=null;

  fetchUserList() async
  {
    FirebaseFirestore.instance.collection("users").get().then((value)
    {
      setState(() {
        users=value;
      });
    });
  }


  @override
  void initState()
  {
    fetchUserList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // resizeToAvoidBottomInset: false,
      appBar: AppBar
        (
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: constColors.blueGreyColor.withOpacity(0.4),

        title: Text('Search users', style: TextStyle(color: Colors.white)),

      ),
      body: ListView(//crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: constColors.blueGreyColor, borderRadius: BorderRadius.circular(10)),
            width: MediaQuery.of(context).size.width*0.9,
            child: TextField(onChanged: (val)
            {
              setState(() {
                textQuery=val;
              });
            },controller: searchController,style: TextStyle(color: Colors.white), decoration: InputDecoration(border: InputBorder.none,hintText: "Search", hintStyle: TextStyle(color: constColors.whiteColor.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 14.0), contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12), isDense: true
            ),),
          ),

          Container(
            child: users==null?Center(child:CircularProgressIndicator()):
            Container(
              margin: EdgeInsets.only(top: 15),
              height: MediaQuery.of(context).size.height*0.67,
              child: ListView.builder(
                  itemCount: users?.docs.length,
                  itemBuilder: (context, index)
                  {
                    if(!(users?.docs[index].get('username').toLowerCase().startsWith(textQuery.trim().toLowerCase())) && textQuery.trim().isNotEmpty)
                    {
                      if(!(users?.docs[index].get('username').toLowerCase().contains(textQuery.trim().toLowerCase())))
                        return Container();
                    }
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      margin: EdgeInsets.only(bottom: 0),
                      child:  InkWell(
                        onTap: ()
                        {
                          Navigator.push(context, PageTransition(child: altProfile(userid: users?.docs[index].get('userid'),), type: PageTransitionType.leftToRight)).then((value)
                          {

                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(children:
                            [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                width: MediaQuery.of(context).size.width*0.64,
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 16, backgroundImage: NetworkImage(users?.docs[index].get('userimage'))),
                                    SizedBox(width: 15),
                                    Text(users?.docs[index].get('username'), style: TextStyle(fontSize: 18, color: Colors.white)),
                                  ],
                                ),
                              ),

                              users?.docs[index].get('userid')!=Provider.of<Authentication>(context, listen: false).getUserUid()?
                              FollowBtn(snap: users?.docs[index]):Container(),
                            ],),
                          ),
                      ),

                    );
                  }
              ),
            )
            ,
          ),
        ],
      ),
    );
  }
}
