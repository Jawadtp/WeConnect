import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';

class LikesCommentsFirebase with ChangeNotifier
{
  Future likePost(BuildContext context, String postid)
  {
   FirebaseFirestore.instance.collection("posts").doc(postid).update(

        {
        'likes':FieldValue.increment(1)
        }
    );
    return FirebaseFirestore.instance.collection("posts").doc(postid).collection("likes").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).set(
        {
          'like':1,
          'time':Timestamp.now(),
          'username': Provider.of<FirebaseOperations>(context, listen: false).name,
          'userimage': Provider.of<FirebaseOperations>(context, listen: false).imageURL,
          'userid':  Provider.of<Authentication>(context, listen: false).getUserUid(),
        });
  }

  Future removeLikePost(BuildContext context, String postid)
  {
    FirebaseFirestore.instance.collection("posts").doc(postid).update(

        {
          'likes':FieldValue.increment(-1)
        }
    );
    return FirebaseFirestore.instance.collection("posts").doc(postid).collection("likes").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).delete();
  }

  Stream<QuerySnapshot> getLikes(String postid)
  {
    return FirebaseFirestore.instance.collection("posts").doc(postid).collection("likes").snapshots();
  }
  Stream<QuerySnapshot> hasUserLiked(BuildContext context, String postid)
  {
    return FirebaseFirestore.instance.collection("posts").doc(postid).collection("likes").where('userid', isEqualTo: Provider.of<Authentication>(context, listen: false).getUserUid()).snapshots();
  }

  Future postComment(BuildContext context, String postid, String comment)
  {
    FirebaseFirestore.instance.collection("posts").doc(postid).update(
        {
          'comments':FieldValue.increment(1)
        });
    return FirebaseFirestore.instance.collection("posts").doc(postid).collection("comments").add(
        {
          'username':Provider.of<FirebaseOperations>(context, listen: false).name,
          'uid': Provider.of<Authentication>(context, listen: false).getUserUid(),
          'imageURL': Provider.of<FirebaseOperations>(context, listen: false).imageURL,
          'comment': comment,
          'time': Timestamp.now()
        });
  }

  Future removeComment(BuildContext context, String postid, String commentid)
  {
    FirebaseFirestore.instance.collection("posts").doc(postid).update(
        {
          'comments':FieldValue.increment(-1)
        });
    return FirebaseFirestore.instance.collection("posts").doc(postid).collection("comments").doc(commentid).delete();
  }
}