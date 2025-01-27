import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/common_pop_up_item.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:flutter/material.dart';

class PopUpWidget extends StatelessWidget {
  const PopUpWidget({super.key, required this.model});
  final ChatViewModel? model;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 70),
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: ColorConstants.grey373E4E,
        margin: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PopUpItem(
                icon: Icons.photo_library_rounded,
                text: StringConstants.gallery,
                onTap: () {
                  FocusScope.of(context).unfocus();
                 // model?.pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                firstIconBackgroundColor: ColorConstants.blueAccent,
                secondIconBackgroundColor: ColorConstants.blue,
              ),
              const SizedBox(
                width: 50,
              ),
              PopUpItem(
                icon: Icons.camera_alt,
                text: StringConstants.camera,
                onTap: () {
                  FocusScope.of(context).unfocus();
                 // model?.pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                firstIconBackgroundColor: ColorConstants.pink,
                secondIconBackgroundColor: ColorConstants.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class AIChatPopupMenuActions {
  // ignore: constant_identifier_names
  static const String COPY_CHAT = "Copy";
  // ignore: constant_identifier_names
  static const String SHARE_CHAT = "Share";
  // ignore: constant_identifier_names
  static const String DELETE_CHAT = "Delete";

  static const List<String> choices = <String>[
    COPY_CHAT,
    SHARE_CHAT,
    DELETE_CHAT
   // NEW_INCOGNITO_TAB
  ];
}