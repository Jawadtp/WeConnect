import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/Feed/feedHelpers.dart';

class UploadPost with ChangeNotifier
{
  PickedFile? pickedFile;
  String? postURL;

  Future pickUploadImage(BuildContext context, ImageSource source) async
  {
    final pickedFileTemp = await ImagePicker().getImage(
      source: source,
      imageQuality: 50
    );
    if(pickedFileTemp!=null)
    {
      pickedFile=pickedFileTemp;
      log('Upload image picked. Path: '+pickedFile!.path);
      // Provider.of<LoginServices>(context, listen: false).showUserAvatar(context);
      Navigator.pop(context); //Model bottoms sheets stack up on each other unless they are closed manually. Hence, it makes sense to programmatically close them.
      Provider.of<FeedHelpers>(context, listen: false).uploadPostDisplay(context);
      notifyListeners();
    }
    else log('Image picked is null');
  }

  Future uploadPostImage(BuildContext context) async
  {
    if(pickedFile!=null)
    {
      UploadTask imageUploadTask;
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'PostImages/${Provider.of<FirebaseOperations>(context, listen: false).name}/${Timestamp.now()}');
      imageUploadTask = imageReference.putFile(File(pickedFile!
          .path));
      await imageUploadTask.whenComplete(() async{
        await imageReference.getDownloadURL().then((url)
        {
         postURL = url;
          log('Post uploaded to Firebase Storage: URL: ${postURL}');
          notifyListeners();

        });

      });
    }

  }

  Future uploadPostToDB(context, Map<String, dynamic> m)
  {
    FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).update(
        {
          'posts':FieldValue.increment(1)
        });
    return FirebaseFirestore.instance.collection("posts").add(m).then((value)
    {
      log('Post added to Firestore successfully');
    });
  }

  Future updateCaption(String postid, String caption)
  {
    return FirebaseFirestore.instance.collection("posts").doc(postid).update(
        {
          'caption':caption
        });
  }

  Future deletePost(context, String postid)
  {
    FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).update(
    {
    'posts':FieldValue.increment(-1)
    });
    FirebaseFirestore.instance.collection('posts').doc(postid).collection("likes").get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs)
      {
        doc.reference.delete();
      };
    });
    FirebaseFirestore.instance.collection('posts').doc(postid).collection("comments").get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs)
      {
        doc.reference.delete();
      };
    });
    return FirebaseFirestore.instance.collection("posts").doc(postid).delete();
  }
}