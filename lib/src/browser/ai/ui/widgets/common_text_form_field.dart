import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({super.key, required this.model});

  final ChatViewModel? model;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () {
        if (model?.showEmoji == true) {
          model?.setShowEmoji = false;
        }
      },
      onEditingComplete: () {
        if (model?.messageController.text.toString().isNotEmpty ?? false) {
          model?.getTextAndImageInfo();
          model?.messageController.clear();
        }
      },
      minLines: 1,
      maxLines: null,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      cursorColor: ColorConstants.white54,
      style: const TextStyle(color: ColorConstants.white),
      controller: model?.messageController,
      decoration: InputDecoration(
        counterStyle: const TextStyle(color: ColorConstants.white54),
        hintText: StringConstants.typeMessage,
        hintStyle: const TextStyle(color: ColorConstants.white54, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
      ),
    );
  }
}
