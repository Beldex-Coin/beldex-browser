import 'dart:io';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';


class ChatModel {
  String text;
  File? image;
  Roles role;

  ChatModel({
    required this.text,
    required this.role,
    this.image,
  });
}
