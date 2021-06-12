import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/Chatroom/chatScreen.dart';
import '../../database/auth.dart';
import '../login/login.dart';
import 'dart:developer';

import 'altProfile.dart';

class ProfileHelpers with ChangeNotifier
{
  ConstantColors constColors = ConstantColors();

  Widget HeaderProfile(BuildContext context, dynamic snapshot)
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,12,0,0),
      child: SizedBox(

        height: MediaQuery.of(context).size.height*0.23,
        width: MediaQuery.of(context).size.width,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
          [

            Container(
              height: 200,
              width: 160,
          //    color: Colors.white,
              child: Column(
                children:
                [
                  GestureDetector(
                    onTap: ()
                    {
                      // To implement: Profile picture to be changed
                    },
                    child: CircleAvatar(
                      backgroundColor: constColors.transparent,
                      radius: 60.0,
                      backgroundImage: NetworkImage(snapshot.data.get('userimage')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        snapshot.data.get('username'),
                      style: TextStyle(
                          color: constColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Column(
                children: [

                  Row(
                    children:
                    [

                      GestureDetector(
                        onTap: ()
                        {
                          showFollowersOrFollowing('followers',context, snapshot.data.get('userid'));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: constColors.darkColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          height: 70,
                          width: 80,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(

                              children:
                              [
                                Text(
                              snapshot.data.get('followers').toString(),
                                  style: TextStyle(
                                      color: constColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28
                                  ),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                      color: constColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: ()
                        {
                          showFollowersOrFollowing('following', context,  snapshot.data.get('userid'));
                        },
                        child: Container(
                          height: 70,
                          width: 80,
                          decoration: BoxDecoration(
                            color: constColors.darkColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children:
                              [
                                Text(
                              snapshot.data.get('following').toString(),
                                  style: TextStyle(
                                      color: constColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28
                                  ),
                                ),
                                Text(
                                  'Following',
                                  style: TextStyle(
                                      color: constColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],),
                  SizedBox(height: 10,),
                  Container(
                    height: 70,
                    width: 80,
                    decoration: BoxDecoration(
                      color: constColors.darkColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children:
                        [
                          Text(
                            snapshot.data.get('posts').toString(),
                            style: TextStyle(
                                color: constColors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 28
                            ),
                          ),
                          Text(
                            'Posts',
                            style: TextStyle(
                                color: constColors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customDivider(context)
  {
    return Container(
      width: MediaQuery.of(context).size.width*0.82,
      height: 0.5,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  showFollowersOrFollowing(String type, context, userid)
  {
    return showModalBottomSheet(isScrollControlled: true, context: context, builder: (context)
    {
      return Container(
        height:MediaQuery.of(context).size.height*0.6,
        decoration: BoxDecoration(
            color: constColors.blueGreyColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25))
        ),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(width: MediaQuery.of(context).size.width*0.4, height: 2, color: Colors.white.withOpacity(0.4),),
            SizedBox(height: 17),
            Text('Followers', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: MediaQuery.of(context).size.height*0.5,
              child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("users").doc(userid).collection(type=='followers'?'followers':'following').orderBy('time', descending: true).snapshots(),
                builder: (context, snapshot)
                {
                  if(snapshot.connectionState==ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                  else return ListView.builder(itemCount: snapshot.data?.docs.length,itemBuilder: (context, index)
                  {
                    return Container(
                      child: Row(children:
                      [
                        GestureDetector(
                            onTap: ()
                            {
                              Navigator.push(context, PageTransition(child: altProfile(userid:snapshot.data?.docs[index].id), type: PageTransitionType.leftToRight));

                            },
                            child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(snapshot.data?.docs[index].get('imageURL')))),
                        SizedBox(width: 12,),
                        GestureDetector(
                          onTap: ()
                          {
                            Navigator.push(context, PageTransition(child: altProfile(userid:snapshot.data?.docs[index].id), type: PageTransitionType.leftToRight));

                          },
                          child: Text(
                              snapshot.data?.docs[index].get('username'),
                              style: TextStyle(
                                  color: constColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17
                              )
                          ),
                        ),
                        Spacer(),
                     //   FollowMessageButtons(snapshot: snapshot)
                      ],),


                    );
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget userDescription(context, dynamic snapshot)
  {
    return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Text(snapshot.data.get('description')),
    );
  }

  Widget middleProfile(context, dynamic snapshot)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children:
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(children:
            [
              Icon(FontAwesomeIcons.userAstronaut, color: constColors.yellowColor, size: 15,),
              SizedBox(width: 6,),
              Text('Recently added', style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold),),
            ],),
          ),
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width*0.9,
            decoration: BoxDecoration(
              color: constColors.darkColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10)
            ),
          )
        ],
      ),
    );
  }
  Widget lowerProfile(context, dynamic snapshot)
  {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
        //  color: constColors.darkColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)
      ),
      child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("posts").where('userid', isEqualTo: snapshot.data.get('userid')).snapshots(),
  builder: (context, sshot)
    {
      if(sshot.connectionState==ConnectionState.waiting) return Center(child: CircularProgressIndicator());
      else return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: sshot.data?.docs.length,
          padding:  EdgeInsets.all(0),
          itemBuilder: (BuildContext context, int index)
          {
            return Container(
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.only(top: 0),
              height: MediaQuery.of(context).size.height*0.6,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.network(sshot.data?.docs[index].get('postURL'))
              ),
            );
          }
    );
    })
    );

  }

  
  /*
  return ListView.builder(itemCount: sshot.data?.docs.length,
      itemBuilder: (context, index)
      {
        return   Container(
          margin: EdgeInsets.only(top: 8),
          height: MediaQuery.of(context).size.height*0.6,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
              fit: BoxFit.fill,
              child: Image.network(sshot.data?.docs[index].get('postURL'))
          ),
        );
      }
    );}
   */
  Widget logoutDialog(context)
  {

    return AlertDialog(
      backgroundColor: constColors.darkColor,
      title: Text(
          'Log out of WeConnect?',
          style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      actions: 
      [
        MaterialButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          child: Text(
            'No',
            style: TextStyle(
                color: constColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,

            ),
          ),
        ),
        MaterialButton(
          onPressed: ()
          {
            Provider.of<Authentication>(context, listen: false).emailLogOut(context).whenComplete(()
            {
              Navigator.pushReplacement(context, PageTransition(child: Login(), type: PageTransitionType.leftToRight));

            });
          },
          child: Text(
            'Yes',
            style: TextStyle(
              color: constColors.redColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,

            ),
          ),
        ),
      ],

    );
  }
}

class FollowMessageButtons extends StatefulWidget
{
  var snapshot;
  FollowMessageButtons({@required this.snapshot});
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowMessageButtons>
{
  bool isFollowing=false;
  @override
  void initState()
  {
    Provider.of<FirebaseOperations>(context, listen: false).isFollowing(context, widget.snapshot.data.get('userid')).then((value)
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
      padding: EdgeInsets.symmetric(horizontal: 28),
      child:
      Row(children:
      [

          MaterialButton(onPressed: ()     //Follow button
        {

        if(isFollowing)
        {
          Provider.of<FirebaseOperations>(context, listen: false).unfollowUser(context, widget.snapshot.data.get('userid'));
          setState(() {
            isFollowing=false;
          });
        }

        else {
          Map<String, dynamic> userData =
          {
            'username': widget.snapshot.data.get('username'),
            'imageURL': widget.snapshot.data.get('userimage'),
            'userid': widget.snapshot.data.get('userid'),
            'email': widget.snapshot.data.get('useremail'),
            'time': Timestamp.now()
          };
          Provider.of<FirebaseOperations>(context, listen: false)
              .followUser(context, userData['userid'], userData);
          setState(() {
            isFollowing=true;
          });
        }

        }, padding: EdgeInsets.symmetric(horizontal: 48), child: Text(isFollowing?'Unfollow':'Follow', style: TextStyle(color: Colors.white)), color: Colors.lightBlue),


        Spacer(),
        MaterialButton(onPressed: ()
        {

            var user=widget.snapshot.data;
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



        }, padding: EdgeInsets.symmetric(horizontal: 45), child: Text('Message'), color: Colors.white)
      ],
      ),
    );
  }
}
