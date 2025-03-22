import 'dart:io';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';


class ChatModel {
  String text;
  File? image;
  Roles role;
  bool isTypingComplete;
  bool isLoading;
  bool isTypingStopped;
  bool istyping;
  bool canShowRegenerate;
  bool isRetry;
  String typingText;
  bool isSummariseResult;

  ChatModel({
    required this.text,
    required this.role,
    this.image,
    this.isTypingComplete = false,
    this.isLoading = false,
    this.isTypingStopped = false,
    this.canShowRegenerate = false,
    this.isRetry = false,
    this.typingText ='',
    this.istyping = false,
    this.isSummariseResult = false
  });
}
