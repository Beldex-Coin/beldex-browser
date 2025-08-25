

// import 'dart:developer';
// import 'dart:io';

// import 'package:beldex_browser/src/model/download_model.dart';
// import 'package:beldex_browser/src/utils/read_write.dart';
// import 'package:beldex_browser/src/utils/show_message.dart';
// import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
// import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// //import 'package:flutter_file_downloader/flutter_file_downloader.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';

// class DownloadController extends GetxController{

//  InAppWebViewController? webViewController;
//   PullToRefreshController? pullToRefreshController;
//   final TextEditingController urlCon = TextEditingController();
//   List bookmarks = [];
//   RxBool isLoading = false.obs;
//   RxString selected = "".obs;
//   RxBool hideBottomSheet = false.obs;
//   RxList history = [].obs;
//   RxList downloadList = [].obs;

//   RxList downloadingList = [].obs;
//   RxList downloadedList = [].obs;

//   dynamic taskId = "".obs;

//  fileDownloadPermission(url,dir,name) {
//     return Get.dialog(
     
//                    DialogBox(url: url,dir:dir,name:name)  


//       // Dialog(
//       //   content: Container(
//       //      height: 100,
//       //      width:double.infinity,
//       //     child: Text(
//       //       'You are about to download ${url.suggestedFilename}. \n Are you sure?',
//       //       textAlign: TextAlign.center
//       //     ),
//       //   ),
//       //   contentPadding: const EdgeInsets.only(top: 8.0),
//       //   actionsAlignment: MainAxisAlignment.center,
//       //   actions: [
//       //     ElevatedButton(
//       //       style: ElevatedButton.styleFrom(
//       //         backgroundColor: Colors.grey
//       //       ),
//       //       onPressed: () => Get.back(),
//       //       child: const Text('Cancel')
//       //     ),
//       //     ElevatedButton(
//       //       style: ElevatedButton.styleFrom(
//       //         backgroundColor: Colors.red
//       //       ),
//       //       onPressed: () {
//       //         Get.back();
//       //         downloadFile(url);
//       //       }, 
//       //       child: const Text('Download')
//       //     )
//       //   ],
//       // ),
//     );
//   }


//  //         showDialog(
//       //         context: context,
//       //         builder: (context) {
//       //           return Dialog(
//       //             backgroundColor:
//       //             themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
//       //         insetPadding: EdgeInsets.all(15),
//       //             child: Container(
//       //                 width: MediaQuery.of(context).size.width,
//       //          // height: 200,
//       //           padding: EdgeInsets.all(20),
//       //           decoration:
//       //               BoxDecoration(borderRadius: BorderRadius.circular(20)),
//       //               child: Column(
//       //                 mainAxisSize: MainAxisSize.min,
//       //                 crossAxisAlignment: CrossAxisAlignment.start,
//       //                 children: <Widget>[
//       //                   Padding(
//       //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//       //                     child: Text('Home Page',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//       //                   ),
//       //                   StatefulBuilder(builder: (context, setState) {
//       //                     return Row(
//       //                        // mainAxisAlignment: MainAxisAlignment.end,
//       //                         children: <Widget>[
//       //                           ]);
                         
//       //                   }),
       
//       //                   Padding(
//       //                     padding: const EdgeInsets.symmetric(vertical:8.0),
//       //                     child: MaterialButton(
//       //                       color: Color(0xff00B134),
//       //                     disabledColor: Color(0xff2C2C3B),
//       //                      minWidth: double.maxFinite,
//       //                     height: 55,
//       //                     child: Text('OK',style: TextStyle(color: Colors.white,fontSize:18)),
//       //                     shape: RoundedRectangleBorder(
//       //                       borderRadius: BorderRadius.circular(
//       //                           10.0), // Adjust the radius as needed
//       //                     ),
//       //                       onPressed: (){
                               
//       //                     },
                          
//       //                     ),
//       //                   )
//       //                 ],
//       //               ),
//       //             ),
//       //           );
//       //         },
//       //       );










//   downloadFile(url,dir) async {
//     try{
//      await createDownloadLog(url);

//          String? taskIds = await FlutterDownloader.enqueue(
//           url: url.url.toString(),
//           fileName:url.suggestedFilename , //generateUniqueFilename(baseFilename, itemCount, _dir), //fileName,
//           savedDir: dir,
//           showNotification: true,
//           openFileFromNotification: true,
//           saveInPublicStorage: true

//         ).whenComplete((){
//           downloadCompleteShow(url);
//           //itemCount++;
//         });
//        taskId = taskIds;
//         print('Task Id is $taskId');
//     }catch(error){
//       downloadError(error, url);
//     }
    

//     // FileDownloader.downloadFile(
//     //   url: url.url.toString(),
//     //   name: url.suggestedFilename,
//     //   onProgress: (String? fileName, double progress) {
//     //     log('$fileName => $progress%');
//     //   },
//     //   onDownloadCompleted: (String path) {
//     //     downloadCompleteShow(url);
//     //   },
//     //   onDownloadError: (String error) {
//     //     downloadError(error, url);
//     //   }
//     // );
//   }



