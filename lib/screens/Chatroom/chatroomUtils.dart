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
  String? imageToBeSentURL;

  PickedFile? pickedFile;

  String getAvatarURL()
  {
    String? temp = avatarURL;
    if(temp==null) return '';
    else return temp;
  }
  String getImageURL()
  {
    String? temp = imageToBeSentURL;
    if(temp==null) return '';
    else return temp;
  }

  PickedFile? getUserImage()
  {
    return pickedFile;
  }
  Future pickUserAvatar(BuildContext context, ImageSource source) async
  {
    final pickedFileTemp = await picker.getImage(
      source: source,
      imageQuality: 50,
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

  Future pickImageToSend(BuildContext context, ImageSource source, String chatroomid) async
  {
    final pickedFileTemp = await picker.getImage(
      source: source,
      imageQuality: 50,
    );
    if(pickedFileTemp!=null)
    {
      pickedFile=pickedFileTemp;
      log('Image picked. Path: '+pickedFile!.path);

      Provider.of<ChatroomHelpers>(context, listen: false).showSelectedImage(context, chatroomid);
      log('Hereee');

      notifyListeners();
    }
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
          log('Image to be send uploaded: ${Provider
              .of<ChatroomUtils>(context, listen: false)
              .avatarURL}');
          notifyListeners();

        });
        log('Image uploaded');

      });


    }
  }


  Future uploadImageToSend(BuildContext context) async
  {
    if(Provider.of<ChatroomUtils>(context, listen:false).pickedFile!=null)
    {
      UploadTask imageUploadTask;
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'ChatroomMessages/${Provider
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
              .imageToBeSentURL = url;
          log('User profile avatar: ${Provider
              .of<ChatroomUtils>(context, listen: false)
              .imageToBeSentURL}');
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

  Future addChatMessageToDatabase(BuildContext context, String message, String chatroomid, String type, String imgURL)
  {
    FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).update(
        {
          'lastmessage':type=="text"?message:"sent an image",
          'lastmessagesender':Provider.of<FirebaseOperations>(context, listen: false).name,
          'lastmessagetime':Timestamp.now()
        });
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).collection("messages").add(
        {
          'type':type,
          'senderid': Provider.of<Authentication>(context, listen: false).getUserUid(),
          'sendername': Provider.of<FirebaseOperations>(context, listen: false).name,
          'imageURL': Provider.of<FirebaseOperations>(context, listen: false).imageURL,
          'postimage':imgURL,
          'message': message,
          'time': Timestamp.now(),
        });
  }
}