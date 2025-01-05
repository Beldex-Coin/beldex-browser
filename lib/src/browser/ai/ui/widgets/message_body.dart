import 'dart:async';

import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MessageBody extends StatefulWidget {
  const MessageBody({
    super.key,
    required this.isLoading,
    required this.message,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final bool isLoading;
  final ChatModel message;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
 String text = '';
 String textChars = "";
  Timer? typingTimer;


@override
  void initState() {
     super.initState();
    _parseResponse(widget.message.text);
   
  }



void _parseResponse(String response) {
    // Split response into lines
    List<String> lines = response.split("\n");

    // Extract title (assume the first non-empty line is the title)
    text = lines.join("\n");
       // lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");
    _startTypingAnimation();
  }

void _startTypingAnimation() {
    int titleIndex = 0;

    textChars = "";

    typingTimer?.cancel();

    typingTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Type the title character by character
      if (titleIndex < text.length) {
        setState(() {
          textChars += text[titleIndex];
          titleIndex++;
        });
      }
       else {
        // Stop the timer once all text is typed
        timer.cancel();
      }
    });
  }


@override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
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
      child: widget.isLoading == true 
          ?  md.Markdown(
            data:textChars, //widget.message.text,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            styleSheet: md.MarkdownStyleSheet.fromTheme(
              Theme.of(context).copyWith(
              textTheme: TextTheme(bodyMedium: TextStyle(color: ColorConstants.white,
                fontSize: 14,
                //fontWeight: FontWeight.w400,
                )),
            ),
            )
           ,
            )
          : 
          md.Markdown(
            data:widget.message.text,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            styleSheet: md.MarkdownStyleSheet.fromTheme(
              Theme.of(context).copyWith(
              textTheme: TextTheme(bodyMedium: TextStyle(color: ColorConstants.white,
                fontSize: 14,
                //fontWeight: FontWeight.w400,
                )),
            ),
            )
           ,
            )
          
          
          // Text(
          //     message.text,
          //     style: const TextStyle(
          //       color: ColorConstants.white,
          //       fontSize: 14,
          //       fontWeight: FontWeight.w400,
          //     ),
          //   ),
    );
  }
}
