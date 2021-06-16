
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/login/loginHelper.dart';
import '../../constants/colors.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'chatroomUtils.dart';
import 'package:image_picker/image_picker.dart';

class ChatroomHelpers with ChangeNotifier
{
  ConstantColors constColors = ConstantColors();

  TextEditingController msgController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  GlobalKey<FormState> _createChatroomKey = GlobalKey<FormState>(debugLabel: '_SomeState');


  chatroomAppBar(context)
  {
    return AppBar(
      centerTitle: true,
      backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
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
                text: 'Chat',
                style: TextStyle(
                  color: constColors.blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),)
            ]
        ),
      ),
      actions:
      [
        IconButton(
            icon: Icon(Icons.add, color: constColors.greenColor, size: 30,),
            onPressed: ()
            {
              showCreateChatroom(context);
            }
        )
      ],
    );
  }

  showCreateChatroom(BuildContext context)
  {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();

    return showModalBottomSheet(context: context, isScrollControlled: true, builder: (context)
    {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*0.53,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: constColors.darkColor),
          child: Form(
            child: Column(
              children:
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                  child: Divider(thickness: 4, color: constColors.whiteColor,),
                ),
                GestureDetector(
                  onTap: ()
                  {
                    Provider.of<ChatroomUtils>(context, listen: false).pickUserAvatar(context, ImageSource.gallery);

                  },
                  child: Container(
                    child: Stack(

                      children:
                      [

                        GestureDetector(onTap:()
                        {
                          Provider.of<ChatroomUtils>(context, listen: false).pickUserAvatar(context, ImageSource.gallery);

                        },child: Provider.of<ChatroomUtils>(context, listen: false).pickedFile!=null?CircleAvatar(backgroundColor: constColors.redColor, radius: 60.0,  backgroundImage:
                        FileImage(
                            File(Provider.of<ChatroomUtils>(context, listen: false).pickedFile!.path)
                        ),):CircleAvatar(backgroundColor: constColors.redColor, radius: 60.0)),
                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(Icons.camera_alt,color: Colors.lightBlue, size: 30,)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(validator:
                   (value)
                  {
                    if(value==null || value.length<3) return 'Chatroom name must be at least 3 characters long.';
                  },
                    controller: nameController,style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Enter chatroom name", hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)),),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(controller: descController, style: TextStyle(color: Colors.white),decoration: InputDecoration(hintText: 'Chat room description', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)), inputFormatters:
                  [
                    LengthLimitingTextInputFormatter(100)
                  ],
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    maxLines: 3,
                  ),
                ),
                SizedBox(height: 15),
                MaterialButton(color: Colors.lightBlue,
                  onPressed: ()
                {
                  if(!_createChatroomKey.currentState!.validate()) return;
                  if(nameController.text.isEmpty) return;

                  Provider.of<ChatroomUtils>(context, listen: false).uploadChatroomImage(context).whenComplete(() async
                  {
                    if (Provider.of<ChatroomUtils>(context, listen: false).avatarURL == null) return Provider.of<LoginHelpers>(context, listen: false).WarningSheet(context, 'Please select an avatar for the group.');
                    Map<String, dynamic> m =
                    {
                      'type':'public',
                      'name':nameController.text,
                      'description':descController.text,
                      'imageURL': Provider.of<ChatroomUtils>(context, listen: false).avatarURL,
                      'createdAt': Timestamp.now(),
                      'createdBy': Provider.of<FirebaseOperations>(context, listen: false).name,
                      'lastmessage': '',
                      'lastmessagesender': '',
                      'lastmessagetime': Timestamp.now(),
                      'userids':
                          [
                            Provider.of<Authentication>(context, listen: false).getUserUid(),
                          ]
                    };
                    await Provider.of<ChatroomUtils>(context, listen: false).createChatroom(m, context);
                    Navigator.pop(context);
                  });
                }, child: Text('Create Chatroom', style: TextStyle(color: Colors.white),),),

              ],),
          ),),
      );
    });

  }
  showChatScreen(context, snapshot) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
        leading: IconButton(onPressed: () {
          Navigator.of(context).pop();
        },
          icon: Icon(Icons.arrow_back_ios),
          color: constColors.whiteColor.withOpacity(0.4),),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(radius: 16,
                backgroundImage: NetworkImage(snapshot.get('imageURL'))),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.get('name'), style: TextStyle(color: Colors.white),),
                SizedBox(height: 3,),
                Text('${snapshot
                    .get('userids')
                    .length} member${snapshot
                    .get('userids')
                    .length > 1 ? 's' : ''}', style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 13)),

              ],
            ),

          ],
        ),
        actions:
        [
          IconButton(
              icon: Icon(Icons.add, color: constColors.greenColor, size: 30,),
              onPressed: () {
                //  Navigator.pop(context);
                // Navigator.push(context, PageTransition(child: ChatScreen(snapshot: snapshot), type: PageTransitionType.leftToRight));
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
                stream: FirebaseFirestore.instance.collection("chatrooms").doc(
                    snapshot.id).collection("messages").orderBy(
                    'time', descending: false).snapshots(),
                builder: (context, msgSnapshot) {
                  if (msgSnapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  return ListView.builder(
                      itemCount: msgSnapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        return msgSnapshot.data!.docs[index].get('senderid') ==
                            Provider.of<Authentication>(context, listen: false)
                                .getUserUid() ?
                        //  index%2==0?
                        Row(
                          children: [
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              constraints: BoxConstraints(maxWidth: 300),
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(msgSnapshot.data!.docs[index].get(
                                      'message'), style: TextStyle(
                                      color: Colors.black, fontSize: 17),),
                                  SizedBox(height: 8,),
                                  Text(DateFormat.jm().format(
                                      msgSnapshot.data!.docs[index]
                                          .get('time')
                                          .toDate()), style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 10),),

                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.lightGreenAccent,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(0))),
                            ),
                          ],
                        )
                            :
                        Row(
                          children: [

                            Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 10, 15),
                              constraints: BoxConstraints(maxWidth: 300),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                    [

                                      CircleAvatar(radius: 10,
                                          backgroundImage: NetworkImage(
                                              msgSnapshot.data!.docs[index].get(
                                                  'imageURL'))),
                                      SizedBox(width: 10,),
                                      Text(msgSnapshot.data!.docs[index].get(
                                          'sendername'), style: TextStyle(
                                          color: Colors.black, fontSize: 16),),
                                      SizedBox(width: 10,),
                                      Text(DateFormat.jm().format(
                                          msgSnapshot.data!.docs[index].get(
                                              'time').toDate()),
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(
                                                0.5), fontSize: 10),),

                                    ],
                                  ),
                                  SizedBox(height: 8,),
                                  Text(msgSnapshot.data!.docs[index].get(
                                      'message'), style: TextStyle(
                                      color: Colors.black, fontSize: 17),),
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

        Container(alignment: Alignment(1, 0.99),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                color: /*Color(0xFFe3e3cf)*/ Colors.white,
                border: Border.all(color: Color(0xFFe3e3cf), width: 2.0)),
            child: Row(
              children: [
                Expanded(child: TextField(controller: msgController,
                  decoration: InputDecoration(border: InputBorder.none,
                      hintText: "Enter message..",
                      hintStyle: TextStyle(fontSize: 15,
                          color: Colors.black.withOpacity(0.5))),)),
                Container(decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blue),
                    child: IconButton(
                      icon: Icon(Icons.send, size: 22, color: Colors.white,),
                      onPressed: () {
                        if (msgController.text.isEmpty) return;
                        Provider.of<ChatroomUtils>(context, listen: false)
                            .addChatMessageToDatabase(context,
                            msgController.text, snapshot.id, "text", "");
                        msgController.clear();
                        FocusScope.of(context).unfocus();
                      },))
              ],
            ),
          ),)
      ],),),
    );
  }

  showImageSelectionMode(context, chatroomid)
  {
    return showModalBottomSheet(context: context, builder: (context)
    {
      return Container(decoration: BoxDecoration(color: constColors.darkColor, borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width,
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children:
        [
          MaterialButton(onPressed: ()
          {
            Provider.of<ChatroomUtils>(context ,listen: false).pickImageToSend(context, ImageSource.gallery, chatroomid);
           // Navigator.pop(context);

          }, child: Text('Gallery'), color: Colors.blue,),
          Spacer(),
          MaterialButton(onPressed: ()
          {
            Provider.of<ChatroomUtils>(context ,listen: false).pickImageToSend(context, ImageSource.camera, chatroomid);


           // Navigator.pop(context);
          }, child: Text('Camera'), color: Colors.blue,),

        ],)
      );
    });
  }
  showSelectedImage(context, chatroomid)
  {
    bool isUploading=false;
    return showModalBottomSheet(context: context, builder: (context)
    {

      return StatefulBuilder( builder: (BuildContext context, StateSetter setState)
      {
          return Container(decoration: BoxDecoration(color: constColors.darkColor, borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            height: MediaQuery.of(context).size.height*0.45,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children:
              [
                Container(
                    height: MediaQuery.of(context).size.height*0.3,
                    width:  MediaQuery.of(context).size.width*0.85,

                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(File(Provider.of<ChatroomUtils>(context, listen: false).pickedFile!.path))))
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width*0.63,
                        child: TextField(
                          controller: captionController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Add a caption..', hintStyle: TextStyle(color: Colors.white)),)),
                    Spacer(),
                    !isUploading?IconButton(icon: Icon(Icons.send, color: Colors.blue,), onPressed: ()
                    {
                      setState(()
                      {
                        isUploading=true;
                      });
                      Provider.of<ChatroomUtils>(context, listen: false).uploadImageToSend(context).then((value)
                      {
                        Provider.of<ChatroomUtils>(context, listen: false).addChatMessageToDatabase(context, captionController.text, chatroomid, "image", Provider.of<ChatroomUtils>(context, listen: false).getImageURL()).then((value)
                        {
                          captionController.clear();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      });
                    }):
                        CircularProgressIndicator()
                  ],
                ),


              ],)
        );
      }
      );
    });
  }

}