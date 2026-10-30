import 'dart:convert';
import 'dart:io';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/ai/constants/color_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/attachment_preview.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/audio/read_aloud_controller.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/full_screen_image_viewer.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/generated_image_preview.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/image_generation_loader.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/message_body.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MessagePair extends StatefulWidget {
  const MessagePair({
    super.key,
    required this.userMessage,
    required this.modelMessage,
    required this.model, required this.currentResponseIndex, required this.lastResponseIndex,
    
  });

  final ChatModel userMessage;
  final ChatModel modelMessage;
  final ChatViewModel model;
  final int currentResponseIndex;
  final int lastResponseIndex;



  @override
  State<MessagePair> createState() => _MessagePairState();
}

class _MessagePairState extends State<MessagePair> {

  bool _isSharing = false;


bool containsUrl(String text) {
  // Regular expression for detecting URLs
  final urlRegex = RegExp(
    r'((http|https):\/\/)?([a-zA-Z0-9\-_]+(\.[a-zA-Z0-9\-_]+)+)(\/[^\s]*)?',
    caseSensitive: false,
  );

  return urlRegex.hasMatch(text);
}

copyText(String text,AppLocalizations loc){
 Clipboard.setData(ClipboardData(text:removeSpecialFormatting(text)));
  showMessage(loc.copied);
}

String removeSpecialFormatting(String text) {
  String cleanText = text
      // Remove bold (**text**)
      .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '')
      // Remove italic (*text*)
      .replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '')
      // Remove only • bullet points (keeping - )
      .replaceAll(RegExp(r'^•\s+', multiLine: true), '')
      // Remove stray $1 that might have crept in
      .replaceAll(RegExp(r'\$1'), '')
      // Remove numbered list markers (e.g., "1. ", "2. ")
      .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
      // Remove Markdown headers (#, ##, ###, etc.) at start of lines
      .replaceAll(RegExp(r'^#+ ', multiLine: true), '')
      // Remove extra newlines and trim whitespace
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();
  
  return cleanText;
}

  // Debounce function to handle share action
  Future<void> _shareContent(String userMessage, String modelMessage) async {
    if (_isSharing) return; // Ignore if already sharing

    _isSharing = true; // Set flag to block further clicks
 print("The UnFormatted text --->${removeSpecialFormatting(modelMessage)}");
 ShareResult result = await SharePlus.instance.share(ShareParams(text:
      'You:\n${removeSpecialFormatting(userMessage)}\nBeldex AI:\n${removeSpecialFormatting(modelMessage)}')
    );
    // ShareResult result = await Share.shareWithResult(
    //   'You:\n$userMessage\nBeldex AI:\n$modelMessage',
    // );

    _isSharing = false; // Reset flag after share completes

    if (result.status == ShareResultStatus.success) {
      print('Shared successfully');
    } else if (result.status == ShareResultStatus.dismissed) {
      print('Share dismissed');
    }
  }


 
Widget _buildImagePreview(ChatModel message) {
  final files = message.images;

  if (files == null || files.isEmpty) {
    return const SizedBox.shrink();
  }

  if (files.length == 1) {
    return Container(
        height: 70,width: 70,
        child: AttachmentPreview(file: files[0],
                onTap: (){
                  showFullScreenImagePreview(
                        context,
                        files,
                        0,
                      );
                }),
    );
  }

  if (files.length == 2) {
    return SizedBox(
    width: 140,
    height: 70,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: files.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index == 0 ? 4 : 0,
          ),
          child: SizedBox(
            width: 70,
            height: 70,
            child: AttachmentPreview(file: files[index],
                onTap: (){
                  showFullScreenImagePreview(
                        context,
                        files,
                        index,
                      );
                }),
          ),
        );
      },
    ),
  );
  }

  final displayCount = files.length > 4 ? 4 : files.length;




  return SizedBox(
     width: 115,
  height: 115,
    child: GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final showMore = index == 3 && files.length > 4;
    
        return Stack(
          fit: StackFit.expand,
          children: [
               AttachmentPreview(file: files[index],
                onTap: (){
                  showFullScreenImagePreview(
                        context,
                        files,
                        index,
                      );
                }),
            
            //_attachmentItem(files[index]),
            if (showMore)
              GestureDetector(
                onTap: (){
                    showFullScreenImagePreview(
                        context,
                        files,
                        index,
                      );
                },
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    '+${files.length - 4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
Widget _attachmentItem(File file) {
  final filePath = file.path.toLowerCase();
  final fileName = file.path.split('/').last;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      _openAttachment(file);
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: _isImageExtension(filePath)
          ? Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _invalidFilePreview(fileName);
              },
            )
          : _buildAttachmentFilePreview(fileName, filePath),
    ),
  );
}


