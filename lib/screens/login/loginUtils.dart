import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/screens/login/loginServices.dart';
import 'loginHelper.dart';

class LoginUtils with ChangeNotifier
{
  final picker = ImagePicker();
  String avatarURL='';
  PickedFile? pickedFile;
  String getAvatarURL()
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
    //  Navigator.pop(context); //Model bottoms sheets stack up on each other unless they are closed manually. Hence, it makes sense to programmatically close them.
     // Provider.of<LoginHelpers>(context, listen: false).SignInSheet(context);
      notifyListeners();
    }
    else log('Image picked is NULL');
  }


}