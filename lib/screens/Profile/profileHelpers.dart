import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/constants/colors.dart';

class ProfileHelpers with ChangeNotifier
{
  Widget HeaderProfile(BuildContext context, dynamic snapshot)
  {
    ConstantColors constColors = ConstantColors();
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.2,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children:
        [
          Container(
            height: 200,
            width: 180,
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}