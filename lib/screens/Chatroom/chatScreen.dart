import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/screens/Chatroom/chatroomSettings/chatroomSettings.dart';
import 'package:socialmedia/screens/Chatroom/chatroomUtils.dart';
import 'package:intl/intl.dart';
ScrollController controller = ScrollController();

class ChatScreen extends StatelessWidget with ChangeNotifier
{
  var snapshot;
  int msgCount=0;
  ConstantColors constColors = ConstantColors();
  ChatScreen({@required this.snapshot});
  TextEditingController msgController = TextEditingController();


  int getInt(int? x)
  {
    if(x==null) return -1;
    return x;
  }

  void scrollToBottom() {
    log('Scrolling to bottom');
    controller.position.maxScrollExtent;


  }

  @override
  Widget build(BuildContext context)
  {
    bool isPrivate=snapshot.get('type')=='private';
    int friend = snapshot.get('userids')[0]==Provider.of<Authentication>(context, listen: false).getUserUid()?1:0;
    WidgetsBinding.instance!.addPostFrameCallback((_)
    {
      Timer(Duration(milliseconds: 700), () {controller.jumpTo(controller.position.maxScrollExtent);});
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
        leading: IconButton(onPressed: () {Navigator.of(context).pop();},icon: Icon(Icons.arrow_back_ios), color: constColors.whiteColor.withOpacity(0.4),),
        automaticallyImplyLeading: false,
        title:
        isPrivate?
        Row(children:
        [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(snapshot.get('imageURLs')[friend])),
          SizedBox(width: 14,),
          Text(snapshot.get('names')[friend], style: TextStyle(color: Colors.white),),

        ],)
            :
        GestureDetector(
          onTap: ()
          {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatroomSettings(id: snapshot.id)));

          },
          child: Container(

            child: Row(
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
          ),
        ),
        actions:
        [
          IconButton(
              icon: Icon(Icons.more_vert, color: constColors.greenColor, size: 30,),
              onPressed: ()
              {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatroomSettings(id: snapshot.id)));
              }
          )
        ],
      ),
      body: Container(child: Stack(children: [
        Container(
          padding: EdgeInsets.only(bottom: 80),
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("chatrooms").doc(snapshot.id).collection("messages").orderBy('time', descending: false).snapshots(),
              builder: (context, msgSnapshot)
              {
                if(msgSnapshot.connectionState==ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if(getInt(msgSnapshot.data?.docs.length)>msgCount)       Timer(Duration(milliseconds: 700), () {controller.jumpTo(controller.position.maxScrollExtent);});
                msgCount = getInt(msgSnapshot.data?.docs.length);
                return ListView.builder(
                    controller: controller,
                    itemCount: msgSnapshot.data?.docs.length,
                    itemBuilder: (context, index)
                    {
                      return msgSnapshot.data!.docs[index].get('senderid')==Provider.of<Authentication>(context, listen: false).getUserUid()?
                    //  index%2==0?
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            constraints: BoxConstraints(maxWidth: 300),
                            margin: EdgeInsets.fromLTRB(0,0,10,7),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(msgSnapshot.data!.docs[index].get('message'), style: TextStyle(color: Colors.black, fontSize: 17),),
                                SizedBox(height: 8,),
                                Text(DateFormat.jm().format(msgSnapshot.data!.docs[index].get('time').toDate()), style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 10),),

                              ],
                            ),
                            decoration: BoxDecoration(color: Colors.lightGreenAccent, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(0))),
                          ),
                        ],
                      )
                          :
                      Row(
                        children: [

                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 10, 7),
                            constraints: BoxConstraints(maxWidth: 300),
                            padding:  EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                  [

                                    CircleAvatar(radius: 10, backgroundImage: NetworkImage(msgSnapshot.data!.docs[index].get('imageURL'))),
                                    SizedBox(width: 10,),
                                    Text(msgSnapshot.data!.docs[index].get('sendername'), style: TextStyle(color: Colors.black, fontSize: 16),),
                                    SizedBox(width: 10,),
                                    Text(DateFormat.jm().format(msgSnapshot.data!.docs[index].get('time').toDate()), style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 10),),

                                  ],
                                ),
                                SizedBox(height: 8,),
                                Text(msgSnapshot.data!.docs[index].get('message'), style: TextStyle(color: Colors.black, fontSize: 17),),
                              ],
                            ),
                          ),

                        ],
                      );
                    }
                );
              }
              ,
            )
          ),
        ),

        Container(alignment:Alignment(1,0.99),child: Container(margin:EdgeInsets.symmetric(horizontal: 20,vertical: 10),padding:EdgeInsets.only(left: 10),decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: /*Color(0xFFe3e3cf)*/ Colors.white,border: Border.all(color:Color(0xFFe3e3cf),width: 2.0 )),
          child: Row(
            children: [
              Expanded(child: TextField(controller: msgController, decoration: InputDecoration(border:InputBorder.none,hintText: "Enter message..",hintStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.5))),)),
              Container(decoration:BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue),child: IconButton(icon: Icon(Icons.send,size: 22,color: Colors.white,),onPressed: ()
              {
                if(msgController.text.isEmpty) return;
                scrollToBottom();

                Provider.of<ChatroomUtils>(context, listen: false).addChatMessageToDatabase(context, msgController.text, snapshot.id);
                  msgController.clear();

                   FocusScope.of(context).unfocus();

              },))
            ],
          ),
        ),)
      ],),),
    );
  }
}
