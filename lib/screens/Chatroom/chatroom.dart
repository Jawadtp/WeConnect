import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/screens/Chatroom/addContact.dart';
import 'package:socialmedia/screens/Chatroom/chatScreen.dart';
import 'chatroomHelpers.dart';

class Chatroom extends StatefulWidget
{
  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  TextEditingController searchController = TextEditingController();

  ConstantColors constColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: ()
      {
        Navigator.push(context, PageTransition(child: AddContact(), type: PageTransitionType.topToBottom));

      },child: Icon(Icons.person,size: 30,),),
      resizeToAvoidBottomInset: false,
      appBar: Provider.of<ChatroomHelpers>(context, listen: false).chatroomAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child:
      ListView(//crossAxisAlignment: CrossAxisAlignment.start,
        children:
      [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: constColors.blueGreyColor, borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width*0.9,
          child: TextField(controller: searchController,style: TextStyle(color: Colors.white), decoration: InputDecoration(border: InputBorder.none,hintText: "Search", hintStyle: TextStyle(color: constColors.whiteColor.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 14.0), contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12), isDense: true
          ),),
        ),
        SizedBox(height: 15,),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Chats', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),)),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          margin: EdgeInsets.fromLTRB(0,20,0,0),
          height: MediaQuery.of(context).size.height*0.65,
          //color: constColors.redColor,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("chatrooms").orderBy('lastmessagetime', descending: true).snapshots(),
            builder: (context, snapshot)
            {

              if(snapshot.connectionState==ConnectionState.waiting)
                return Center(child: CircularProgressIndicator(),);
              else
                {
                return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index)
                {
                  bool isPrivate = snapshot.data!.docs[index].get('type')=='private';
                  int friend=Provider.of<Authentication>(context, listen: false).getUserUid()==snapshot.data!.docs[index].get('userids')[0]?1:0;
                  return Container(

                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(children:
                      [
                        !isPrivate?
                        CircleAvatar(radius: 24, backgroundImage: NetworkImage(snapshot.data!.docs[index].get('imageURL'))):
                        CircleAvatar(radius: 24, backgroundImage: NetworkImage(snapshot.data!.docs[index].get('imageURLs')[friend])),

                        SizedBox(width: 19),
                         GestureDetector(
                           onTap: ()
                           {
                             Navigator.push(context, PageTransition(child: ChatScreen(snapshot: snapshot.data!.docs[index]), type: PageTransitionType.leftToRight));
                           },
                           child: Container(
                             width: MediaQuery.of(context).size.width*0.7,
                             padding: EdgeInsets.symmetric(vertical: 5),
                             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                [
                                  !isPrivate?
                                  Text(snapshot.data!.docs[index].get('name'), style: TextStyle(color: Colors.white, fontSize: 16),):
                                  Text(snapshot.data!.docs[index].get('names')[friend], style: TextStyle(color: Colors.white, fontSize: 16),),


                                  SizedBox(height: 4),
                                  snapshot.data!.docs[index].get('lastmessage')==""?Container():
                                  Text("${snapshot.data!.docs[index].get('lastmessagesender')}: ${snapshot.data!.docs[index].get('lastmessage').length<25?snapshot.data!.docs[index].get('lastmessage'):snapshot.data!.docs[index].get('lastmessage').substring(0,25                                                     )+'...'}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),),

                                ],),
                           ),
                         ),

                      ],),
                    );
                }
              );}
            },
          ),
          )

      ],),),
    );
  }
}
