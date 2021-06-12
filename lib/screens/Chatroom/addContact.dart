import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';

import 'chatScreen.dart';

class AddContact extends StatefulWidget
{
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact>
{
  String textQuery="";
  ConstantColors constColors = ConstantColors();
  TextEditingController searchController = TextEditingController();
  QuerySnapshot? users=null;

  startConversation(user) async
  {
    FirebaseFirestore.instance.collection("chatrooms").where('userids', arrayContains: user.get('userid')).get().then((qs) async
    {
      log('Length: '+qs.docs.length.toString());
      bool exists=false;
      for(int i=0; i<qs.docs.length; i++)
      {
        if (qs.docs[i].get('userids').contains(Provider.of<Authentication>(context, listen: false).getUserUid()) && qs.docs[i].get('type') == 'private')
        {
          //Navigator.pop(context);
          Navigator.pushReplacement(context, PageTransition(child: ChatScreen(snapshot: qs.docs[i]), type: PageTransitionType.leftToRight));
          exists=true;
          break;
        }
      }
      if(!exists) {
        await FirebaseFirestore.instance.collection("chatrooms").add(
            {
              'type': 'private',
              'createdAt': Timestamp.now(),
              'userids': [
                Provider.of<Authentication>(context, listen: false)
                    .getUserUid(),
                user.get('userid')
              ],
              'names': [
                Provider
                    .of<FirebaseOperations>(context, listen: false)
                    .name,
                user.get('username'),
              ],
              'imageURLs': [
                Provider
                    .of<FirebaseOperations>(context, listen: false)
                    .imageURL,
                user.get('imageURL'),
              ],
              'lastmessage': '',
              'lastmessagesender': '',
              'lastmessagetime': Timestamp.now()
            }).then((DocRef)
        {
          DocRef.get().then((DS)
          {
            Navigator.pushReplacement(context, PageTransition(child: ChatScreen(snapshot: DS), type: PageTransitionType.leftToRight));

          });
        });
      }

    });

  }


  fetchUserList() async
  {




    FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).collection("following").get().then((value)
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar
        (
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
        leading: IconButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white.withOpacity(0.5),),
        ),
        title: Text('Start a conversation', style: TextStyle(color: Colors.white)),

      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
              height: MediaQuery.of(context).size.height*0.75,
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
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      margin: EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: ()
                        {
                          log('HITTTT');
                          startConversation(users?.docs[index]);
                          //Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(children:
                          [
                            CircleAvatar(radius: 16, backgroundImage: NetworkImage(users?.docs[index].get('imageURL'))),
                            SizedBox(width: 15),
                            Text(users?.docs[index].get('username'), style: TextStyle(fontSize: 18, color: Colors.white)),
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
