import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/login/loginUtils.dart';
import '../../constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class LoginServices with ChangeNotifier
{
  ConstantColors constColors = ConstantColors();
  Widget PasswordLessSignIn(BuildContext context)
  {
    return SizedBox(height: MediaQuery.of(context).size.height*0.4,
    width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("allUsers").snapshots(),builder: (context, snapshot)
      {
        if(snapshot.connectionState==ConnectionState.waiting)
          {
            return Center(child: CircularProgressIndicator(),);
          }
        else
          {
            return ListView.builder(itemCount: snapshot.data?.docs.length,itemBuilder: (context, index)
            {
              return ListTile(leading: CircleAvatar(backgroundImage: NetworkImage(snapshot.data?.docs[index].get('userimage')),
                              ),
                title: Text(snapshot.data!.docs[index].get('username'), style: TextStyle(fontWeight: FontWeight.bold, color: constColors.greenColor),),
                subtitle: Text(snapshot.data!.docs[index].get('useremail'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: constColors.greenColor),),
                trailing: IconButton(icon: Icon(FontAwesomeIcons.trashAlt), onPressed: (){}),
              );
            });
          }
      },),
    );
  }

  showUserAvatar(BuildContext context)
  {
    return showModalBottomSheet(context: context, builder: (context)
    {
      return Container(height: MediaQuery.of(context).size.height*0.3,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constColors.blueGreyColor, borderRadius: BorderRadius.circular(15)),
      child: Column(children:
      [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
          child: Divider(thickness: 4, color: constColors.whiteColor,),
        ),

        CircleAvatar(
          radius: 80, backgroundColor: constColors.transparent, backgroundImage:
            FileImage(
                File(Provider.of<LoginUtils>(context, listen: false).pickedFile!.path)
              ),
            ),
        
        Container(
          child: Row(
              children:
              [
                MaterialButton(onPressed: ()
                {
                  Provider.of<LoginUtils>(context, listen: false).pickUserAvatar(context, ImageSource.gallery);
                }, child: Text('Reselect', style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: constColors.whiteColor),),),

                MaterialButton(color: constColors.blueColor,
                  onPressed: ()
                {
                  Provider.of<FirebaseOperations>(context, listen: false).uploadUserAvatar(context);

                }, child: Text('Confirm image', style: TextStyle(color: constColors.whiteColor, fontWeight: FontWeight.bold,)),)
              ],),),
      ],),);
    });
  }
  

}