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
 Clipboard.setData(ClipboardData(text:text));
  showMessage('Copied');
}





  @override
  Widget build(BuildContext context) {
    final webviewModel = Provider.of<WebViewModel>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
             padding: const EdgeInsets.all(15.0),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                  children: [
                    SvgPicture.asset(IconConstants.userIcon),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(StringConstants.you,style: TextStyle(color: Color(0xff9595B5),fontFamily: 'Poppins',),),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: ()=> copyText(userMessage.text),
                      child: SvgPicture.asset(IconConstants.copyIconDark))
                  ],
                 ),
               
             userMessage.text.contains(webviewModel.title.toString()) ? Column(
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
                 MessageBody(
              isLoading: false,
              message: userMessage,
              topLeft: 20,
              topRight: 20,
              bottomLeft: 20,
              bottomRight: 20, canAnimate: currentResponseIndex == lastResponseIndex,
            )
               ],
             ),
           ),
            Divider(color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA)),

            Padding(
             padding: const EdgeInsets.all(15.0),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
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
                    GestureDetector(onTap: (){
                   if(modelMessage.text.isNotEmpty){
                    copyText(modelMessage.text);
                   }
                    },
                     child: SvgPicture.asset(IconConstants.copyIconDark))
                    
                  ],
                 ),
                 modelMessage.text.isNotEmpty || modelMessage.image != null
                 ? 
                MessageBody(
                    isLoading: true,
                    message: modelMessage,
                    topLeft: 20,
                    topRight: 20,
                    bottomLeft: 20,
                    bottomRight: 20, canAnimate: currentResponseIndex == lastResponseIndex,
                  )
                : 
                Container(
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

            // Align(
            //   alignment: Alignment.center,
            //   child: GestureDetector(
            //     onDoubleTap: (){

            //     },
            //     child: Container(
            //       height: 40,
            //       width: 130,
            //       padding: EdgeInsets.symmetric(vertical: 5),
            //       decoration: BoxDecoration(
            //        borderRadius: BorderRadius.circular(12),
            //               border: Border.all(color: Color(0xff42425F)),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Color(0xff42425F).withOpacity(0.2),
            //             offset: const Offset(0, 4),
            //             blurRadius: 6
            //           )
            //         ]
            //       ),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.refresh,size: 18,),
            //           Text('Regenerate')
            //         ],
            //       ),
            //     ),
            //   ),
            // )
               ],
             ),
           ),
           
           
           
            // // User Message
            // MessageBody(
            //   isLoading: false,
            //   message: userMessage,
            //   topLeft: 20,
            //   topRight: 20,
            //   bottomLeft: 20,
            //   bottomRight: 20,
            // ),
            // const SizedBox(height: 10),
            // // Model Response
            // modelMessage.text.isNotEmpty || modelMessage.image != null
            //     ? MessageBody(
            //         isLoading: false,
            //         message: modelMessage,
            //         topLeft: 20,
            //         topRight: 20,
            //         bottomLeft: 20,
            //         bottomRight: 20,
            //       )
            //     : const SizedBox(),
            // // Model Image (if exists)
            // if (modelMessage.image != null)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 10.0),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(20),
            //       child: Image(
            //         height: 200,
            //         image: FileImage(modelMessage.image!),
            //         fit: BoxFit.fill,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
