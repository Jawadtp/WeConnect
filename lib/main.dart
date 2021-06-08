import 'package:flutter/material.dart';
import 'package:socialmedia/database/auth.dart';
import 'package:socialmedia/screens/Chatroom/chatroomHelpers.dart';
import 'package:socialmedia/screens/Chatroom/chatroomUtils.dart';
import 'package:socialmedia/screens/Feed/LikesAndComments/LikesCommentFirebase.dart';
import 'package:socialmedia/screens/Home/homeHelpers.dart';
import 'screens/splash.dart';
import 'constants/colors.dart';
import 'package:provider/provider.dart';
import 'screens/login/loginHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login/loginServices.dart';
import 'screens/login/loginUtils.dart';
import 'database/firebaseops.dart';
import 'screens/Profile/profileHelpers.dart';
import 'screens/Feed/feedHelpers.dart';
import 'screens/Feed/feedDatabase.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  ConstantColors constColors = ConstantColors();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(accentColor: constColors.blueColor,
          canvasColor: constColors.transparent,
        hintColor: constColors.blueColor,
        primaryColor: constColors.blueColor
      ),
      home: SplashScreen(),
    ),
      providers:
      [
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => LoginHelpers()),
        ChangeNotifierProvider(create: (_) => LoginServices()),
        ChangeNotifierProvider(create: (_) => LoginUtils()),
        ChangeNotifierProvider(create: (_) => FirebaseOperations()),
        ChangeNotifierProvider(create: (_) => HomeHelper()),
        ChangeNotifierProvider(create: (_) => ProfileHelpers()),
        ChangeNotifierProvider(create: (_) => FeedHelpers()),
        ChangeNotifierProvider(create: (_) => UploadPost()),
        ChangeNotifierProvider(create: (_) => LikesCommentsFirebase()),
        ChangeNotifierProvider(create: (_) => ChatroomHelpers()),
        ChangeNotifierProvider(create: (_) => ChatroomUtils()),



      ],
    );
  }
}

