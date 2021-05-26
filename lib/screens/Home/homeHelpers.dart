import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:socialmedia/constants/colors.dart';
import 'package:socialmedia/database/firebaseops.dart';
import 'package:provider/provider.dart';

class HomeHelper with ChangeNotifier
{
  Widget bottomNavBar(int index, PageController pageController, BuildContext context)
  {
    ConstantColors constColors = ConstantColors();

    return CustomNavigationBar(
      currentIndex: index,
      bubbleCurve: Curves.bounceIn,
      scaleCurve: Curves.decelerate,
      selectedColor: constColors.blueColor,
      unSelectedColor: constColors.whiteColor,
      strokeColor: constColors.blueColor,
      scaleFactor: 0.5,
      iconSize: 30.5,
      onTap: (val)
      {
        index=val;
        pageController.jumpToPage(val);
        notifyListeners();
      },
      backgroundColor: Color(0xff040307),
      items:
        [
          CustomNavigationBarItem(icon: Icon(EvaIcons.home)),
          CustomNavigationBarItem(icon: Icon(EvaIcons.messageCircle)),
          CustomNavigationBarItem(
              icon: CircleAvatar(
                radius: 35,
                backgroundColor: constColors.blueGreyColor,
                backgroundImage: NetworkImage(Provider.of<FirebaseOperations>(context, listen: true).imageURL),

              ))


        ],
    );
  }
}