// String generateUniqueFilename(String baseFilename,int itemCount,String _dir) {
//     String uniqueFilename = baseFilename;

//     while (true) {
//       File file = File('$_dir/$uniqueFilename');
//       if (!file.existsSync()) {
//         break;
//       } else {
//         itemCount++;
//         String extension = baseFilename.split('.').last;
//         String filenameWithoutExtension = baseFilename.substring(0, baseFilename.length - extension.length - 1);
//         uniqueFilename = '$filenameWithoutExtension' + '_$itemCount.$extension';
//       }
//     }

//     return uniqueFilename;
//   }






//    createDownloadLog(url) {
//     showMessage('Start downloading...');
//     var downloadItem = DownloadModel(name: url.suggestedFilename, progress: 0.0, url: url.url.toString(), mimeType: url.mimeType, status: 'Downloading', fileSize: url.contentLength,taskId: taskId);
//     downloadList.add(downloadItem);
//     // var lastIndex = downloadList.lastIndexWhere((element) => element.name == url.suggestedFilename);
//     // downloadList[lastIndex].status = "Downloading";
//     downloadingList.add(downloadItem);
//     List downloadJsonList = downloadList.map((item) => item.toJson()).toList();
//     write('downloadList', downloadJsonList);
//   }

//   downloadCompleteShow(url) async {
//     showMessage('Download Completed.');
   
//     var lastIndex = downloadList.lastIndexWhere((element) => element.name == url.suggestedFilename);
//     downloadList[lastIndex].status = "Completed";
//     downloadingList[lastIndex].status = "Completed";
//     List downloadJsonList = downloadList.map((item) => item.toJson()).toList();
//     write('downloadList', downloadJsonList);
//      for(int i=0;i< downloadingList.length;i++){
//       if(downloadingList[i].status == "Completed" ){
//         downloadedList.add(downloadingList[i]); 
//         downloadingList.removeAt(i);
//          //removeWhere((element) => element.status == 'Completed');
//       }
//     }
//   }

//   downloadError(error, url) {
//     showMessage(error);
//     var lastIndex = downloadList.lastIndexWhere((element) => element.name == url.suggestedFilename);
//     downloadList[lastIndex].status = "Failed";
//     List downloadJsonList = downloadList.map((item) => item.toJson()).toList();
//     write('downloadList', downloadJsonList);
//   }


//   getDownloadList() {
//     try {
//       isLoading(true);
//       var data = read('downloadList');
//       if(data != "") {
//         downloadList.clear();
//         for(var item in data) {
//           downloadList.add(DownloadModel.fromJson(item));
//         }
//       }
//     } catch (e) {
//       log(e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }


// }


// class DialogBox extends StatelessWidget {
//   final dynamic url;
//   final String dir;
//   final String name;
//   const DialogBox({super.key, required this.url, required this.dir, required this.name});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<DarkThemeProvider>(context);
//     //final taskProvider = Provider.of<DownloadProvider>(context,listen: false);
//    //  final _downloadCon = Get.put(DownloadController());
//     return  Dialog(
//                    backgroundColor:
//                   themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
//               insetPadding: EdgeInsets.all(10),
//                   child: Container(
//                       width:MediaQuery.of(context).size.width,
//                // height: 200,
//                 padding: EdgeInsets.all(15),
//                 decoration:
//                     BoxDecoration(borderRadius: BorderRadius.circular(20)),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Text('Download',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//                         ),
//                         Text('You are about to download ${url.suggestedFilename}. \n Are you sure?',
//                         textAlign: TextAlign.center,
//                         ),
       
//                         Row(
//                           children: [
//                             Expanded(
//                               flex:1,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical:10.0,),
//                                 child: MaterialButton(
//                                   elevation: 0,
//                                 color:themeProvider.darkTheme ? Color(0xff42425F)  : Color(0xffF3F3F3),
//                                 disabledColor: Color(0xff2C2C3B),
//                                  minWidth: double.maxFinite,
//                                 height: 50,
//                                 child: Text('Cancel',style: TextStyle(color: Colors.white,fontSize:18)),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       10.0), // Adjust the radius as needed
//                                 ),
//                                   onPressed: (){
//                                      Get.back();
//                                 },
                                
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                               flex:1,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical:10.0),
//                                 child: MaterialButton(
//                                   color: Color(0xff00B134),
//                                 disabledColor: Color(0xff2C2C3B),
//                                  minWidth: double.maxFinite,
//                                 height: 50,
//                                 child: Text('Download',style: TextStyle(color: Colors.white,fontSize:18)),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       10.0), // Adjust the radius as needed
//                                 ),
//                                   onPressed: ()async{
//                                              Get.back();
//                                             //  await taskProvider.prepareDownloads();
//                                             //  taskProvider.downloadFile(url, dir);
//                                              //_downloadCon.downloadFile(url,dir); 
//                                             Provider.of<DownloadProvider>(context,listen: false).addTask(url, dir, name);
                                             
//                                 },
                                
//                                 ),
//                               ),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//   }
// }