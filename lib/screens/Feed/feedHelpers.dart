
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
import 'package:socialmedia/screens/Feed/feedUpload.dart';
import 'dart:io';

class FeedHelpers with ChangeNotifier
{

  ConstantColors constColors = ConstantColors();
  TextEditingController captionController = new TextEditingController();
  feedAppBar(BuildContext context)
  {
    return AppBar(
      centerTitle: true,
      backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
        leading: IconButton(
            icon: Icon(Icons.menu),
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
              else return ListView.builder(
                  cacheExtent: MediaQuery.of(context).size.height*5,
                  itemCount: snapshot.data?.docs.length,

                  itemBuilder: (context, index)
                  {
                    return feedPost(snapshot.data!.docs[index], context);
                  }
              );
            }),);

  }

  Widget feedPost(DocumentSnapshot snapshot, BuildContext context)
  {
    log('doc id: ${snapshot.id}');
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          Container(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Row(
              children:
              [
                CircleAvatar(radius: 18, backgroundImage: NetworkImage(snapshot.get('userimage'))),
                SizedBox(width: 8,),
                Text(
                    snapshot.get('username'),
                    style: TextStyle(
                        color: constColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17
                    )
                ),
                Spacer(),
                Provider.of<Authentication>(context, listen: false).getUserUid()!=snapshot.get('userid')?Container():
                IconButton(
                    onPressed: ()
                    {

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
                child: Text('${snapshot.get('likes')}', style: TextStyle(color: constColors.whiteColor, fontSize: 20))),


            SizedBox(width: 18),

            IconButton(
              onPressed: ()
              {

              },
              icon: Icon(FontAwesomeIcons.comment),
              color: constColors.whiteColor,
              iconSize: 25,
            ),
            Text('8', style: TextStyle(color: constColors.whiteColor, fontSize: 20)),

            SizedBox(width: 18),

            IconButton(
              onPressed: ()
              {

              },
              icon: Icon(FontAwesomeIcons.award),
              color: constColors.whiteColor,
              iconSize: 23,
            ),
            Text('8', style: TextStyle(color: constColors.whiteColor, fontSize: 20)),

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
                '2 HOURS AGO',
                style: TextStyle(
                    color: constColors.whiteColor.withOpacity(0.4),
                    fontSize: 12
                )
            ),
          )

        ],),


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
                  child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("posts").doc(postid).collection("likes").snapshots(),
                    builder: (context, snapshot)
                    {
                      if(snapshot.connectionState==ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                      else return ListView.builder(itemCount: snapshot.data?.docs.length,itemBuilder: (context, index)
                      {
                        return Container(
                          child: Row(children:
                          [
                            CircleAvatar(radius: 18, backgroundImage: NetworkImage(snapshot.data?.docs[index].get('userimage'))),
                            SizedBox(width: 12,),
                            Text(
                                snapshot.data?.docs[index].get('username'),
                                style: TextStyle(
                                    color: constColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17
                                )
                            ),
                            Spacer(),
                            ElevatedButton(onPressed: (){}, child: Text('Follow',style: TextStyle(fontSize: 15),), ),
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
                onPressed: ()
                {

                  Provider.of<UploadPost>(context, listen: false).uploadPostImage(context).whenComplete(()
                  {
                    if(Provider.of<UploadPost>(context, listen: false).postURL==null) return;
                    Map<String, dynamic> m =
                    {

                      'postURL': '${Provider.of<UploadPost>(context, listen: false).postURL}',
                      'caption': captionController.text,
                      'userid': '${Provider.of<Authentication>(context, listen: false).getUserUid()}',
                      'username': '${Provider.of<FirebaseOperations>(context, listen: false).name}',
                      'userimage': '${Provider.of<FirebaseOperations>(context, listen: false).imageURL}',
                      'useremail': '${Provider.of<FirebaseOperations>(context, listen: false).email}',
                      'time': Timestamp.now(),
                      'like':0,
                      'comments':0
                    };
                    Provider.of<UploadPost>(context, listen: false).uploadPostToDB(m).whenComplete(()
                    {
                      Navigator.pop(context);
                    });
                  });
                },
                child: Text("Share", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),)
            ],
          ),
        ),
      );
    });

  }
}