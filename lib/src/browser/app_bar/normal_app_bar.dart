import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';

class NormalAppBar extends StatefulWidget {
  const NormalAppBar({super.key, required this.title});

  final String title;

  @override
  State<NormalAppBar> createState() => _NormalAppBarState();
}

class _NormalAppBarState extends State<NormalAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xff171720),
      leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )),
      centerTitle: true,
      title: TextWidget(
       text: widget.title,
        style:TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
