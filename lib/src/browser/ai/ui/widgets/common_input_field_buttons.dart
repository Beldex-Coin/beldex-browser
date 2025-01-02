import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:flutter/material.dart';

class InputFieldButton extends StatelessWidget {
  const InputFieldButton(
      {super.key, required this.icon, required this.onpressed});

  final IconData icon;
  final Function onpressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onpressed();
      },
      icon: Icon(
        icon,
        color: ColorConstants.white54,
      ),
    );
  }
}
