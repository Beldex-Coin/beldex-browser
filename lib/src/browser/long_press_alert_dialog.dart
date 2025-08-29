// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/custom_image.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/browser_model.dart';
import 'models/webview_model.dart';
import 'util.dart';
import 'package:http/http.dart' as http;

class LongPressAlertDialog extends StatefulWidget {
  static const List<InAppWebViewHitTestResultType> hitTestResultSupported = [
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE
  ];

  const LongPressAlertDialog(
      {super.key,
      required this.webViewModel,
      required this.hitTestResult,
      this.requestFocusNodeHrefResult});

  final WebViewModel webViewModel;
  final InAppWebViewHitTestResult hitTestResult;
  final RequestFocusNodeHrefResult? requestFocusNodeHrefResult;

  @override
  State<LongPressAlertDialog> createState() => _LongPressAlertDialogState();
}

class _LongPressAlertDialogState extends State<LongPressAlertDialog> {
  var _isLinkPreviewReady = false;

  bool _isShare = false;

  @override
  void didUpdateWidget(covariant LongPressAlertDialog oldWidget) {
    if (_isShare)
      new Timer(const Duration(milliseconds: 300), () {
        setState(() => _isShare = false);
      });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      //contentPadding: const EdgeInsets.all(0.0),
      insetPadding: const EdgeInsets.all(0),
      child: _buildDialogLongPressHitTestResult(themeProvider)
      //  Container(
      //   decoration: BoxDecoration(
      //       color: themeProvider.darkTheme
      //           ? const Color(0xff171720)
      //           : const Color(0xffFFFFFF),
      //       borderRadius: BorderRadius.circular(5)),
      //   width: MediaQuery.of(context).size.width * 0.03,
      //   height: MediaQuery.of(context).size.height / 2.2,
      //   //width:double.maxFinite,
      //   child: LayoutBuilder(builder: (context, constraints) {
      //     return Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       // mainAxisSize: MainAxisSize.min,
      //       children:
      //           _buildDialogLongPressHitTestResult(themeProvider, constraints),
      //     );
      //   }),
      // ),
    );
  }