Future<void> _openAttachment(
  File file, {
  List<File>? allFiles,
  int initialIndex = 0,
}) async {
  final filePath = file.path.toLowerCase();

  if (_isImageExtension(filePath)) {
    final images = allFiles
            ?.where((f) => _isImageExtension(f.path.toLowerCase()))
            .toList() ??
        [file];

    final imageIndex = images.indexWhere(
      (f) => f.path == file.path,
    );

    showFullScreenImagePreview(
      context,
      images,
      imageIndex >= 0 ? imageIndex : 0,
    );
    return;
  }

  if (filePath.endsWith('.pdf')) {
    await _openPdfPreview(file);
    return;
  }

  try {
    final result = await OpenFilex.open(file.path);
    debugPrint('Open attachment result: ${result.message}');
  } catch (e) {
    debugPrint('Unable to open attachment: $e');
  }
}
Future<void> _openPdfPreview(File file) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(file.path.split('/').last),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ),
          body: PdfView(
            controller: PdfController(
              document: PdfDocument.openFile(file.path),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildAttachmentFilePreview(
  String fileName,
  String filePath,
) {
  final extension = filePath.split('.').last;

  IconData icon = Icons.insert_drive_file_outlined;
  Color iconColor = Colors.blueGrey;

  if (extension == 'pdf') {
    icon = Icons.picture_as_pdf;
    iconColor = Colors.red;
  } else if (['doc', 'docx'].contains(extension)) {
    icon = Icons.description;
    iconColor = Colors.blue;
  } else if (['xls', 'xlsx', 'csv'].contains(extension)) {
    icon = Icons.table_chart;
    iconColor = Colors.green;
  } else if (['ppt', 'pptx'].contains(extension)) {
    icon = Icons.slideshow;
    iconColor = Colors.orange;
  } else if (extension == 'txt') {
    icon = Icons.text_snippet;
  }

  return Container(
    color: Colors.grey.shade100,
    padding: const EdgeInsets.all(6),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: iconColor,
        ),
        const SizedBox(height: 5),
        Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}


bool _isImageExtension(String filePath) {
  return filePath.endsWith('.jpg') ||
      filePath.endsWith('.jpeg') ||
      filePath.endsWith('.png') ||
      filePath.endsWith('.webp') ||
      filePath.endsWith('.gif') ||
      filePath.endsWith('.bmp') ||
      filePath.endsWith('.heic') ||
      filePath.endsWith('.heif');
}

// Widget _filePreview(String fileName) {
//   return Container(
//     color: Colors.grey.shade100,
//     padding: const EdgeInsets.all(10),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//           Icons.insert_drive_file_outlined,
//           size: 32,
//         ),
//         const SizedBox(height: 6),
//         Text(
//           fileName,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 11),
//         ),
//       ],
//     ),
//   );
// }
Widget _filePreview(
  String fileName, {
  IconData icon = Icons.insert_drive_file_outlined,
  Color iconColor = Colors.blueGrey,
  Color? backgroundColor,
}) {
  return Container(
    color: backgroundColor ?? Colors.grey.shade100,
    padding: const EdgeInsets.all(6),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: iconColor,
        ),
        const SizedBox(height: 5),
        Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

Widget _invalidFilePreview(String fileName) {
  return Container(
    color: Colors.grey.shade100,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(8),
    child: const Icon(
      Icons.broken_image_outlined,
      color: Colors.grey,
      size: 30,
    ),
  );
}

// Widget _invalidFilePreview(String fileName) {
//   return Container(
//     color: Colors.grey.shade100,
//     alignment: Alignment.center,
//     padding: const EdgeInsets.all(8),
//     child: const Icon(
//       Icons.broken_image_outlined,
//       color: Colors.grey,
//       size: 30,
//     ),
//   );
// }


  @override
  Widget build(BuildContext context) {
    final webviewModel = Provider.of<WebViewModel>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0
      ),
      child: GlassGroupPanel(
        color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4),
        child: Container(
          decoration: BoxDecoration(
            //color: ColorConstants.grey7A8194,
            //borderRadius: BorderRadius.circular(12),
            //border: Border.all(color:themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA))
          ),
          //padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
             Padding(
               padding: const EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom: 10),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                    children: [
                      SvgPicture.asset(themeProvider.darkTheme ? IconConstants.userIconDark : IconConstants.userIconWhite),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(loc.you,style: TextStyle(color: Color(0xff8D8D8D),fontFamily: 'Inter',),),
                      ),
                      Spacer(),
        
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: GestureDetector(
                          onTap: ()=> copyText(widget.userMessage.text,loc),
                          child: SvgPicture.asset(IconConstants.copyIconDark,color: Color(0xff8D8D8D),)),
                      ),
        
                        Padding(
                          padding: const EdgeInsets.only(left:10.0,),
                          child: Visibility(
                            visible: widget.userMessage.text.isNotEmpty && widget.modelMessage.text.isNotEmpty ,
                            child: GestureDetector(
                            onTap: _isSharing ? null : ()=> _shareContent(widget.userMessage.text, widget.modelMessage.text),
                          //   ()async{
                          //     //Share.share('You:\n${userMessage.text}\nBeldex AI:\n${modelMessage.text}', subject:'');
                          //  ShareResult result =  await Share.shareWithResult('You:\n${userMessage.text}\nBeldex AI:\n${modelMessage.text}');
                           
                          //   },
                            child: SvgPicture.asset(IconConstants.shareIcon,color: Color(0xff8D8D8D),)),
                          ),
                        )
                    ],
                   ),
                 
                  widget.userMessage.images?.isNotEmpty == true  //userMessage.images?.length != 0
                 ? Container(
        padding: const EdgeInsets.all(3),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50.withOpacity(0.1),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildImagePreview(widget.userMessage),
      )
//                   Container(
//   height: 115,
//   width: 115,
//   padding: EdgeInsets.all(3),
//   margin: EdgeInsets.only(top: 10),
//   decoration: BoxDecoration(
//     color: Colors.grey.shade50.withOpacity(0.1),
//     //borderRadius: BorderRadius.circular(10),
//   ),
//   clipBehavior: Clip.antiAlias,
//   child: _buildImagePreview(widget.userMessage),
// )
: SizedBox.shrink(),

 widget.userMessage.text.contains(webviewModel.title.toString()) || widget.userMessage.text.contains('null - Summarise page') ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:8.0),
                      child: Text(loc.summariseThisPage,style: TextStyle(fontFamily: 'Inter'),),
                    ),
                    Container(
                      //height: 30,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:themeProvider.darkTheme ? Color(0xff222222): Color(0xffFFFFFF),
                        border: Border.all(
                          color:themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4)
                        ),
                        //borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right:8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:  Image.network(webviewModel.favicon?.url.toString() ?? '',height: 20,width: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return Container();//Icon(Icons.)
                              },
                              // loadingBuilder: (context, child, loadingProgress) {
                              //   return ;
                              // },
                              ),
                            ),
                          ),
                          Expanded(child: Text(webviewModel.title ?? 'Summarise ', style: TextStyle(fontFamily: 'Inter',fontSize: 14),)),
                        ],
                      ),
                    )
                  ],
                 ):
                widget.userMessage.text.isNotEmpty ? Padding(
                   padding: const EdgeInsets.symmetric(vertical :8.0),
                   child: SelectableText(widget.userMessage.text,
                   style: TextStyle( fontSize: 14,
                    fontFamily: 'Inter'),
                     contextMenuBuilder: (
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return AdaptiveTextSelectionToolbar(
      anchors: editableTextState.contextMenuAnchors,
      children: [
        // Copy
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            editableTextState.copySelection(
              SelectionChangedCause.toolbar,
            );
          },
          child: const Text('Copy'),
        ),

        // Select All
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            editableTextState.selectAll(
              SelectionChangedCause.toolbar,
            );
          },
          child: const Text('Select All'),
        ),

        // Share
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            final selectedText = editableTextState
                .textEditingValue
                .selection
                .textInside(
                  editableTextState.textEditingValue.text,
                );

            Share.share(
              selectedText.isNotEmpty
                  ? selectedText
                  : widget.userMessage.text,
            );

            editableTextState.hideToolbar();
          },
          child: const Text('Share'),
        ),
      ],
    );
  },    
                    ),
                 ): SizedBox.shrink(),
              //      MessageBody(
              //   isLoading: false,
              //   message: userMessage,
              //   topLeft: 20,
              //   topRight: 20,
              //   bottomLeft: 20,
              //   model: model,
              //   bottomRight: 20, canAnimate: currentResponseIndex == lastResponseIndex,
              // )
                 ],
               ),
             ),
              SizedBox(
                //color: Colors.green,
                height: 2,
                child: Divider(
                  
                  color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4)),
              ),
        
              // Padding(
              //  padding: const EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom: 10),
              // child: 
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Padding(
                     padding:const EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom: 10),
                     child: Row(
                      children: [
                        SvgPicture.asset(IconConstants.beldexAILogoSvg,
                        width: 18,
                        height: 18,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(loc.beldexAI,
                            //StringConstants.beldexAI,
                            style : TextStyle(color: Color(0xff8D8D8D),fontFamily: 'Inter',
                          ),),
                        ),
                        Spacer(),
                       modelMessage.text.isNotEmpty && modelMessage.text != StringConstants.retryMessage && modelMessage.text != 'The response has been interrupted' ? GestureDetector(onTap: (){
                       if(modelMessage.text.isNotEmpty){
                        copyText(modelMessage.text,loc);
                       }
                        },
                         child: SvgPicture.asset(IconConstants.copyIconDark,color: Color(0xff8D8D8D),)):SizedBox()
                        
                      ],
                     ),
                   ),
                   modelMessage.text.isNotEmpty || modelMessage.image != null
                   ? 
                  MessageBody(
                      isLoading: true,
                      message: modelMessage,
                      topLeft: 20,
                      topRight: 20,
                      bottomLeft: 20,
                      model: model,
                      bottomRight: 20, canAnimate: currentResponseIndex == lastResponseIndex,
                    )
                  : 
                  Center(
                    child: Padding(
                      padding:const EdgeInsets.only(left:15.0,right:15.0,bottom: 10),
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                         color://themeProvider.darkTheme ?
                          Color(0xff333333),// : Color(0xffF3F3F3),
                         borderRadius: BorderRadius.circular(20.0)
                        ),
                                    padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 15),
                                    child: LoadingAnimationWidget.waveDots(
                      color://themeProvider.darkTheme ?
                       Color(0xff8D8D8D),// : Color(0xffACACAC),
                      size: 30,
                                    ),
                                  ),
                    ),
                  ),
                 ],
               ),
            // ),
             
            ],
          ),
        ),
      ),
    );
  }
}
