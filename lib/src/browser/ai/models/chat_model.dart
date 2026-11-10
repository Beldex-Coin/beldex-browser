import 'dart:io';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';

enum AttachmentType {
  image,
  pdf,
}

class ChatModel {
  String text;
  File? image;
  Roles role;
  List<File>? images;
  File? attachment;
  AttachmentType? attachmentType;
  bool isTypingComplete;
  bool isLoading;
  bool isTypingStopped;
  bool istyping;
  bool canShowRegenerate;
  bool isRetry;
  String typingText;
  bool isSummariseResult; 
  
  bool isImageGeneration;

   File? generatedImageFile;

   String? generatedImageBase64;

   bool isGeneratingImage;

  

  ChatModel({
    required this.text,
    required this.role,
    this.image,
    this.images,
    this.attachment,
    this.attachmentType,
    this.isTypingComplete = false,
    this.isLoading = false,
    this.isTypingStopped = false,
    this.canShowRegenerate = false,
    this.isRetry = false,
    this.typingText ='',
    this.istyping = false,
    this.isSummariseResult = false,
    this.isImageGeneration = false,
    this.generatedImageFile,
    this.generatedImageBase64,
    this.isGeneratingImage = false,
  });
}
