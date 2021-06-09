import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';


class ChatroomSettings extends StatelessWidget
{
  var id;
  ConstantColors constColors = ConstantColors();
  ChatroomSettings({this.id});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        backgroundColor: constColors.blueGreyColor.withOpacity(0.5),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").doc(id).snapshots(),
            builder: (context, sshot)
            {
              AsyncSnapshot snapshot = sshot;
              return snapshot.connectionState==ConnectionState.waiting?Container():
              ListView(children:
              [
                Stack(
                  children: [

                    Container(
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.only(top: 0),
                      height: MediaQuery.of(context).size.height*0.3,
                      width: MediaQuery.of(context).size.width,
                      child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.network(snapshot.data.get('imageURL'))
                      ),
                    ),
                    Positioned(
                        top: MediaQuery.of(context).size.height*0.22,
                        left: 10,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data.get('name'), style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Created by ${snapshot.data.get('createdBy')} on ${DateFormat.yMMMd().format(snapshot.data.get('createdAt').toDate())}', style: TextStyle(color: Colors.white, fontSize: 17),)),

                          ],
                        )
                    ),
                    Positioned(
                      top: 30,
                      left: 10,
                      child: IconButton(
                        iconSize: 30,
                          color: Colors.white,
                          icon: Icon(Icons.arrow_back_ios),
                              onPressed: ()
                          {
                            Navigator.pop(context);
                          }),
                    )

                  ],
                ),
                Container(
                  color: Colors.black,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text('Description', style: TextStyle(fontSize: 20, color: Colors.green)),
                      SizedBox(height: 10),
                      Text(snapshot.data.get('description'), style: TextStyle(fontSize: 18, color: Colors.white))

                    ],),
                ),

                Container(
                  color: Colors.black,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Text('${snapshot.data.get('userids').length} member${snapshot.data.get('userids').length>1?'s':''}', style: TextStyle(fontSize: 16, color: Colors.white)),
                          Spacer(),

                          StreamBuilder(
                          stream: FirebaseFirestore.instance.collection("chatrooms").doc(id).collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).snapshots(),
                          builder: (context, ashot)
                          {
                            AsyncSnapshot adminshot = ashot;

                            if(adminshot.connectionState==ConnectionState.waiting) return Container();
                            return adminshot.data.get('admin')!=true?Container():
                            GestureDetector(
                              onTap: ()
                              {

                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.lightBlue),borderRadius: BorderRadius.circular(5),),
                                  child: Text('Add people', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),)),
                            );
                          }),

                        ],
                      ),
                      SizedBox(height: 15,),
                      Container(
                        height: MediaQuery.of(context).size.height*0.45,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection("chatrooms").doc(id).collection("users").snapshots(),
                          builder: (context, usersnap)
                          {
                            return usersnap.connectionState==ConnectionState.waiting?
                                Center(child: CircularProgressIndicator()):
                                ListView.builder(itemCount: usersnap.data?.docs.length, itemBuilder: (context, index)
                                {
                                  log('${usersnap.data?.docs.length.toString}');
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(children:
                                    [
                                      CircleAvatar(radius: 16, backgroundImage: NetworkImage(usersnap.data?.docs[index].get('imageURL'))),
                                      SizedBox(width: 15),
                                      Text(usersnap.data?.docs[index].get('username'), style: TextStyle(fontSize: 18, color: Colors.white)),
                                      Spacer(),
                                      usersnap.data?.docs[index].get('admin')!=true?Container():
                                      Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(border: Border.all(color: Colors.lightGreen, width: 0.5), borderRadius: BorderRadius.circular(5)),
                                          child: Text('Admin', style: TextStyle(fontSize: 12, color: Colors.lightGreen))),

                                    ],),
                                  );
                                });
                          },
                        ),
                      ),
                    ],
                  ),

                )
              ],);

            }
        )
    );

  }
}


/*
AppBar(
        centerTitle: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
        leading: IconButton(onPressed: () {Navigator.of(context).pop();},icon: Icon(Icons.arrow_back_ios), color: constColors.whiteColor.withOpacity(0.4),),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(snapshot.get('imageURL'))),
            SizedBox(width: 10),
            Container(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snapshot.get('name'), style: TextStyle(color: Colors.white),),
                  SizedBox(height: 3,),
                  Text('${snapshot.get('userids').length} member${snapshot.get('userids').length>1?'s':''}', style: TextStyle(color: Colors.white.withOpacity(0.4),fontSize: 13)),

                ],
              ),
            ),
          ],
        ),
      ),*/
