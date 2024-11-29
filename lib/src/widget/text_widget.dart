
import 'package:beldex_browser/src/browser/custom_popup_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  const TextWidget({super.key, required this.text, this.style, this.textAlign = TextAlign.start, this.maxLines, this.overflow});

  @override
  Widget build(BuildContext context) {
    return Text( 
       text,
       textAlign: textAlign,
       style: style ?? TextStyle(),
       maxLines: maxLines,
       overflow: overflow,
    );
  }
}


class PopupMenuListWidget extends StatelessWidget {
  final String choice;
  final TextStyle? style;
  final String image;
  final bool enabled;
  final Color? color;
  const PopupMenuListWidget({super.key, required this.choice, this.style, this.color, required this.image, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('assets/images/Belnet.svg',
                                color: color),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextWidget( text: choice,
                                  style: style),
                            ),
                          ]),
                    ),
                  );
  }
}