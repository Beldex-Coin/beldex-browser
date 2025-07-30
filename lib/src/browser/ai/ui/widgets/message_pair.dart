import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/message_body.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MessagePair extends StatelessWidget {
  const MessagePair({
    super.key,
    required this.userMessage,
    required this.modelMessage,
    required this.model, required this.currentResponseIndex, required this.lastResponseIndex,
    
  });

  final ChatModel userMessage;
  final ChatModel modelMessage;
  final ChatViewModel model;
  final int currentResponseIndex;
  final int lastResponseIndex;

bool containsUrl(String text) {
  // Regular expression for detecting URLs
  final urlRegex = RegExp(
    r'((http|https):\/\/)?([a-zA-Z0-9\-_]+(\.[a-zA-Z0-9\-_]+)+)(\/[^\s]*)?',
    caseSensitive: false,
  );

  return urlRegex.hasMatch(text);
}


copyText(String text){
 Clipboard.setData(ClipboardData(text:removeSpecialFormatting(text)));
  showMessage('Copied');
}

String removeSpecialFormatting(String text) {
  String cleanText = text
      // Remove bold (**text**)
      .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '')
      // Remove italic (*text*)
      .replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '')
      // Remove only • bullet points (keeping - )
      .replaceAll(RegExp(r'^•\s+', multiLine: true), '')
      // Remove stray $1 that might have crept in
      .replaceAll(RegExp(r'\$1'), '')
      // Remove numbered list markers (e.g., "1. ", "2. ")
      .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
      // Remove Markdown headers (#, ##, ###, etc.) at start of lines
      .replaceAll(RegExp(r'^#+ ', multiLine: true), '')
      // Remove extra newlines and trim whitespace
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();
  
  return cleanText;
}

static bool _isSharing = false;

  // Debounce function to handle share action
  Future<void> _shareContent(String userMessage, String modelMessage) async {
    if (_isSharing) return; // Ignore if already sharing

    _isSharing = true; // Set flag to block further clicks
 print("The UnFormatted text --->${removeSpecialFormatting(modelMessage)}");
 ShareResult result = await SharePlus.instance.share(ShareParams(text:
      'You:\n${removeSpecialFormatting(userMessage)}\nBeldex AI:\n${removeSpecialFormatting(modelMessage)}')
    );
    // ShareResult result = await Share.shareWithResult(
    //   'You:\n$userMessage\nBeldex AI:\n$modelMessage',
    // );

    _isSharing = false; // Reset flag after share completes

    if (result.status == ShareResultStatus.success) {
      print('Shared successfully');
    } else if (result.status == ShareResultStatus.dismissed) {
      print('Share dismissed');
    }
  }


  @override
  Widget build(BuildContext context) {
    final webviewModel = Provider.of<WebViewModel>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0
      ),
      child: Container(
        decoration: BoxDecoration(
          //color: ColorConstants.grey7A8194,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color:themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA))
        ),
        //padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
           Padding(
             padding: const EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom: 10),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                  children: [
                    SvgPicture.asset(themeProvider.darkTheme ? IconConstants.userIconDark : IconConstants.userIconWhite),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(StringConstants.you,style: TextStyle(color: Color(0xff9595B5),fontFamily: 'Poppins',),),
                    ),
                    Spacer(),

                    GestureDetector(
                      onTap: ()=> copyText(userMessage.text),
                      child: SvgPicture.asset(IconConstants.copyIconDark)),

                      Padding(
                        padding: const EdgeInsets.only(left:10.0),
                        child: Visibility(
                          visible: userMessage.text.isNotEmpty && modelMessage.text.isNotEmpty ,
                          child: GestureDetector(
                          onTap: _isSharing ? null : ()=> _shareContent(userMessage.text, modelMessage.text),
                        //   ()async{
                        //     //Share.share('You:\n${userMessage.text}\nBeldex AI:\n${modelMessage.text}', subject:'');
                        //  ShareResult result =  await Share.shareWithResult('You:\n${userMessage.text}\nBeldex AI:\n${modelMessage.text}');
                         
                        //   },
                          child: SvgPicture.asset(IconConstants.shareIcon)),
                        ),
                      )
                  ],
                 ),
               
             userMessage.text.contains(webviewModel.title.toString()) || userMessage.text.contains('null - Summarise page') ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:8.0),
                    child: Text('Summarise this page',style: TextStyle(fontFamily: 'Poppins'),),
                  ),
                  Container(
                    //height: 30,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:themeProvider.darkTheme ? Color(0xff292937): Color(0xffF3F3F3),
                      border: Border.all(
                        color:themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDDDDDD)
                      ),
                      borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right:8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:  Image.network(webviewModel.favicon?.url.toString() ?? '',height: 20,width: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return Container();//Icon(Icons.)
                            },
                            // loadingBuilder: (context, child, loadingProgress) {
                            //   return ;
                            // },
                            ),
                          ),
                        ),
                        Expanded(child: Text(webviewModel.title ?? 'Summarise ')),
                      ],
                    ),
                  )
                ],
               ):
               Padding(
                 padding: const EdgeInsets.symmetric(vertical :8.0),
                 child: Text(userMessage.text,style: TextStyle( fontSize: 14,
                  fontFamily: 'Poppins'),),
               ),
            //      MessageBody(
            //   isLoading: false,
            //   message: userMessage,
            //   topLeft: 20,
            //   topRight: 20,
            //   bottomLeft: 20,
            //   model: model,
            //   bottomRight: 20, canAnimate: currentResponseIndex == lastResponseIndex,
            // )
               ],
             ),
           ),
            SizedBox(
              //color: Colors.green,
              height: 2,
              child: Divider(
                
                color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA)),
            ),

            // Padding(
            //  padding: const EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom: 10),
            // child: 
             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Padding(
                   padding:const EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom: 10),
                   child: Row(
                    children: [
                      SvgPicture.asset(IconConstants.beldexAILogoSvg,
                      width: 18,
                      height: 18,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(StringConstants.beldexAI,style : TextStyle(color: Color(0xff9595B5),fontFamily: 'Poppins',
                        ),),
                      ),
                      Spacer(),
                     modelMessage.text.isNotEmpty && modelMessage.text != StringConstants.retryMessage && modelMessage.text != 'The response has been interrupted' ? GestureDetector(onTap: (){
                     if(modelMessage.text.isNotEmpty){
                      copyText(modelMessage.text);
                     }
                      },
                       child: SvgPicture.asset(IconConstants.copyIconDark)):SizedBox()
                      
                    ],
                   ),
                 ),
                 modelMessage.text.isNotEmpty || modelMessage.image != null
                 ? 
                MessageBody(
                    isLoading: true,
                    message: modelMessage,
                    topLeft: 20,
                    topRight: 20,
                    bottomLeft: 20,
                    model: model,
                    bottomRight: 20, canAnimate: currentResponseIndex == lastResponseIndex,
                  )
                : 
                Padding(
                  padding:const EdgeInsets.only(left:15.0,right:15.0,bottom: 10),
                  child: Container(
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                     color:themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                     borderRadius: BorderRadius.circular(12.0)
                    ),
                                padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 15),
                                child: LoadingAnimationWidget.waveDots(
                  color:themeProvider.darkTheme ? Color(0xff9595B5) : Color(0xffACACAC),
                  size: 30,
                                ),
                              ),
                ),
               ],
             ),
          // ),
           
          ],
        ),
      ),
    );
  }
}
