import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/screens/Feed/feedHelpers.dart';
import 'package:socialmedia/constants/colors.dart';

class Feed extends StatelessWidget
{
  ConstantColors constColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: Provider.of<FeedHelpers>(context, listen: false).feedAppBar(
          context),
      body: Provider.of<FeedHelpers>(context, listen: false).feedBody(context),
    );
  }

}
//