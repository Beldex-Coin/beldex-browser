

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



  PreferredSize _appbars(){
     var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
  return PreferredSize(
    preferredSize:Size.fromHeight(90),
     child: Container(
          height:45,
          width: double.infinity,
          margin: EdgeInsets.only(top: 40,left:15,right:15,bottom: 8),
          decoration: BoxDecoration(
            color: Color(0xff282836),
            borderRadius: BorderRadius.circular(8)
          ),
         child: Row(
          children: [
           // _buildSearchList(),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical:8.0),
            child: VerticalDivider(
              color: Color(0xff42425F),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              onSubmitted: (value) {
                var url = WebUri(value.trim());
                if (!url.scheme.startsWith("http") &&
                    !Util.isLocalizedContent(url)) {
                  url = WebUri(settings.searchEngine.searchUrl + value);
                }
            
                if (webViewController != null) {
                  webViewController.loadUrl(urlRequest: URLRequest(url: url));
                } else {
                 // addNewTab(url: url);
                  webViewModel.url = url;
                }
              },
               keyboardType: TextInputType.url,
              //focusNode: _focusNode,
              autofocus: false,
              //controller: _searchController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
                  border: InputBorder.none,
                  hintText: "Search for or type a web address",
              hintStyle: const TextStyle(color: Colors.black54, fontSize: 16.0,),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
            ),

          ),
          Expanded(
            flex: 1,
            child: Container(
              width: 80,
             // height: 40,
              //color: Colors.green,
              child: Row(
                children:
                 [
                  IconButton(icon: Icon(Icons.more_horiz),onPressed: (){

                  },)
                ]
                // _buildActionsMenu(),
              ),
            ),
          )
          ],
         ),
     ));
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