import 'package:flutter/material.dart';
import 'package:socialmedia/constants/colors.dart';
import 'loginHelper.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  final ConstantColors constColors = ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constColors.whiteColor,  body: Column(children:
    [
      bodyColor(Column(crossAxisAlignment: CrossAxisAlignment.center,
        children:
      [
        Container(padding: EdgeInsets.fromLTRB(0, 50, 0, 0),child: Provider.of<LoginHelpers>(context, listen: false).Logo(context)),
        Container(padding: EdgeInsets.fromLTRB(0, 120, 20, 0),child: Provider.of<LoginHelpers>(context, listen: false).HelperText(context)),
      //  Container(padding: EdgeInsets.fromLTRB(0, 120, 20, 0),child: Provider.of<LoginHelpers>(context, listen: false).googleButton(context)),
     //   Container(padding: EdgeInsets.fromLTRB(0, 20, 20, 0),child: Provider.of<LoginHelpers>(context, listen: false).EmailLoginButton(context)),
        SizedBox(height: 30),
        Container(padding: EdgeInsets.fromLTRB(0, 20, 20, 0),child: Provider.of<LoginHelpers>(context, listen: false).LoginRevised(context)),

      ],)),

    ],),);
  }

  Widget bodyColor(Widget child)
  {
    return Expanded(
      child: Container(decoration: BoxDecoration
        (gradient: LinearGradient
        (begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.5, 0.9],
        colors:
        [constColors.darkColor,
          constColors.blueGreyColor
        ]

      )),child: child,),
    );
  }
}
