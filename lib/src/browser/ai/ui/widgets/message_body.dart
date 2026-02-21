import 'dart:async';
import 'dart:io';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class MessageBody extends StatefulWidget {
  const MessageBody({
    super.key,
    required this.isLoading,
    required this.message,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.model,
    required this.bottomRight, required this.canAnimate,
  });

  final bool isLoading;
  final ChatModel message;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;
  final ChatViewModel model;
  final bool canAnimate;

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
 String text = '';
 String textChars = "";
  Timer? typingTimer;
bool canStop = false;
Dio dio = Dio();

@override
  void initState() {
     super.initState();
    parseResponse(widget.message.text,context);
   
  }



void parseResponse(String response,BuildContext context) {
   //final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context,listen: false);
    // Split response into lines
   
    // List<String> lines = response.split("\n");

    // // Extract title (assume the first non-empty line is the title)
    // text = lines.join("\n");
       // lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");
       Future.delayed(Duration(milliseconds: 150),(){

        if(widget.message.text == StringConstants.retryMessage){
         // checkNetworkConnectivity();
        }
          //  if(widget.canAnimate){
          //     ///if(urlSummaryProvider.isSummarise == false)
          //     _startTypingAnimation(context);
          //  }
   
       });
      
  }
//
// void _startTypingAnimation(BuildContext context) {
//    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context,listen: false);
//     int titleIndex = 0;
//
//     textChars = "";
//
//     typingTimer?.cancel();
//
//     typingTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
//       if(canStop == false){
//         urlSummaryProvider.updateCanStop(true);
//          // Type the title character by character
//       if (titleIndex < text.length && urlSummaryProvider.canStopAndRegenerate) {
//         setState(() {
//
//           textChars += text[titleIndex];
//           titleIndex++;
//
//         });
//       }
//        else {
//         // Stop the timer once all text is typed
//         timer.cancel();
//         urlSummaryProvider.updateCanStop(false);
//         setState(() {
//           canStop= true;
//         });
//       }
//       }
//
//     });
//    // urlSummaryProvider.updateSummariser(false);
//   }
//


void checkNetworkConnectivity(AppLocalizations loc)async{
  final connectivityResult = await Connectivity().checkConnectivity();

 // if(connectivityResult.contains(ConnectivityResult.vpn)){
   if(!(connectivityResult.contains(ConnectivityResult.mobile)) && !(connectivityResult.contains(ConnectivityResult.wifi))){
       print('mobile network not connected $connectivityResult');
    showMessage(loc.youAreNotConnectedToInternet);
    return;
   }
  else{
    // Step 2: Test Actual Internet Access
  bool hasInternet = await _hasInternetAccess();

   if (!hasInternet) {
     showMessage(loc.unprecidentedTrafficExitNodeError);
    print("mobile network is ON & Internet is Working");
  }
  }

   
  // else {
    
  //   print("Network is ON but No Internet (Possible VPN Issue)");
  // }
}



Future<bool> _hasInternetAccess() async {
  try {
    final response = await dio.get("https://www.google.com")
        .timeout(Duration(seconds: 5)); // Timeout to avoid long waits

    if (response.statusCode == 200) {
      return true; // Internet is working
    } else {
      return false; // Response but no internet access
    }
  } on SocketException catch (_) {
    return false; // No Internet (VPN, Firewall, or DNS issue)
  } on TimeoutException catch (_) {
    return false; // Timeout means no internet
  }
}

setNewModel(AIModelProvider aiModelProvider)async{
  String currentModels = aiModelProvider.selectedModel;
  String currentModel = currentModels;
  // print('the AI model providers value currently ----$currentModel');
  // // Keep initializing the model until a different one is selected
  // do {

    await aiModelProvider..initializeModel();
    Future.delayed(Duration(milliseconds: 150),(){});
    print('New AI model attempt:$currentModel --------   ${aiModelProvider.selectedModel}');
  // } while (aiModelProvider.selectedModel == currentModel);

}

@override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final aiModelProvider = Provider.of<AIModelProvider>(context);
    final webViewModel = Provider.of<WebViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    //final typingProvider = Provider.of<TypingProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        //horizontal: 8.0,
      ),
      decoration: BoxDecoration(
       // color: Colors.green, //ColorConstants.grey7A8194,
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(widget.topLeft),
        //   topRight: Radius.circular(widget.topRight),
        //   bottomLeft: Radius.circular(widget.bottomLeft),
        //   bottomRight: Radius.circular(widget.bottomRight),
        // ),
      ),
      child:Column(
        children:[
         
            
            widget.message.text == StringConstants.retryMessage
            ? Padding(
              padding: const EdgeInsets.only(left:15.0,right:15.0),
              child: Row(
                children: [
                  SvgPicture.asset('assets/images/ai-icons/errors.svg'),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(widget.message.text,style: TextStyle(fontSize: 13,color:themeProvider.darkTheme ? Color(0xff56566B) : Color(0xffACACAC),
                    fontFamily: 'Poppins'),),
                  )
                ],
              ),
            ):
             Padding(
               padding: const EdgeInsets.only(left:15.0,right:15.0),
               child: md.Markdown(
                           data:widget.message.text,
                           shrinkWrap: true,
                           padding: EdgeInsets.zero,
                           physics: NeverScrollableScrollPhysics(),
                           styleSheet: md.MarkdownStyleSheet.fromTheme(
                Theme.of(context).copyWith(
                textTheme: TextTheme(bodyMedium: TextStyle(//color: themeProvider.darkTheme ? Colors.white : Colors.black, // Colors.yellow,
                  fontSize: 14,
                  fontFamily: 'Poppins'
                  //fontWeight: FontWeight.w400,
                  )),
                           ),
                           ),
                           ),
             ),

            Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Visibility(
                visible:widget.message.text == StringConstants.retryMessage,
                 child:
                 Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: GestureDetector(
                  onTap:widget.message.isRetry ? (){
                     // typingProvider.updateAITypingState(true);
                   checkNetworkConnectivity(loc);
                   
                  setNewModel(aiModelProvider);
                  if(widget.message.isSummariseResult){
                    print('Error retry button is calling');
              
                    widget.model.regenerateSummarization(webViewModel,aiModelProvider.selectedModel,loc);
                   }else{
                    print('Error else retry button is calling');
                    widget.model.retryResponse(aiModelProvider);
                   }
                   
                   //
              
                   setState(() {
                     widget.message.canShowRegenerate = false;
                     widget.message.isTypingComplete = false;
                     widget.message.isRetry = false;
                    });                             
                  }: null,
                  child: Column(
                    children: [
                     SizedBox(
                //color: Colors.green,
                height: 2,
                child: Divider(
                  
                  color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA)),
              ),
                Padding(
                  padding: const EdgeInsets.only(top:13.0),
                  child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                            SvgPicture.asset('assets/images/ai-icons/retry.svg',color: widget.message.isRetry ? Color(0xff00B134) : themeProvider.darkTheme ? Color(0xff56566B) : Color(0xffACACAC),),
                             Padding(
                               padding: const EdgeInsets.only(left:5.0),
                               child: Text(loc.retry,style: TextStyle(fontFamily: 'Poppins', color: widget.message.isRetry ? Color(0xff00B134) : themeProvider.darkTheme ? Color(0xff56566B) : Color(0xffACACAC)),),
                             ),
                           ],
                         ),
                ),
                    ],
                  )
                  
                  // Container(
                  //   margin: EdgeInsets.symmetric(vertical: 10),
                  //    padding: const EdgeInsets.symmetric(vertical: 9.0,horizontal: 12.0),
                  //    width: 95,
                  //    decoration: BoxDecoration(
                  //     color: themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                  //     borderRadius: BorderRadius.circular(12)
                  //    ),
                  //      child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //        children: [
                  //         SvgPicture.asset('assets/images/ai-icons/Vector.svg'),
                  //          Text('Retry',style: TextStyle(fontFamily: 'Poppins'),),
                  //        ],
                  //      ),
                  // ),
                ),
                            
                //             Center(
                //               child: ElevatedButton(
                // onPressed: () {
                //   // typingProvider.updateAITypingState(true);
                //    checkNetworkConnectivity();
                //   setNewModel(aiModelProvider);
              
                //    widget.model.retryResponse(aiModelProvider);
              
                //    setState(() {
                //      widget.message.canShowRegenerate = false;
                //      widget.message.isTypingComplete = false;
                //      widget.message.isRetry = false;
                //     });
              
                // },
                // child: Text("Retry"),
                //               ),
                //             ),
                 )
                
                ),
            ),
            
            
            
            
            Visibility(
              visible: widget.message.canShowRegenerate,
              child:
              
              GestureDetector(
                onTap: (){
                      //regenerateResponse(typingProvider);
                 // typingProvider.updateAITypingState(true);
                 widget.model.regenerateResponse();
               setState(() {
                   widget.message.canShowRegenerate = false;
                   widget.message.isTypingComplete = false;
                  });
                // Define button action here
                //print("Button clicked!");
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                   padding: const EdgeInsets.symmetric(vertical: 9.0,horizontal: 12.0),
                  // width: 127,
                   decoration: BoxDecoration(
                    color: themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(12)
                   ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                        SvgPicture.asset('assets/images/ai-icons/Vector.svg'),
                        SizedBox(width: 5,),
                         Text(loc.regenerate,style: TextStyle(fontFamily: 'Poppins'),),
                       ],
                     ),
                ),
              ),
              
              
              // Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 20.0),
              //             child: Center(   
              //               child: ElevatedButton(
              // onPressed: () {
              //   //regenerateResponse(typingProvider);
              //    // typingProvider.updateAITypingState(true);
              //    widget.model.regenerateResponse();
              //  setState(() {
              //      widget.message.canShowRegenerate = false;
              //      widget.message.isTypingComplete = false;
              //     });
              //   // Define button action here
              //   print("Button clicked!");
              // },
              // child: Text("Regenerate"),
              //               ),
              //             ),
              //           )
              
               )
        ]
      )
    );
  }
}
