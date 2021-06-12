import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';

class FollowButton extends StatefulWidget
{
  var snapshot;
  bool? refresh;
  FollowButton({@required this.snapshot, @required this.refresh});
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
{
  bool isFollowing=false;
  @override
  void initState()
  {
    Provider.of<FirebaseOperations>(context, listen: false).isFollowing(context, widget.snapshot.get('userid')).then((value)
    {
      setState(() {
        isFollowing=value;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context)
  {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child:


        MaterialButton(
          minWidth: 80,
            height: 0,
            onPressed: ()     //Follow button
        {

          if(isFollowing)
          {
            Provider.of<FirebaseOperations>(context, listen: false).unfollowUser(context, widget.snapshot.get('userid'));
            setState(() {
              isFollowing=false;
            });
          }

          else {
            Map<String, dynamic> userData =
            {
              'username': widget.snapshot.get('username'),
              'imageURL': widget.snapshot.get('userimage'),
              'userid': widget.snapshot.get('userid'),
              'email': widget.snapshot.get('useremail'),
              'time': Timestamp.now()
            };
            Provider.of<FirebaseOperations>(context, listen: false)
                .followUser(context, userData['userid'], userData);
            setState(() {
              isFollowing=true;
            });
          }

        }, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: Text(isFollowing?'Unfollow':'Follow', style: TextStyle(color: Colors.white, fontSize: 13)), color: Colors.lightBlue),

    );
  }
}

class FollowBtn extends StatelessWidget {
  var snap;
  FollowBtn({this.snap});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(Provider.of<Authentication>(context, listen: false).getUserUid()).collection("following").where('userid', isEqualTo: snap.get('userid')).snapshots(),
        builder: (context, snapshot)
        {
          if(snapshot.connectionState==ConnectionState.waiting) return Container();
          if(snapshot.data?.docs.length==1)
              return    MaterialButton(
                  minWidth: 80,
                  height: 0,
                  onPressed: ()     //Follow button
                  {
                    Provider.of<FirebaseOperations>(context, listen: false).unfollowUser(context, snap.get('userid'));
                  }
                  , padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: Text('Unfollow', style: TextStyle(color: Colors.white, fontSize: 13)), color: Colors.lightBlue);

          else return    MaterialButton(
              minWidth: 80,
              height: 0,
              onPressed: ()     //Follow button
              {
                Map<String, dynamic> userData =
                {
                  'username': snap.get('username'),
                  'imageURL': snap.get('userimage'),
                  'userid': snap.get('userid'),
                  'email': snap.get('useremail'),
                  'time': Timestamp.now()
                };
                Provider.of<FirebaseOperations>(context, listen: false)
                    .followUser(context, userData['userid'], userData);
              }
              , padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: Text('Follow', style: TextStyle(color: Colors.white, fontSize: 13)), color: Colors.lightBlue);

        },
      ),
    );
  }
}
