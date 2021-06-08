
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import '../../constants/colors.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'chatroomUtils.dart';
import 'package:image_picker/image_picker.dart';

class ChatroomHelpers with ChangeNotifier
{
  ConstantColors constColors = ConstantColors();

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
          child: Column(
            children:
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                child: Divider(thickness: 4, color: constColors.whiteColor,),
              ),
              Stack(
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
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(controller: nameController,style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Enter chatroom name", hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(controller: descController, style: TextStyle(color: Colors.white),decoration: InputDecoration(hintText: 'Chat room description', hintStyle: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.0)), inputFormatters:
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
                Provider.of<ChatroomUtils>(context, listen: false).uploadChatroomImage(context).whenComplete(() async
                {
                  if (Provider.of<ChatroomUtils>(context, listen: false).avatarURL == null) return;
                  Map<String, dynamic> m =
                  {
                    'name':nameController.text,
                    'description':descController.text,
                    'imageURL': Provider.of<ChatroomUtils>(context, listen: false).avatarURL,
                    'createdAt': Timestamp.now(),
                    'lastmessage': '',
                    'lastmessagesender': '',
                    'userids':
                        [
                          Provider.of<Authentication>(context, listen: false).getUserUid(),
                        ]
                  };
                  await Provider.of<ChatroomUtils>(context, listen: false).createChatroom(m, context);
                  Navigator.pop(context);
                });
              }, child: Text('Create Chatroom', style: TextStyle(color: Colors.white),),),

            ],),),
      );
    });
  }

}