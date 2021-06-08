import 'package:flutter/material.dart';
import 'package:socialmedia/constants/colors.dart';

class ChatScreen extends StatelessWidget
{
  var snapshot;
  ConstantColors constColors = ConstantColors();
  ChatScreen({@required this.snapshot});


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        backgroundColor: constColors.blueGreyColor.withOpacity(0.4),
        leading: IconButton(onPressed: () {Navigator.of(context).pop();},icon: Icon(Icons.arrow_back_ios), color: constColors.whiteColor.withOpacity(0.4),),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(snapshot.get('imageURL'))),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snapshot.get('name'), style: TextStyle(color: Colors.white),),
                SizedBox(height: 3,),
                Text('15 members', style: TextStyle(color: Colors.white.withOpacity(0.4),fontSize: 13)),

              ],
            ),

          ],
        ),
        actions:
        [
          IconButton(
              icon: Icon(Icons.add, color: constColors.greenColor, size: 30,),
              onPressed: ()
              {

              }
          )
        ],
      ),
      body: Container(child: Stack(children: [
        Container(child: Container(child: Text('message to be fetched')), padding: EdgeInsets.only(bottom: 80),),

        Container(alignment:Alignment(1,0.99),child: Container(margin:EdgeInsets.symmetric(horizontal: 20,vertical: 10),padding:EdgeInsets.only(left: 10),decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: /*Color(0xFFe3e3cf)*/ Colors.white,border: Border.all(color:Color(0xFFe3e3cf),width: 2.0 )),
          child: Row(
            children: [
              Expanded(child: TextField(decoration: InputDecoration(border:InputBorder.none,hintText: "Enter message..",hintStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.5))),)),
              Container(decoration:BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blue),child: IconButton(icon: Icon(Icons.send,size: 22,color: Colors.white,),onPressed: ()
              {
                //msg.clear();
              },))
            ],
          ),
        ),)
      ],),),
    );
  }
}
