import 'dart:async';

import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
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
    required this.bottomRight, required this.canAnimate,
  });

  final bool isLoading;
  final ChatModel message;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  final bool canAnimate;

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
 String text = '';
 String textChars = "";
  Timer? typingTimer;
bool canStop = false;

@override
  void initState() {
     super.initState();
    parseResponse(widget.message.text,context);
   
  }



void parseResponse(String response,BuildContext context) {
   //final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context,listen: false);
    // Split response into lines
    List<String> lines = response.split("\n");

    // Extract title (assume the first non-empty line is the title)
    text = lines.join("\n");
       // lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");
       Future.delayed(Duration(milliseconds: 150),(){
           if(widget.canAnimate){
              ///if(urlSummaryProvider.isSummarise == false)
              _startTypingAnimation(context);
           }
   
       });
      
  }

void _startTypingAnimation(BuildContext context) {
   final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context,listen: false);
    int titleIndex = 0;
  
    textChars = "";
  
    typingTimer?.cancel();
  
    typingTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if(canStop == false){
        urlSummaryProvider.updateCanStop(true);
         // Type the title character by character
      if (titleIndex < text.length && urlSummaryProvider.canStopAndRegenerate) {
        setState(() {
          
          textChars += text[titleIndex];
          titleIndex++;

        });
      }
       else {
        // Stop the timer once all text is typed
        timer.cancel();
        urlSummaryProvider.updateCanStop(false);
        setState(() {
          canStop= true;
        });
      }
      }
     
    });
   // urlSummaryProvider.updateSummariser(false);
  }


@override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 15.0,
      ),
      decoration: BoxDecoration(
       // color: Colors.green, //ColorConstants.grey7A8194,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.topLeft),
          topRight: Radius.circular(widget.topRight),
          bottomLeft: Radius.circular(widget.bottomLeft),
          bottomRight: Radius.circular(widget.bottomRight),
        ),
      ),
      child:
       
       widget.isLoading && textChars.isNotEmpty && urlSummaryProvider.isSummarise == false
          ? 
           md.Markdown(
            data:textChars, //widget.message.text,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            styleSheet: md.MarkdownStyleSheet.fromTheme(
              Theme.of(context).copyWith(
              textTheme: TextTheme(bodyMedium: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                //color: ColorConstants.white,
                fontSize: 14,
                //fontWeight: FontWeight.w400,
                )),
            ),
            )
           ,
            )
          : urlSummaryProvider.isSummarise == true ?
            md.Markdown(
            data:widget.message.text,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            styleSheet: md.MarkdownStyleSheet.fromTheme(
              Theme.of(context).copyWith(
              textTheme: TextTheme(bodyMedium: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                //color: ColorConstants.white,
                fontSize: 14,
                //fontWeight: FontWeight.w400,
                )),
            ),
            )
           ,
            )
          // : widget.canAnimate == false ?
          //   md.Markdown(
          //   data:widget.message.text,
          //   shrinkWrap: true,
          //   padding: EdgeInsets.zero,
          //   styleSheet: md.MarkdownStyleSheet.fromTheme(
          //     Theme.of(context).copyWith(
          //     textTheme: TextTheme(bodyMedium: TextStyle(color: ColorConstants.white,
          //       fontSize: 14,
          //       //fontWeight: FontWeight.w400,
          //       )),
          //   ),
          //   )
          //  ,
          //   )
          :
          md.Markdown(
            data:widget.message.text,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            styleSheet: md.MarkdownStyleSheet.fromTheme(
              Theme.of(context).copyWith(
              textTheme: TextTheme(bodyMedium: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                //color: ColorConstants.white,
                fontSize: 14,
                //fontWeight: FontWeight.w400,
                )),
            ),
            )
           ,
            )
    );
  }
}