Widget _buildDialogLongPressHitTestResult(
      DarkThemeProvider themeProvider) {
         var browserModel = Provider.of<BrowserModel>(context, listen: false);
     var settings = browserModel.getSettings();
    if (widget.hitTestResult.type ==
            InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
        widget.hitTestResult.type ==
            InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
        (widget.hitTestResult.type ==
                InAppWebViewHitTestResultType.IMAGE_TYPE &&
            widget.requestFocusNodeHrefResult != null &&
            widget.requestFocusNodeHrefResult!.url != null &&
            widget.requestFocusNodeHrefResult!.url.toString().isNotEmpty)) {
      return Container(
        decoration: BoxDecoration(
            color: themeProvider.darkTheme
                ? const Color(0xff171720)
                : const Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width * 0.03,
        height: MediaQuery.of(context).size.height / 2.8,
        //width:double.maxFinite,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
        _buildLinkTile(constraints),
        Divider(
          color: themeProvider.darkTheme
              ? const Color(0xff42425F)
              : const Color(0xffDADADA),
          height: 0.05,
          thickness: 0.30,
        ),
        _buildOpenNewTab(constraints),
       // _buildOpenNewIncognitoTab(constraints),
        _buildCopyAddressLink(constraints),
        _buildShareLink(constraints),
        SizedBox(
          height: 10,
        )
      ]
                
          );
        }),
      );
      
      
       
    } else if (widget.hitTestResult.type ==
        InAppWebViewHitTestResultType.IMAGE_TYPE) {
      return Container(
        decoration: BoxDecoration(
            color: themeProvider.darkTheme
                ? const Color(0xff171720)
                : const Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width * 0.03,
        height:settings.searchEngine.name == 'Google' || settings.searchEngine.name == 'Bing' ?  MediaQuery.of(context).size.height / 2.2 : MediaQuery.of(context).size.height / 2.8,
        //width:double.maxFinite,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // mainAxisSize: MainAxisSize.min,
            children:<Widget>[
        _buildImageTile(constraints),
        Divider(
          color: themeProvider.darkTheme
              ? const Color(0xff42425F)
              : const Color(0xffDADADA),
          height: 0.05,
          thickness: 0.30,
        ),
        SizedBox(
          height: 10,
        ),
        _buildOpenImageNewTab(constraints),
        _buildDownloadImage(constraints),
       settings.searchEngine.name == 'Google' || settings.searchEngine.name == 'Bing' ? _buildSearchImageOnGoogle(constraints): SizedBox.shrink(),
        _buildShareImage(constraints),
        // SizedBox(height: 10,)
      ]
                
          );
        }),
      );
      
      
    }

    return Container();
  }







  // List<Widget> _buildDialogLongPressHitTestResult(
  //     DarkThemeProvider themeProvider, BoxConstraints constraints) {
  //   if (widget.hitTestResult.type ==
  //           InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
  //       widget.hitTestResult.type ==
  //           InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
  //       (widget.hitTestResult.type ==
  //               InAppWebViewHitTestResultType.IMAGE_TYPE &&
  //           widget.requestFocusNodeHrefResult != null &&
  //           widget.requestFocusNodeHrefResult!.url != null &&
  //           widget.requestFocusNodeHrefResult!.url.toString().isNotEmpty)) {
  //     return <Widget>[
  //       _buildLinkTile(constraints),
  //       Divider(
  //         color: themeProvider.darkTheme
  //             ? const Color(0xff42425F)
  //             : const Color(0xffDADADA),
  //         height: 0.05,
  //         thickness: 0.30,
  //       ),
  //       _buildOpenNewTab(constraints),
  //       //_buildOpenNewIncognitoTab(constraints),
  //       _buildCopyAddressLink(constraints),
  //       _buildShareLink(constraints),
  //       SizedBox(
  //         height: 10,
  //       )
  //     ];
  //   } else if (widget.hitTestResult.type ==
  //       InAppWebViewHitTestResultType.IMAGE_TYPE) {
  //     return <Widget>[
  //       _buildImageTile(constraints),
  //       Divider(
  //         color: themeProvider.darkTheme
  //             ? const Color(0xff42425F)
  //             : const Color(0xffDADADA),
  //         height: 0.05,
  //         thickness: 0.30,
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       _buildOpenImageNewTab(constraints),
  //       _buildDownloadImage(constraints),
  //       _buildSearchImageOnGoogle(constraints),
  //       _buildShareImage(constraints),
  //       // SizedBox(height: 10,)
  //     ];
  //   }

  //   return [];
  // }

  Widget _buildLinkTile(BoxConstraints constraints) {
    var url =
        widget.requestFocusNodeHrefResult?.url ?? Uri.parse("about:blank");
    var faviconUrl = Uri.parse("${url.origin}/favicon.ico");

    var title = widget.requestFocusNodeHrefResult?.title ?? "";
    if (title.isEmpty) {
      title = "Link";
    }

    return SizedBox(
        height: constraints.maxHeight * 0.23, //80,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                //width: constraints.maxWidth*0.25,
                //color: Colors.green,
                padding: EdgeInsets.all(20),
                child: CustomImage(
                  url:
                      // widget.requestFocusNodeHrefResult?.src != null
                      //     ? Uri.parse(widget.requestFocusNodeHrefResult!.src!)
                      //     :
                      faviconUrl,
                  // maxWidth: 30.0,
                  //  height: 30.0,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                // width: constraints.maxWidth*0.50,
                //color: Colors.blue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                    ),
                    TextWidget(
                      text:
                          widget.requestFocusNodeHrefResult?.url?.toString() ??
                              "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
        // ListTile(
        //   contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        //   leading: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       // CachedNetworkImage(
        //       //   placeholder: (context, url) => CircularProgressIndicator(),
        //       //   imageUrl: widget.requestFocusNodeHrefResult?.src != null ? widget.requestFocusNodeHrefResult!.src : faviconUrl,
        //       //   height: 30,
        //       // )
        //       CustomImage(
        //         url:
        //         // widget.requestFocusNodeHrefResult?.src != null
        //         //     ? Uri.parse(widget.requestFocusNodeHrefResult!.src!)
        //         //     :
        //             faviconUrl,
        //         maxWidth: 30.0,
        //         height: 30.0,
        //       )
        //     ],
        //   ),
        //   title: Text(
        //     title,
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //     style: TextStyle(fontSize: 13,fontWeight:FontWeight.normal
        //     ),
        //   ),
        //   subtitle: Text(
        //     widget.requestFocusNodeHrefResult?.url?.toString() ?? "",
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //     style: TextStyle(fontSize: 13,fontWeight:FontWeight.normal
        //     ),
        //   ),
        //   isThreeLine: true,
        // ),
        );
  }

  Widget _buildLinkPreview() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    browserModel.getSettings();

    return ListTile(
      title: const Center(child: Text("Link Preview")),
      subtitle: Container(
        padding: const EdgeInsets.only(top: 15.0),
        height: 250,
        child: IndexedStack(
          index: _isLinkPreviewReady ? 1 : 0,
          children: <Widget>[
            const Center(
              child: CircularProgressIndicator(),
            ),
            InAppWebView(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              initialUrlRequest:
                  URLRequest(url: widget.requestFocusNodeHrefResult?.url),
              initialSettings: InAppWebViewSettings(
                  verticalScrollbarThumbColor:
                      const Color.fromRGBO(0, 0, 0, 0.5),
                  horizontalScrollbarThumbColor:
                      const Color.fromRGBO(0, 0, 0, 0.5)),
              onProgressChanged: (controller, progress) {
                if (progress > 50) {
                  setState(() {
                    _isLinkPreviewReady = true;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOpenNewTab(BoxConstraints constraints) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    final selectedItemsProvider =
        Provider.of<SelectedItemsProvider>(context, listen: false);
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    return ListTile(
      title: const TextWidget(
        text: "Open in new tab",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
      onTap: () {
        webViewModel.settings?.minimumFontSize =
            selectedItemsProvider.fontSize.round();
            vpnStatusProvider.updateCanShowHomeScreen(false);
        browserModel.addTab(WebViewTab(
          key: GlobalKey(),
          webViewModel: WebViewModel(
              url: widget.requestFocusNodeHrefResult?.url,
              settings: webViewModel.settings),
        ));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildOpenNewIncognitoTab(BoxConstraints constraints) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    final selectedItemsProvider =
        Provider.of<SelectedItemsProvider>(context, listen: false);
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    return ListTile(
      title: const TextWidget(
        text: "Open in new private tab",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
      onTap: () {
        webViewModel.settings?.minimumFontSize =
            selectedItemsProvider.fontSize.round();
        browserModel.addTab(WebViewTab(
          key: GlobalKey(),
          webViewModel: WebViewModel(
              url: widget.requestFocusNodeHrefResult?.url,
              isIncognitoMode: true,
              settings: webViewModel.settings),
        ));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCopyAddressLink(BoxConstraints constraints) {
    return ListTile(
      title: const TextWidget(
        text: "Copy address link",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: widget.requestFocusNodeHrefResult?.url.toString() ??
                widget.hitTestResult.extra ??
                ''));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildShareLink(BoxConstraints constraints) {
    return ListTile(
      title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: "Share link",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
            Icon(
              Icons.share,
              // color: Colors.black54,
              size: 20.0,
            )
          ]),
      onTap: () {
        if (widget.hitTestResult.extra != null) {
          Share.share(widget.requestFocusNodeHrefResult?.url.toString() ??
              widget.hitTestResult.extra!);
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildImageTile(BoxConstraints constraints) {
    final image =
        widget.hitTestResult.extra != null ? widget.hitTestResult.extra! : "";
    print('the image is ------> $image');

    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);

    // List<int> imageList = base64.decode(image);

    return SizedBox(
        height: constraints.maxHeight * 0.23, //80,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                  //width: constraints.maxWidth*0.25,
                  //color: Colors.green,
                  padding: EdgeInsets.all(15),
                  child: Image.network(
                    _decodeUrlIfNeeded(image),
                    errorBuilder: ((context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image_sharp,
                        size: 50,
                        color: themeProvider.darkTheme
                            ? Color(0xff6D6D81)
                            : Color(0xffC5C5C5),
                      );
                    }),
                  )
                  //  CustomImage(
                  //   url: // Uri.parse(image),
                  //   // maxWidth: 50.0,
                  //   // height: 50.0
                  // ),
                  ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: widget.webViewModel.title ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                  // Text(
                  // widget.requestFocusNodeHrefResult?.url?.toString() ?? "",
                  // maxLines: 1,
                  // overflow: TextOverflow.ellipsis,
                  // style: TextStyle(fontSize: 13,fontWeight:FontWeight.normal
                  // ),
                  //         ),
                ],
              ),
            )
          ],
        ));

    // return ListTile(
    //   contentPadding: const EdgeInsets.only(
    //       left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
    //   leading: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       // CachedNetworkImage(
    //       //   placeholder: (context, url) => CircularProgressIndicator(),
    //       //   imageUrl: widget.hitTestResult.extra,
    //       //   height: 50,
    //       // ),
    //       Expanded(
    //         child: CustomImage(
    //             url: Uri.parse(widget.hitTestResult.extra!),
    //             maxWidth: 50.0,
    //             height: 50.0),
    //       )
    //     ],
    //   ),
    //   title: Text(widget.webViewModel.title ?? "",style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
    // );
  }

  String _decodeUrlIfNeeded(String url) {
    try {
      // Check if the URL is encoded
      Uri.parse(url);
      // If the URL can be parsed, it's not encoded
      return url;
    } catch (e) {
      // If parsing fails, assume it's an encoded URL and decode it
      return base64Decode(url).toString(); //utf8.decode(base64Url.decode(url));
    }
  }

  Widget _buildDownloadImage(BoxConstraints constraints) {
    final downloadProvider =
        Provider.of<DownloadProvider>(context, listen: false);
    return SizedBox(
      //height: 40,
      child: ListTile(
        title: const TextWidget(
          text: "Download image",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        onTap: () async {
          String? url = widget.hitTestResult.extra;
          if (url != null) {
            var uri = Uri.parse(widget.hitTestResult.extra!);
            String path = uri.path;
            String fileName = path.substring(path.lastIndexOf('/') + 1);
            Directory? directory = await getExternalStorageDirectory();
            String _dir = "";
            if (directory!.path.contains("/storage/emulated/0/") &&
                Util.isAndroid()) {
              _dir = '/storage/emulated/0/Download';
            } else {
              _dir = directory.path;
            }
            try {

                 final response = await http.head(Uri.parse(url));
    final contentType = response.headers['content-type'];
    print('content type is ----> $contentType');
    //return contentType;
    String imageName = 'IMG_B${DateTime.now().microsecondsSinceEpoch}';
       if(contentType == 'image/gif'){
           imageName += '.gif';
       }else if(contentType == 'image/jpeg'){
        imageName += '.jpg';
       }else if(contentType == 'image/png'){
        imageName += '.png';
       }else if(contentType == 'image/webp'){
        imageName += '.webp';
       }else if(contentType == 'image/svg'){
        imageName += '.svg';
       }else{
        imageName +='.jpg';
       }
              bool? downloadConfirmed =
                  await _showDownloadConfirmationDialog(context, url);
              if (downloadConfirmed == true) {
                downloadProvider.addTask(url.toString(), _dir, imageName
                    //'IMG_B${DateTime.now().microsecondsSinceEpoch}.jpg'
                    );
              }
            } catch (e) {
              print("$e");
            }

            print('url from the image $url');

            // await FlutterDownloader.enqueue(
            //   url: url,
            //   fileName: "fileNames.jpg",
            //   savedDir: _dir,
            //   showNotification: true,
            //   openFileFromNotification: true,
            // );
          }
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildShareImage(BoxConstraints constraints) {
    // bool _isSharing = false;
    return SizedBox(
      //height: 40,
      child: ListTile(
        title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: "Share image",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
              Icon(
                Icons.share,
                // color: Colors.black54,
                size: 20.0,
              )
            ]),
        onTap: () async {
          if (!_isShare && widget.hitTestResult.extra != null) {
            _isShare = true;
            try {
              //Share.share(widget.hitTestResult.extra!);
              await _shareImageFromUrl(widget.hitTestResult.extra!);
            } finally {
              // _isShare = false;
            }
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<String> getImagePath(String url) async {
    try {
      if (url.contains(';base64,')) {
        // Extract content type and image data from the data URI
        final contentTypeEndIndex = url.indexOf(';base64,');
        final contentType = url.substring(5, contentTypeEndIndex);
        final imageDataStartIndex = contentTypeEndIndex + 8;
        final imageData = url.substring(imageDataStartIndex);
        final bytes = base64.decode(imageData);
        var fileType = '.jpg';
        if (contentType == 'image/gif') {
          fileType += '.gif';
        } else if (contentType == 'image/jpeg') {
          fileType += '.jpg';
        } else if (contentType == 'image/png') {
          fileType += '.png';
        } else if (contentType == 'image/webp') {
          fileType += '.webp';
        } else if (contentType == 'image/svg') {
          fileType += '.svg';
        } else {
          fileType += '.jpg';
        }
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempFilePath =
            '${tempDir.path}/shared_img${DateTime.now().microsecondsSinceEpoch}$fileType';
        return tempFilePath;
      } else {
        // Download the image
        var response = await http.get(Uri.parse(url));
        List<int> bytes = response.bodyBytes;
        final contentType = response.headers['content-type'];
        // Get temporary directory
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        // Save the image to temporary directory
        String fileName = url.split('/').last;
        if (contentType == 'image/gif') {
          fileName += '.gif';
        } else if (contentType == 'image/jpeg') {
          fileName += '.jpg';
        } else if (contentType == 'image/png') {
          fileName += '.png';
        } else if (contentType == 'image/webp') {
          fileName += '.webp';
        } else if (contentType == 'image/svg') {
          fileName += '.svg';
        } else {
          fileName += '.jpg';
        }
        String filePath = '$tempPath/$fileName';
        return filePath;
      }
    } catch (e) {
      print('Error catched $e');
      return url;
    }
  }

  Future<void> _shareImageFromUrl(String imageUrl) async {
    if (imageUrl.contains(';base64,')) {
      try {
        // Extract content type and image data from the data URI
        final contentTypeEndIndex = imageUrl.indexOf(';base64,');
        final contentType = imageUrl.substring(5, contentTypeEndIndex);
        final imageDataStartIndex = contentTypeEndIndex + 8;
        final imageData = imageUrl.substring(imageDataStartIndex);
        final bytes = base64.decode(imageData);
        var fileType = '.jpg';
        if (contentType == 'image/gif') {
          fileType += '.gif';
        } else if (contentType == 'image/jpeg') {
          fileType += '.jpg';
        } else if (contentType == 'image/png') {
          fileType += '.png';
        } else if (contentType == 'image/webp') {
          fileType += '.webp';
        } else if (contentType == 'image/svg') {
          fileType += '.svg';
        } else {
          fileType += '.jpg';
        }
        // Get temporary directory
        final tempFilePath = await getImagePath(
            imageUrl); //'${tempDir.path}/shared_img${DateTime.now().microsecondsSinceEpoch}$fileType';

        // Write image data to a temporary file
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(bytes);

        // Share the temporary file
        await SharePlus.instance.share(ShareParams(files: [XFile(tempFilePath)],text: 'Shared Image')); //.shareFiles([tempFilePath], text: 'Shared Image');

  //       final file = XFile(tempFilePath);
  // await Share.shareXFiles(
  //   [file],
  //   text: 'Shared Image',
  // );
      } catch (e) {
        print('Error sharing image: $e');
        // Handle error sharing image
      }
    } else {
      try {
        // Download the image
        var response = await http.get(Uri.parse(imageUrl));
        List<int> bytes = response.bodyBytes;
        final contentType = response.headers['content-type'];
        // Get temporary directory
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        // Save the image to temporary directory
        String fileName = imageUrl.split('/').last;
        if (contentType == 'image/gif') {
          fileName += '.gif';
        } else if (contentType == 'image/jpeg') {
          fileName += '.jpg';
        } else if (contentType == 'image/png') {
          fileName += '.png';
        } else if (contentType == 'image/webp') {
          fileName += '.webp';
        } else if (contentType == 'image/svg') {
          fileName += '.svg';
        } else {
          fileName += '.jpg';
        }
        String filePath = await getImagePath(imageUrl); //'$tempPath/$fileName';
        await File(filePath).writeAsBytes(bytes);

        // Share the image
        await Share.shareXFiles([XFile(filePath)], text: 'Shared Image');
      } catch (e) {
        await Share.share(imageUrl, subject: "image url");
        print('Error sharing image: $e');
        // Handle error sharing image
      }
    }
  }

  Widget _buildOpenImageNewTab(BoxConstraints constraints) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);

    return SizedBox(
      // height: 40,
      child: ListTile(
        title:const TextWidget(
          text: "Open image in new tab",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        onTap: () {
          browserModel.addTab(WebViewTab(
            key: GlobalKey(),
            webViewModel: WebViewModel(
                url: WebUri(widget.hitTestResult.extra ?? "about:blank")),
          ));
          Navigator.pop(context);
        },
      ),
    );
  }

Widget _buildSearchImageOnGoogle(BoxConstraints constraints) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
     var settings = browserModel.getSettings();
    return SizedBox(
      // height: 40,
      child: ListTile(
        title: Text(
          "Search image with ${settings.searchEngine.name == 'Bing' ? 'Microsoft Bing' : 'Google Lens'}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        onTap: () {
          print('OPEN IMAGE SEARCH ____ ${widget.hitTestResult.extra}');
          if (widget.hitTestResult.extra != null) {
            var url =
                "https://lens.google.com/uploadbyurl?url=${widget.hitTestResult.extra!}";

            if(settings.searchEngine.name == 'Bing'){
           url = "https://www.bing.com/images/search?view=detailv2&iss=sbi&FORM=SBIIDP&q=imgurl:${widget.hitTestResult.extra!}";
             }
            browserModel.addTab(WebViewTab(
              key: GlobalKey(),
              webViewModel: WebViewModel(url: WebUri(url)),
            ));
          }
          Navigator.pop(context);
        },
      ),
    );
  }



  // Widget _buildSearchImageOnGoogle(BoxConstraints constraints) {
  //   var browserModel = Provider.of<BrowserModel>(context, listen: false);

  //   return SizedBox(
  //     // height: 40,
  //     child: ListTile(
  //       title: const TextWidget(
  //         text: "Search image on Google",
  //         style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
  //       ),
  //       onTap: () {
  //         if (widget.hitTestResult.extra != null) {
  //           var url =
  //               "http://images.google.com/searchbyimage?image_url=${widget.hitTestResult.extra!}";
  //           browserModel.addTab(WebViewTab(
  //             key: GlobalKey(),
  //             webViewModel: WebViewModel(url: WebUri(url)),
  //           ));
  //         }
  //         Navigator.pop(context);
  //       },
  //     ),
  //   );
  // }

  Future<bool?> _showDownloadConfirmationDialog(
    BuildContext context,
    url,
  ) {
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            // height: 200,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ? Color(0xff282836)
                    : Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const TextWidget(
                    text: 'Download',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const TextWidget(
                  text: 'You are about to download image. \n Are you sure?',
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                        ),
                        child: MaterialButton(
                          elevation: 0,
                          color: themeProvider.darkTheme
                              ?const Color(0xff42425F)
                              :const Color(0xffF3F3F3),
                          disabledColor:const Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child: const TextWidget(
                              text: 'Cancel', style: TextStyle(fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MaterialButton(
                          color:const Color(0xff00B134),
                          disabledColor:const Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child: const TextWidget(
                              text: 'Download',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
