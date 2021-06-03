import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialmedia/database/auth.dart';
import '../screens/login/loginUtils.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:developer';

class FirebaseOperations with ChangeNotifier
{
  String imageURL="";
  String name="";
  String email="";

  Future uploadUserAvatar(BuildContext context) async
  {
    if(Provider.of<LoginUtils>(context, listen:false).pickedFile!=null)
    {
      UploadTask imageUploadTask;
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'userProfileAvatar/${Provider
              .of<LoginUtils>(context, listen: false)
              .pickedFile!
              .path}/${TimeOfDay.now()}');
      imageUploadTask = imageReference.putFile(File(Provider
          .of<LoginUtils>(context, listen: false)
          .pickedFile!
          .path));
      await imageUploadTask.whenComplete(() async{
        await imageReference.getDownloadURL().then((url)
        {
          Provider
              .of<LoginUtils>(context, listen: false)
              .avatarURL = url;
          log('User profile avatar: ${Provider
              .of<LoginUtils>(context, listen: false)
              .avatarURL}');
          notifyListeners();

        });
        log('Image uploaded');

      });


    }
  }

  Future createUserCollection(BuildContext context, dynamic data)
  {
      return FirebaseFirestore.instance.collection('users').doc(Provider.of<Authentication>(context, listen:false).getUserUid()).set(data);
  }

  Future initUserData(BuildContext context) async
  {
    return FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).get().then((doc)
    {
      log('User data fetched. Assigning to variables');
      imageURL=doc.data()?['userimage'];
      name=doc.data()?['username'];
      email=doc.data()?['useremail'];
      log('User data: $name, $email');
      notifyListeners();
    });
  }

  Future followUser(BuildContext context, String friendid, Map<String, dynamic> frienddata)
  {
    FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).update(
        {
          'following':FieldValue.increment(1)
        });
    FirebaseFirestore.instance.collection("users").doc(friendid).update(
    {
    'followers':FieldValue.increment(1)
    });
    return FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).collection("following").doc(friendid).set(frienddata).whenComplete(()
    {
      Map<String, dynamic> m =
      {
        'username': Provider.of<FirebaseOperations>(context, listen:false).name,
        'imageURL': Provider.of<FirebaseOperations>(context, listen:false).imageURL,
        'userid': Provider.of<Authentication>(context, listen:false).getUserUid(),
        'email': Provider.of<FirebaseOperations>(context, listen:false).email,
        'time': Timestamp.now()
      };
      return FirebaseFirestore.instance.collection("users").doc(friendid).collection("followers").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).set(m);
    });
  }

  Future unfollowUser(BuildContext context, String friendid)
  {
    FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).update(
        {
          'following':FieldValue.increment(-1)
        });
    FirebaseFirestore.instance.collection("users").doc(friendid).update(
        {
          'followers':FieldValue.increment(-1)
        });
    return FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).collection("following").doc(friendid).delete().whenComplete(()
    {
      return FirebaseFirestore.instance.collection("users").doc(friendid).collection("followers").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).delete();
    });
  }
  
  Future<bool> isFollowing(BuildContext context, String friendid) async
  {
   QuerySnapshot qs = await FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen:false).getUserUid()).collection("following").where('userid', isEqualTo: friendid).get();
    return qs.docs.length==1;
  }
}