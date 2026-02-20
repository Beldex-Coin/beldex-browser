

import 'package:beldex_browser/src/browser/app_bar/tab_viewer_app_bar.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class TabsList extends StatefulWidget {
  const TabsList({super.key});

  @override
  State<TabsList> createState() => _TabsListState();
}

class _TabsListState extends State<TabsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
       appBar: TabViewerAppBar(),
       
       body: Padding(
         padding: const EdgeInsets.all(8.0),
         child: const TabGridView(),
       ), //_appbars() ,
    );
  }





}


class TabGridView extends StatelessWidget {
  const TabGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 images per row
        crossAxisSpacing: 8.0, // spacing between columns
        mainAxisSpacing: 8.0, // spacing between rows
      ) ,
      itemCount: 1,
       itemBuilder: ((context, index) {
         return Container(
            height:100,
            padding: EdgeInsets.all(10),
            //margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color:const Color(0xff282836),
              borderRadius: BorderRadius.circular(10)

            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  const Icon(Icons.close,color:Colors.white)
                  ],
                ),
                Expanded(
                  child: Container(
                    margin:const EdgeInsets.only(top:5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  
                )),
              ],
            ),
         );
       }));
  }
}