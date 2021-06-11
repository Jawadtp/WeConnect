import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/screens/Chatroom/chatroomHelpers.dart';
import 'package:socialmedia/screens/login/loginServices.dart';


class ChatroomUtils with ChangeNotifier
{
  final picker = ImagePicker();
  String? avatarURL;
  PickedFile? pickedFile;
  String? getAvatarURL()
  {
    return avatarURL;
  }
  PickedFile? getUserImage()
  {
    return pickedFile;
  }
  Future pickUserAvatar(BuildContext context, ImageSource source) async
  {
    final pickedFileTemp = await picker.getImage(
      source: source,
    );
    if(pickedFileTemp!=null)
    {
      pickedFile=pickedFileTemp;
      log('Image picked. Path: '+pickedFile!.path);
      // Provider.of<LoginServices>(context, listen: false).showUserAvatar(context);
      Navigator.pop(context); //Model bottoms sheets stack up on each other unless they are closed manually. Hence, it makes sense to programmatically close them.
      Provider.of<ChatroomHelpers>(context, listen: false).showCreateChatroom(context);
      notifyListeners();
    }
    else log('Image picked is null');
  }

  Future uploadChatroomImage(BuildContext context) async
  {
    if(Provider.of<ChatroomUtils>(context, listen:false).pickedFile!=null)
    {
      UploadTask imageUploadTask;
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'ChatroomAvatars/${Provider
              .of<ChatroomUtils>(context, listen: false)
              .pickedFile!
              .path}/${TimeOfDay.now()}');
      imageUploadTask = imageReference.putFile(File(Provider
          .of<ChatroomUtils>(context, listen: false)
          .pickedFile!
          .path));
      await imageUploadTask.whenComplete(() async{
        await imageReference.getDownloadURL().then((url)
        {
          Provider
              .of<ChatroomUtils>(context, listen: false)
              .avatarURL = url;
          log('User profile avatar: ${Provider
              .of<ChatroomUtils>(context, listen: false)
              .avatarURL}');
          notifyListeners();

        });
        log('Image uploaded');

      });


    }
  }

  createChatroom(Map<String, dynamic> m, context) async
  {

    await FirebaseFirestore.instance.collection("chatrooms").add(m).then((docRef) async
    {
      await FirebaseFirestore.instance.collection("chatrooms").doc(docRef.id).collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).set
      (
          {
            'userid': Provider.of<Authentication>(context, listen: false).getUserUid(),
            'username': Provider.of<FirebaseOperations>(context, listen: false).name,
            'imageURL': Provider.of<FirebaseOperations>(context, listen: false).imageURL,
            'admin': true
          }
      );
    });
  }

  Future addChatMessageToDatabase(BuildContext context, String message, String chatroomid)
  {
    FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).update(
        {
          'lastmessage':message,
          'lastmessagesender':Provider.of<FirebaseOperations>(context, listen: false).name,
        });
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).collection("messages").add(
        {
          'senderid': Provider.of<Authentication>(context, listen: false).getUserUid(),
          'sendername': Provider.of<FirebaseOperations>(context, listen: false).name,
          'imageURL': Provider.of<FirebaseOperations>(context, listen: false).imageURL,
          'message': message,
          'time': Timestamp.now(),
        });
  }
}