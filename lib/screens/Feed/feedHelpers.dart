
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/Feed/LikesAndComments/LikesCommentFirebase.dart';
import 'package:socialmedia/screens/Feed/feedDatabase.dart';
import 'package:socialmedia/screens/Profile/altProfile.dart';
import 'package:socialmedia/screens/search/followButton.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:page_transition/page_transition.dart';

class FeedHelpers with ChangeNotifier
{

  ConstantColors constColors = ConstantColors();
  TextEditingController captionController = new TextEditingController();
  TextEditingController commentController = new TextEditingController();
  TextEditingController captionEditController = new TextEditingController();


  getTimeAgo(Timestamp timeData)
  {
    DateTime dateTime = timeData.toDate();
    return timeago.format(dateTime);
  }

  feedAppBar(BuildContext context)
  {
    return AppBar(
      centerTitle: true,
      backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
      leading: IconButton(
            icon: Icon(Icons.camera),
            color: Colors.transparent,
            onPressed: ()
            {

            }
        ),
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
        text: 'Connect',
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
          icon: Icon(Icons.camera_alt, color: constColors.greenColor,),
          onPressed: ()
          {
            captionController.clear();
            selectUploadPost(context);
          }
        )
      ],
    );
  }

  Widget feedBody(BuildContext context)
  {

    return Container(
        padding: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
            color: constColors.darkColor
        ),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("posts").orderBy('time', descending: true).snapshots(),
            builder: (context, snapshot)
            {
              if(snapshot.connectionState==ConnectionState.waiting)
                return Center(child: CircularProgressIndicator(),);
              if(snapshot.hasData) return ListView.builder(
                  cacheExtent: MediaQuery.of(context).size.height*5,
                  itemCount: snapshot.data?.docs.length,

                  itemBuilder: (context, index)
                  {
                    if(Provider.of<FirebaseOperations>(context, listen: false).following.contains(snapshot.data!.docs[index].get('userid')))
                    return feedPost(snapshot.data!.docs[index], context);
                    return Container();
                  }
              );
              return Container();
            }),);

  }

  Widget feedPost(DocumentSnapshot snapshot, BuildContext context)
  {

    return Container(
      margin: EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          Container(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Row(
              children:
              [
                GestureDetector(
                    onTap: ()
                    {
                      Navigator.push(context, PageTransition(child: altProfile(userid:snapshot.get('userid')), type: PageTransitionType.leftToRight));

                    },
                    child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(snapshot.get('userimage')))),
                SizedBox(width: 8,),
                GestureDetector(
                  onTap: ()
                  {
                    Navigator.push(context, PageTransition(child: altProfile(userid:snapshot.get('userid')), type: PageTransitionType.leftToRight));

                  },
                  child: Text(
                      snapshot.get('username'),
                      style: TextStyle(
                          color: constColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17
                      )
                  ),
                ),
                Spacer(),
                Provider.of<Authentication>(context, listen: false).getUserUid()!=snapshot.get('userid')?Container():
                IconButton(
                    onPressed: ()
                    {
                      captionEditController.text=snapshot.get('caption');
                      showPostOptions(context, snapshot.id, snapshot.get('caption'));
                    },
                    iconSize: 25,
                    color: constColors.whiteColor,
                    icon: Icon(Icons.more_vert)
                )
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 8),
            height: MediaQuery.of(context).size.height*0.6,
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.network(snapshot.get('postURL'))
            ),
          ),

          Row(children:
          [
            Container(
              height: 50,
              width: 50,
            //  color: constColors.yellowColor,
              child: StreamBuilder<QuerySnapshot>(stream: Provider.of<LikesCommentsFirebase>(context, listen: false).hasUserLiked(context, snapshot.id), builder: (context, sshot)
              {
                if(sshot.connectionState==ConnectionState.waiting)
                  return IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.heart), color: constColors.whiteColor, iconSize: 25,);
                else {
                  if (sshot.data?.docs.length  == 0)
                    return IconButton(
                      onPressed: ()
                      {
                        Provider.of<LikesCommentsFirebase>(context, listen: false).likePost(context, snapshot.id);
                      },
                      icon: Icon(FontAwesomeIcons.heart),
                      color: constColors.whiteColor,
                      iconSize: 25,
                    );
                  else
                    return IconButton(
                      onPressed: () {
                        Provider.of<LikesCommentsFirebase>(
                            context, listen: false).removeLikePost(
                            context, snapshot.id);
                      },
                      icon: Icon(FontAwesomeIcons.solidHeart),
                      color: constColors.redColor,
                      iconSize: 25,
                    );
                }
              }),
            ),



            GestureDetector(
                onTap: ()
                {
                  log('clicked xddd');
                  displayAllLikes(context, snapshot.id);
                },
                child: Text('${snapshot.get('likes')}', style: TextStyle(color: constColors.whiteColor, fontSize: 18))),


            SizedBox(width: 18),

            IconButton(
              onPressed: ()
              {
                displayComments(context, snapshot.id);
              },
              icon: Icon(FontAwesomeIcons.comment),
              color: constColors.whiteColor,
              iconSize: 25,
            ),
            Text('${snapshot.get('comments')}', style: TextStyle(color: constColors.whiteColor, fontSize: 18)),

            SizedBox(width: 18),
/*
            IconButton(
              onPressed: ()
              {

              },
              icon: Icon(FontAwesomeIcons.award),
              color: constColors.whiteColor,
              iconSize: 23,
            ),
            Text('8', style: TextStyle(color: constColors.whiteColor, fontSize: 18)),
*/
          ],),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: RichText(
              text:  TextSpan(
                style:  TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
                children: <TextSpan>
                [
                  TextSpan(
                      text: '${snapshot.get('username')} ', style: TextStyle(
                      fontWeight: FontWeight.bold,

                  )),
                  TextSpan(
                    text: snapshot.get('caption')
                  ),
                ],
              ),
              ),
          ),
          SizedBox(height: 8,),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Text(
                getTimeAgo(snapshot.get('time')),
                style: TextStyle(
                    color: constColors.whiteColor.withOpacity(0.4),
                    fontSize: 12
                )
            ),
          )

        ],),


    );
  }

  showPostOptions(BuildContext context, String postid, String caption)
  {
    return showModalBottomSheet(isScrollControlled: true, context: context, builder: (context)
    {
   //   if(captionEditController.text.isEmpty) captionEditController.text = caption;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            height:MediaQuery.of(context).size.height*0.35,
            decoration: BoxDecoration(
            color: constColors.blueGreyColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25))
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(25, 15, 0, 25),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  Center(child: Container(width: MediaQuery.of(context).size.width*0.4, height: 2, color: Colors.white.withOpacity(0.4),)),
                  SizedBox(height: 30),
                  Text('Update caption', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 0),
                          height: 100,
                          width: 5,
                          color: constColors.blueColor,

                        ),
                        SizedBox(width: 10),
                        Container(
                            width: MediaQuery.of(context).size.width*0.86,
                            child: TextField(
                                controller: captionEditController,
                                style: TextStyle(color: constColors.lightBlueColor),
                                inputFormatters:
                                [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(

                                    border: InputBorder.none,
                                    hintText: 'Post a caption..',
                                    hintStyle: TextStyle(
                                        color: constColors.whiteColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    )

                                ),
                                maxLines: 5
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children:
                    [
                      MaterialButton(
                          onPressed: ()
                          {
                            Provider.of<UploadPost>(context, listen: false).updateCaption(postid, captionEditController.text);
                            Navigator.pop(context);
                            captionEditController.clear();
                          },
                          child: Text("Update", style: TextStyle(color: Colors.white, fontSize: 15)), color: Colors.lightBlue),
                      Spacer(),
                      MaterialButton(
                        onPressed: ()
                        {
                          showDialog(context: context, builder: (BuildContext context)
                          {
                            return deleteConfirmDialog(context, postid);
                          });

                        },
                        child: Text("Delete Post", style: TextStyle(color: Colors.white, fontSize: 15)), color: Colors.red,),

                    ],),
                  )
                ],
            ),
          ),
        ),
      );
    });
  }

  deleteConfirmDialog(BuildContext context, String postid)
  {

    return AlertDialog(
      backgroundColor: constColors.darkColor,
      title: Text(
        'Delete this post? This action cannot be reversed.',
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
            Provider.of<UploadPost>(context, listen: false).deletePost(context, postid);
            Navigator.pop(context);
            Navigator.pop(context);

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



  displayAllLikes(BuildContext context, String postid)
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
                Text('Likes', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: MediaQuery.of(context).size.height*0.5,
                  child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("posts").doc(postid).collection("likes").orderBy('time', descending: true).snapshots(),
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
                                child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(snapshot.data?.docs[index].get('userimage')))),
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
                            snapshot.data?.docs[index].id!=Provider.of<Authentication>(context, listen: false).getUserUid()?
                            FollowBtn(snap: snapshot.data?.docs[index])
                                :Container()
                           // ElevatedButton(onPressed: (){}, child: Text('Follow',style: TextStyle(fontSize: 15),), ),
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

  displayComments(BuildContext context, String postid)
  {
    return showModalBottomSheet(isScrollControlled: true, context: context, builder: (context)
    {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(

            height:MediaQuery.of(context).size.height*0.6,
            decoration: BoxDecoration(
                color: constColors.blueGreyColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25))
            ),
            child: Column(
                children:
                [
                  SizedBox(height: 12),
                  Container(width: MediaQuery.of(context).size.width*0.4, height: 2, color: Colors.white.withOpacity(0.4),),
                  SizedBox(height: 17),
                  Text('Comments', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    height: MediaQuery.of(context).size.height*0.43,
                    child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("posts").doc(postid).collection("comments").orderBy('time', descending: true).snapshots(),
                      builder: (context, snapshot)
                      {
                        if(snapshot.connectionState==ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                        else return ListView.builder(itemCount: snapshot.data?.docs.length,itemBuilder: (context, index)
                        {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.only(left: 15),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                            [
                              GestureDetector(
                                  onTap: ()
                                  {
                                    Navigator.push(context, PageTransition(child: altProfile(userid:snapshot.data?.docs[index].get('uid')), type: PageTransitionType.leftToRight));

                                  },
                                  child: CircleAvatar(radius: 16, backgroundImage: NetworkImage(snapshot.data?.docs[index].get('imageURL')))),
                              SizedBox(width: 12,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text:  TextSpan(
                                        style:  TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                        children: <TextSpan>
                                        [
                                          TextSpan(
                                              text: '${snapshot.data?.docs[index].get('username')} ', style: TextStyle(
                                            fontWeight: FontWeight.bold,

                                          )),
                                          TextSpan(
                                              text: snapshot.data?.docs[index].get('comment')
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(

                                      child: Row(children:
                                      [
                                        Text(getTimeAgo(snapshot.data?.docs[index].get('time')), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14 )),
                                        SizedBox(width: 10),
                                        Text('${snapshot.data?.docs[index].get('likes')} ${snapshot.data?.docs[index].get('likes')>1?'likes':'like'}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14 )),
                                      ],),
                                    )
                                  ],
                                ),
                              ),
                              Spacer(),
                              /*
                              IconButton(
                                onPressed: ()
                                {
                                  Provider.of<LikesCommentsFirebase>(context, listen: false).likeComment(context, postid, '${snapshot.data?.docs[index].id}');
                                },
                                icon: Icon(FontAwesomeIcons.heart),
                                iconSize: 15,
                              ),
                              */

                              StreamBuilder<QuerySnapshot>(stream: Provider.of<LikesCommentsFirebase>(context, listen: false).hasUserLikedComment(context, postid, '${snapshot.data?.docs[index].id}'), builder: (context, sshot)
                              {
                                if(sshot.connectionState==ConnectionState.waiting)
                                  return IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.heart), color: constColors.whiteColor, iconSize: 15,);
                                else {
                                  if (sshot.data?.docs.length  == 0)
                                    return IconButton(
                                      onPressed: ()
                                      {
                                        Provider.of<LikesCommentsFirebase>(context, listen: false).likeComment(context, postid, '${snapshot.data?.docs[index].id}');
                                      },
                                      icon: Icon(FontAwesomeIcons.heart),
                                      iconSize: 15,
                                      color: constColors.whiteColor,
                                    );
                                  else
                                    return IconButton(
                                      onPressed: ()
                                      {
                                        Provider.of<LikesCommentsFirebase>(context, listen: false).removeLikeComment(context, postid, '${snapshot.data?.docs[index].id}');
                                      },
                                      icon: Icon(FontAwesomeIcons.solidHeart),
                                      iconSize: 15,
                                      color: constColors.redColor,
                                    );
                                }
                              }),



                            ],),
                          );
                        });
                      },
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(12,0,0,0),
                    child: Row(
                      children: [
                       CircleAvatar(radius: 17, backgroundImage: NetworkImage(Provider.of<FirebaseOperations>(context, listen: false).imageURL)),
                        SizedBox(width: 10),
                        Container(
                          width: MediaQuery.of(context).size.width*0.68,
                          child: TextField(
                              controller: commentController,
                              style: TextStyle(color: constColors.lightBlueColor),
                              inputFormatters:
                              [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              decoration: InputDecoration(

                                  border: InputBorder.none,
                                  hintText: 'Add a comment..',
                                  hintStyle: TextStyle(
                                      color: constColors.whiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                  )

                              ),
                              maxLines: 1
                          ),
                        ),
                        TextButton(
                            onPressed: ()
                            {

                              Provider.of<LikesCommentsFirebase>(context, listen: false).postComment(context, postid, commentController.text);
                              commentController.clear();
                              },
                            child: Text('Post'))
                      ],
                    ),
                  )

                ]
            )
        ),
      );
    });
  }

  selectUploadPost(BuildContext context)
  {
    return showModalBottomSheet(context: context, builder: (context)
    {
      return Container(
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width*0.5,
        decoration: BoxDecoration(
          color: constColors.blueGreyColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25))
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
          [
            ElevatedButton(
              onPressed: ()
              {
                Provider.of<UploadPost>(context, listen: false).pickUploadImage(context, ImageSource.camera);
              },
              child: Text('Camera' ,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),)
              ,),
            ElevatedButton(
              onPressed: ()
              {
                Provider.of<UploadPost>(context, listen: false).pickUploadImage(context, ImageSource.gallery);

              },
              child: Text('Gallery' ,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),)
              ,),
          ],
        ),
      );
    });
  }


  uploadPostDisplay(BuildContext context)
  {
    return showModalBottomSheet(context: context, isScrollControlled: true, builder: (context)
    {
      bool isUploading=false;
      return StatefulBuilder(builder:(context, setState)
      {

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(

            height: MediaQuery.of(context).size.height*0.6,
            decoration: BoxDecoration(
                color: constColors.blueGreyColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
            ),

            child: Column(
              children:
              [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width*0.4,
                  height: 1.5,
                  color: constColors.whiteColor,
                ),
                SizedBox(height: 15),
                Container(
                    height: MediaQuery.of(context).size.height*0.3,
                    width:  MediaQuery.of(context).size.width*0.85,

                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(File(Provider.of<UploadPost>(context, listen: false).pickedFile!.path))))
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      height: 100,
                      width: 5,
                      color: constColors.blueColor,

                    ),
                    SizedBox(width: 10),
                    Container(
                        width: MediaQuery.of(context).size.width*0.88,
                        child: TextField(
                            controller: captionController,
                            style: TextStyle(color: constColors.lightBlueColor),
                            inputFormatters:
                            [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: InputDecoration(

                                border: InputBorder.none,
                                hintText: 'Post a caption..',
                                hintStyle: TextStyle(
                                  color: constColors.whiteColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                                )

                            ),
                            maxLines: 5
                        )
                    ),
                  ],
                ),
                SizedBox(height: 20,),

                ElevatedButton(
                  onPressed: () {
                    setState(()
                    {
                      isUploading=true;
                    });
                    Provider.of<UploadPost>(context, listen: false)
                        .uploadPostImage(context)
                        .whenComplete(() {
                      if (Provider
                          .of<UploadPost>(context, listen: false)
                          .postURL == null) return;
                      Map<String, dynamic> m =
                      {

                        'postURL': '${Provider
                            .of<UploadPost>(context, listen: false)
                            .postURL}',
                        'caption': captionController.text,
                        'userid': '${Provider.of<Authentication>(
                            context, listen: false).getUserUid()}',
                        'username': '${Provider
                            .of<FirebaseOperations>(context, listen: false)
                            .name}',
                        'userimage': '${Provider
                            .of<FirebaseOperations>(context, listen: false)
                            .imageURL}',
                        'useremail': '${Provider
                            .of<FirebaseOperations>(context, listen: false)
                            .email}',
                        'time': Timestamp.now(),
                        'likes': 0,
                        'comments': 0
                      };
                      Provider.of<UploadPost>(context, listen: false)
                          .uploadPostToDB(context, m)
                          .whenComplete(() {
                        captionController.clear();
                        setState(()
                        {
                          isUploading=false;
                        });
                        Navigator.pop(context);
                      });
                    });
                  },
                  child: Text(isUploading?'Uploading..':"Share", style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold),),)
              ],
            ),
          ),
        );}
      );
    });

  }
}


