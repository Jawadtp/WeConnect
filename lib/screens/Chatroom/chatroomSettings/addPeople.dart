import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';

class AddPeople extends StatefulWidget
{
  var snapshot;
  AddPeople({this.snapshot});
  @override
  _AddPeopleState createState() => _AddPeopleState();
}

class _AddPeopleState extends State<AddPeople>
{
  String textQuery="";
  ConstantColors constColors = ConstantColors();
  TextEditingController searchController = TextEditingController();
  QuerySnapshot? users=null;

  updateChatroomList(user)
  {
    log(user.get('userid'));
    FirebaseFirestore.instance.collection("chatrooms").doc(widget.snapshot.data.id).update(
        {
          'userids':FieldValue.arrayUnion([user.get('userid')])
        });

    FirebaseFirestore.instance.collection("chatrooms").doc(widget.snapshot.data.id).collection("users").doc(user.get('userid')).set(
        {
          'admin': false,
          'imageURL':user.get('imageURL'),
          'userid': user.get('userid'),
          'username': user.get('username')
        });
    log('After');

  }
  fetchUserList() async
  {

    FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).collection("following").get().then((value)
    {
      setState(() {
        users=value;
      });
    });

/*
    FirebaseFirestore.instance.collection("users").get().then((value)
    {
      setState(() {
        users=value;
      });
    }); */
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
        title: Text('Add participant', style: TextStyle(color: Colors.white)),

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
                      if(widget.snapshot.data.get('userids').contains(users?.docs[index].get('userid')) )
                          return Container();
                      else if(!(users?.docs[index].get('username').toLowerCase().startsWith(textQuery.trim().toLowerCase())) && textQuery.trim().isNotEmpty)
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
                            updateChatroomList(users?.docs[index]);
                            Navigator.pop(context);
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
