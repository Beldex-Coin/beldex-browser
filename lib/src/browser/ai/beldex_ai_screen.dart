

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BeldexAIPage extends StatefulWidget {
  const BeldexAIPage({super.key});

  @override
  State<BeldexAIPage> createState() => _BeldexAIPageState();
}

class _BeldexAIPageState extends State<BeldexAIPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
           appBar: PreferredSize(preferredSize: Size(MediaQuery.of(context).size.width,80),
               child:buildAppBar(context) ),
         body: buildBody(context),

    );
  }

  Widget buildAppBar(BuildContext context){
    return Padding(
    padding: const EdgeInsets.only(left: 10,top:40,bottom: 20),
     child: ListTile(
       leading: Container(
         margin: EdgeInsets.all(3),
         child: SvgPicture.asset('assets/images/browser.svg'),
       ),
       title: Text(
         'Beldex AI'
       ),
     ),
    );
  }




  Widget buildBody(BuildContext context){
    return Column(
      children: [
        Expanded(child: Container()),
         TextField(
          minLines: 1,
           maxLines: null,
           keyboardType: TextInputType.text,
           keyboardAppearance: Brightness.dark,
           cursorColor: Colors.white54,
           style: TextStyle(color: Colors.white),
           decoration: InputDecoration(
            counterStyle: TextStyle(
              color: Colors.white54,
            ),
            hintText: 'Type message',
            hintStyle: TextStyle(color: Colors.white54,fontSize: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.0)
           ),
         )
      ],
    );
  }
}
