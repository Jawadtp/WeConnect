import 'package:flutter/material.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:socialmedia/screens/Chatroom/chatroom.dart';
import 'package:socialmedia/screens/Feed/feed.dart';
import 'package:socialmedia/screens/Home/homeHelpers.dart';
import 'package:socialmedia/screens/Profile/profile.dart';
import 'package:socialmedia/screens/search/search.dart';
import '../../database/auth.dart';
import 'package:provider/provider.dart';
import '../login/loginUtils.dart';
import '../../database/auth.dart';
import '../../constants/colors.dart';

class Home extends StatefulWidget
{

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
{

  Authentication auth = Authentication();

  final constColors = ConstantColors();
  int pageIndex=0;
  PageController pageController = PageController();

  /*  @override
  void initState()
    {
    Provider.of<FirebaseOperations>(context, listen: false).initUserData(context);

    super.initState();
  } */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constColors.darkColor,
      body: PageView(
        controller: pageController,
        children:
        [
          Feed(),
          Search(),
          Chatroom(),
          Profile()
        ],
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page)
        {
          setState(()
          {
            pageIndex=page;
          });

        },
      ),
      bottomNavigationBar: Provider.of<HomeHelper>(context, listen: false).bottomNavBar(pageIndex, pageController, context),
      );
  }
}

//         Text('User id: ${Provider.of<Authentication>(context, listen: false).getUserUid()}'),