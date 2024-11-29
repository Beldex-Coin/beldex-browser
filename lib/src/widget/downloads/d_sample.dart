import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overlay Entry Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show overlay
            showOverlay(context);
          },
          child: Text('Show Overlay'),
        ),
      ),
    );
  }

  void showOverlay(BuildContext context) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.grey.withOpacity(0.5),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Remove overlay
                  overlayEntry!.remove();
                },
                child: Text('Close Overlay'),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Intercept back button press to remove overlay
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => WillPopScope(
          onWillPop: () async {
            overlayEntry!.remove();
            return false;
          },
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}
























// import 'package:beldex_browser/src/utils/show_message.dart';
// import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
// import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
// import 'package:beldex_browser/src/widget/downloads/download_task_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:square_percent_indicater/square_percent_indicater.dart';
// import 'package:square_progress_indicator/square_progress_indicator.dart';

// class DownloadUI extends StatefulWidget {
//   @override
//   State<DownloadUI> createState() => _DownloadUIState();
// }

// class _DownloadUIState extends State<DownloadUI> {
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<DarkThemeProvider>(context);
//     final downloadProvider = Provider.of<DownloadProvider>(context);
//     return Scaffold(
//       appBar:  normalAppBar(context, 'Downloads', themeProvider),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: downloadProvider.tasks.length == 0 
//         ? const Center(
//               child: Text('No recent downloads')
//             )
        
//         : SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                   children: [
//                     Expanded(
//                       flex: 4,
//                       child: GestureDetector(
//                         onTap: () {
//                           downloadProvider.clearDownloads();
//                         },
//                         child: Container(
//                           height: 45,
//                           decoration: BoxDecoration(
//                               color: themeProvider.darkTheme
//                                   ? Color(0xff39394B)
//                                   : Color(0xffF3F3F3),
//                               border: Border.all(color: Color(0xffFF3D00)),
//                               borderRadius: BorderRadius.circular(15)),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/images/delete.svg',
//                                 height: 15,
//                                 width: 15,
//                                 color: themeProvider.darkTheme
//                                     ? Color(0xffFFFFFF)
//                                     : Color(0xff222222),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 8.0),
//                                 child: Text(
//                                   'Clear Downloads',
//                                   style: TextStyle(
//                                       fontSize: 11, fontWeight: FontWeight.w400),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(flex: 5, child: SizedBox())
//                   ],
//                 ),
//               // ListView for downloading or failed files
//              downloadProvider.getDownloadingAndFailedCount() == 0 ?  Container() : Padding(
//                 padding: const EdgeInsets.symmetric(vertical:10.0),
//                 child: Row(
//                   children: [
//                     Text('Downloading '),
//                   downloadProvider.getDownloadingCount() == 0 ? SizedBox.shrink() : Container(
//                       height: 20,width: 20,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Color(0xff00B134)
//                       ),
//                       child: Center(child: Text(downloadProvider.getDownloadingCount().toString(),style: TextStyle(fontSize:12,color: Colors.white),)),
//                     )
//                   ],
//                 ),
//               ),
//             downloadProvider.getDownloadingAndFailedCount() == 0 ?  Container() : Container(
//                 padding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
//                  decoration: BoxDecoration(
//                         color: themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
//                                  borderRadius: BorderRadius.circular(10)
//                  ),
//                 child: Consumer<DownloadProvider>(
//                   builder: (context, downloadProvider, _) {
//                     List<DownloadTasks> downloadingOrFailedTasks = downloadProvider.tasks
//                         .where((task) =>
//                             task.status == DownloadTaskStatus.running.index ||
//                             task.status == DownloadTaskStatus.failed.index)
//                         .toList();
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: downloadingOrFailedTasks.length,
//                       itemBuilder: (context, index) {
//                         DownloadTasks task = downloadingOrFailedTasks[index];
//                         print('call this function for task ${task.progress}');
//                   // double progressInMB = downloadProvider.bytesToMegabytes(task.progress);
//                   // double totalSizeInMB = downloadProvider.bytesToMegabytes(task.totalSize);
//                   // String progressText = '${progressInMB.toStringAsFixed(2)} MB / ${totalSizeInMB.toStringAsFixed(2)} MB';
//                         return Column(
//                           children: [
//                             Container(
//                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
//                                  borderRadius: BorderRadius.circular(10)
//                               ),
//                               child: Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: (){
//                                       //downloadProvider.pauseTask(task.taskId);// pauseTask(task.taskId);
//                                       //   switch (task.status) {
//                                       //   case 0: 
//                                       //   print('undefined');
//                                       //     break;
//                                       //   case 1:
//                                       //   print('enqueued');
//                                       //      break;
//                                       //   case 2:
//                                       //    print('running');
//                                       //    downloadProvider.pauseTask(task.taskId);
//                                       //      break;
                                        
//                                       //   case 3:
//                                       //     print('complete');
//                                       //     break;
//                                       //   case 4:
//                                       //       print('failed ${task.taskId}');
//                                       //       downloadProvider.retryTask(task.taskId);
//                                       //       break;
//                                       //   case 5:
//                                       //       print('canceled');
//                                       //       break;
//                                       //   case 6:
//                                       //   print('paused');
//                                       //       downloadProvider.resumeTask(task.taskId);
//                                       //       break;
//                                       //  default:
//                                       //       print('Invalid value: ${task.status}');
//                                       //   }
//                                     },
//                                     child: Container(
//                                     height:30,width: 30,
                                    
//                                     decoration: BoxDecoration(
//                                      color:themeProvider.darkTheme ? Color(0xff404054) : Color(0xffffffff),
//                                      borderRadius: BorderRadius.circular(5)
//                                     ),
//                                     child: SquareProgressIndicator(
//                                       value:downloadProvider.convertToDoubleProgress(task.progress),
//                                       borderRadius: 5,
//                                       color:task.status == DownloadTaskStatus.failed.index ? Colors.transparent  : Color(0xff00B134),
//                                       strokeWidth: 1,
//                                       child: Container(
//                                          child:
//                                          task.status == DownloadTaskStatus.failed.index ?  SvgPicture.asset('assets/images/failed.svg'): Text('${task.progress}%',style: TextStyle(color:Color(0xff00B134),fontSize: 11),),
//                                         //color: Colors.pink,
//                                       ),
//                                     ),
//                                  ),
//                                   ),
//                                 SizedBox(width: 15,),
//                                 Expanded(
                            
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.baseline,
//                                     textBaseline: TextBaseline.alphabetic,
//                                     children: [
//                                       Text(task.name,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800),overflow: TextOverflow.ellipsis,maxLines: 1,),
//                                       Text(task.status == DownloadTaskStatus.failed.index ? 'Download Failed!' : 
//                                        task.status == DownloadTaskStatus.paused.index ?
//                                        'Download paused' :
//                                        ' Downloading...',style: TextStyle(color: task.status == DownloadTaskStatus.failed.index ? Color(0xffFF3D00) : Color(0xff00B134),fontSize: 13),),
//                                     ],
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {
//                                     downloadProvider.cancelTask(task.taskId);
//                                     downloadProvider.removeTask(task.taskId) ;
//                                   },
//                                   child: Container(
//                                     height: 50,width: 50,
//                                     child: Icon(Icons.close,size: 20,color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81),),
//                                   ),
//                                 )
//                                 ],
//                               )
                              
//                             ),
//                             index < downloadingOrFailedTasks.length - 1 ? Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Divider(
//                                 height: 1,
//                                 color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
//                                ),
//                              ): Container()
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               // ListView for completed files
//              downloadProvider.getCompletedCount() == 0 ? Container() :  Padding(
//                 padding: const EdgeInsets.symmetric(vertical:10.0),
//                 child: Text('Completed',style: TextStyle(color: Color(0xff0BA70F),fontSize:14),),
//               ),
//               downloadProvider.getCompletedCount() == 0 ?
//                Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           height: 100,
//                         ),
//                         SvgPicture.asset('assets/images/no_downloads.svg',color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffDADADA)),
//                          Center(child: Padding(
//                            padding: const EdgeInsets.symmetric(vertical: 8.0),
//                            child: Text('No completed downloads',style: TextStyle(color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffDADADA),fontSize: 15),),
//                          ))
//                       ],
//                      )
//               :Container(
//                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
//                  decoration: BoxDecoration(
//                         color: themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
//                                  borderRadius: BorderRadius.circular(10)
//                  ),
//                 child: Consumer<DownloadProvider>(
//                   builder: (context, downloadProvider, _) {
//                     List<DownloadTasks> completedTasks = downloadProvider.tasks
//                         .where((task) => task.status == DownloadTaskStatus.complete.index)
//                         .toList();
//                     return 
//                      ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: completedTasks.length,
//                       itemBuilder: (context, index) {
//                        DownloadTasks task = completedTasks[index];
//                         return Column(
//                           children: [
//                             Container(
//                                  padding: EdgeInsets.only(right: 8,top: 3,bottom: 3),
//                               decoration: BoxDecoration(
//                                 color: themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
//                                  borderRadius: BorderRadius.circular(10)
//                               ),
//                               child: Row(
//                                 children: [
//                                 SizedBox(width: 15,),
//                                 Expanded(
                                                            
//                                   child: GestureDetector(
//                                     onTap: ()async {
//                                            final success = await downloadProvider.openDownloadedFile(task.taskId);
//                 if (!success) {
//                   showMessage('Cannot open this file');
//                   // ScaffoldMessenger.of(context).showSnackBar(
//                   //   const SnackBar(
//                   //     content: Text('Cannot open this file'),
//                   //   ),
//                   // );
//                 }
//                                     },
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.baseline,
//                                       textBaseline: TextBaseline.alphabetic,
//                                       children: [
//                                         Text('${task.name}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800),overflow: TextOverflow.ellipsis,maxLines: 1,),
//                                         Row(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(right:8.0),
//                                               child: Text('${(task.totalSize / (1024 * 1024)).toStringAsFixed(2)} MB', style: TextStyle(fontSize: 13),),
//                                             ),
//                                             Expanded(child: Text('${task.url}',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 13,color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81))))
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () => downloadProvider.removeTask(task.taskId) ,
//                                   child: Container(
//                                     height: 50,width: 50,
//                                     child: Icon(Icons.close,size: 20,color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81)),
//                                   ),
//                                 )
//                                 ],
//                               )
//                             ),
//                             index < completedTasks.length - 1 ? Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Divider(
//                                 height: 1,
//                                 color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
//                                ),
//                              ): Container()
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   AppBar normalAppBar(
//     BuildContext context, String title, DarkThemeProvider themeProvider) {
//   return AppBar(
//     centerTitle: true,
//     leading: IconButton(
//         onPressed: () => Navigator.pop(context),
//         icon: SvgPicture.asset(
//           'assets/images/back.svg',
//           color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
//           height: 30,
//         )),
//     title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
//   );
// }
// }


// // import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
// // import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
// // import 'package:beldex_browser/src/widget/downloads/download_task_model.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_downloader/flutter_downloader.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:provider/provider.dart';

// // class DownloadUI extends StatelessWidget {
// //   const DownloadUI({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final themeProvider = Provider.of<DarkThemeProvider>(context);
// //     return Scaffold(
// //         appBar:normalAppBar(context,'Downloads',themeProvider),

// //         body: Padding(
          
// //           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.start,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children:[
// //                Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 4,
// //                     child: Container(
// //                       height: 45,
// //                       decoration: BoxDecoration(
// //                           color: themeProvider.darkTheme
// //                               ? Color(0xff39394B)
// //                               : Color(0xffF3F3F3),
// //                           border: Border.all(color: Color(0xffFF3D00)),
// //                           borderRadius: BorderRadius.circular(15)),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           SvgPicture.asset(
// //                             'assets/images/delete.svg',
// //                             height: 15,
// //                             width: 15,
// //                             color: themeProvider.darkTheme
// //                                 ? Color(0xffFFFFFF)
// //                                 : Color(0xff222222),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(left: 8.0),
// //                             child: Text(
// //                               'Clear Downloads',
// //                               style: TextStyle(
// //                                   fontSize: 11, fontWeight: FontWeight.w400),
// //                             ),
// //                           )
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   Expanded(flex: 5, child: SizedBox())
// //                 ],
// //               ),
// //               Text('Downloading '),
// //               Container(
// //                  margin: EdgeInsets.symmetric(vertical: 15),
// //                 decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(15.0),
// //                     color: themeProvider.darkTheme
// //                         ? Color(0xff292937)
// //                         : Color(0xffF3F3F3)),
// //                 padding:
// //                     EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),

// //               child:Consumer<DownloadProvider>(
// //                 builder: (context, downloadProvider, child) {
// //                   List<DownloadTasks> downloadingorFailedTasks = downloadProvider.tasks.where((task)=>
// //                    task.status ==  DownloadTaskStatus.running.index || 
// //                    task.status == DownloadTaskStatus.failed.index
// //                   ).toList();


// //                 return ListView.builder(
// //                   shrinkWrap: true,
// //                   padding: EdgeInsets.zero,
// //                   itemCount: downloadingorFailedTasks.length,
// //                   itemBuilder: ((context, index) {
// //                     DownloadTasks task = downloadingorFailedTasks[index];
// //                     return Column(
// //                       children: [
// //                         Row(
// //                             children: [
// //                               Expanded(
// //                                 flex: 5,
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     SizedBox(
// //                                       width: MediaQuery.of(context).size.width * 0.7,
// //                                       child: Text(
// //                                         task.name,
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.bold,
// //                                           // color: data.status == 'Failed'
// //                                           //         ? Colors.grey
// //                                           //         : Colors.white
// //                                         ),
// //                                         overflow: TextOverflow.ellipsis,
// //                                         maxLines: 1,
// //                                       ),
// //                                     ),
// //                                     Row(
// //                                       children: [
// //                                         // SizedBox(
// //                                         //   width:
// //                                         //       MediaQuery.of(context).size.width * 0.2,
// //                                         //   child: Text(
// //                                         //     '${(data.fileSize / 1000000).toStringAsFixed(2)} MB',
// //                                         //     style: TextStyle(
// //                                         //         // color: data.status == 'Failed'
// //                                         //         //       ? Colors.grey
// //                                         //         //       : Colors.white
// //                                         //         ),
// //                                         //   ),
// //                                         // ),
// //                                         Expanded(
// //                                           child: SizedBox(
// //                                             // width:
// //                                             //     MediaQuery.of(context).size.width * 0.5,
// //                                             child: Text(
// //                                               '${task.progress}',
// //                                               // data.status == null ||
// //                                               //         data.status == 'Downloading'
// //                                               //     ? 'Downloading'
// //                                               //     : data.status == 'Failed'
// //                                               //         ? 'Failed'
// //                                               //         : data.url,
// //                                               overflow: TextOverflow.ellipsis,
// //                                               maxLines: 1,
// //                                               softWrap: true,
// //                                               style: TextStyle(
// //                                                   color:
// //                                                   //  data.status == 'Failed'
// //                                                   //       ? Colors.grey
// //                                                   //       :
// //                                                          themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81)
// //                                                   ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     )
// //                                   ],
// //                                 ),
// //                               ),
// //                               SizedBox(
// //                                   width: 40,
// //                                   child: IconButton(
// //                                       onPressed: () {
// //                                         // setState(() {
// //                                         //   _downloadCon.downloadList.removeAt(index);
// //                                         //   List downloadJsonList = _downloadCon
// //                                         //       .downloadList
// //                                         //       .map((item) => item.toJson())
// //                                         //       .toList();
// //                                         //   write('downloadList', downloadJsonList);
// //                                         // });
// //                                       },
// //                                       icon: Icon(
// //                                         Icons.close,
// //                                         color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5),
// //                                         size: 20,
// //                                       )))
// //                             ],
// //                           ),
// //                       ],
// //                     );
// //                   })
// //                   );
// //               },) ,
// //               ),
// //               Text('Completed'),
// //                 Container(
// //                  margin: EdgeInsets.symmetric(vertical: 15),
// //                 decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(15.0),
// //                     color: themeProvider.darkTheme
// //                         ? Color(0xff292937)
// //                         : Color(0xffF3F3F3)),
// //                 padding:
// //                     EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),

// //               child:Consumer<DownloadProvider>(
// //                 builder: (context, downloadProvider, child) {
// //                   List<DownloadTasks> completedTasks = downloadProvider.tasks.where((task)=>task.status == DownloadTaskStatus.complete.index).toList();
// //                 return ListView.builder(
// //                   shrinkWrap: true,
// //                   padding: EdgeInsets.zero,
// //                   itemCount: completedTasks.length,
// //                   itemBuilder: ((context, index) {
// //                     DownloadTasks task = completedTasks[index];
// //                     return Column(
// //                       children: [
// //                         Row(
// //                             children: [
// //                               Expanded(
// //                                 flex: 5,
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     SizedBox(
// //                                       width: MediaQuery.of(context).size.width * 0.7,
// //                                       child: Text(
// //                                         task.name,
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.bold,
// //                                           // color: data.status == 'Failed'
// //                                           //         ? Colors.grey
// //                                           //         : Colors.white
// //                                         ),
// //                                         overflow: TextOverflow.ellipsis,
// //                                         maxLines: 1,
// //                                       ),
// //                                     ),
// //                                     Row(
// //                                       children: [
// //                                         // SizedBox(
// //                                         //   width:
// //                                         //       MediaQuery.of(context).size.width * 0.2,
// //                                         //   child: Text(
// //                                         //     '${(data.fileSize / 1000000).toStringAsFixed(2)} MB',
// //                                         //     style: TextStyle(
// //                                         //         // color: data.status == 'Failed'
// //                                         //         //       ? Colors.grey
// //                                         //         //       : Colors.white
// //                                         //         ),
// //                                         //   ),
// //                                         // ),
// //                                         Expanded(
// //                                           child: SizedBox(
// //                                             // width:
// //                                             //     MediaQuery.of(context).size.width * 0.5,
// //                                             child: Text(
// //                                               '${task.progress}',
// //                                               // data.status == null ||
// //                                               //         data.status == 'Downloading'
// //                                               //     ? 'Downloading'
// //                                               //     : data.status == 'Failed'
// //                                               //         ? 'Failed'
// //                                               //         : data.url,
// //                                               overflow: TextOverflow.ellipsis,
// //                                               maxLines: 1,
// //                                               softWrap: true,
// //                                               style: TextStyle(
// //                                                   color:
// //                                                   //  data.status == 'Failed'
// //                                                   //       ? Colors.grey
// //                                                   //       :
// //                                                          themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81)
// //                                                   ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     )
// //                                   ],
// //                                 ),
// //                               ),
// //                               SizedBox(
// //                                   width: 40,
// //                                   child: IconButton(
// //                                       onPressed: () {
// //                                         // setState(() {
// //                                         //   _downloadCon.downloadList.removeAt(index);
// //                                         //   List downloadJsonList = _downloadCon
// //                                         //       .downloadList
// //                                         //       .map((item) => item.toJson())
// //                                         //       .toList();
// //                                         //   write('downloadList', downloadJsonList);
// //                                         // });
// //                                       },
// //                                       icon: Icon(
// //                                         Icons.close,
// //                                         color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5),
// //                                         size: 20,
// //                                       )))
// //                             ],
// //                           ),
// //                       ],
// //                     );
// //                   })
// //                   );
// //               },) ,
// //               ),



// //               ]
// //             ),
// //           ),
          
// //           )
        
        
// //         // Consumer<DownloadProvider>(builder: (BuildContext context, DownloadProvider downloadProvider, Widget? child) { 
// //         //   print('provider is empty ${downloadProvider.tasks.length}');
// //         //   return ListView.builder(
// //         //     itemCount: downloadProvider.tasks.length,
// //         //     itemBuilder:((context, index) {
// //         //       DownloadTasks task = downloadProvider.tasks[index];
// //         //       return Container(
// //         //         height: 60,
// //         //         width: double.infinity,
// //         //         child: Column(
// //         //           children: [
// //         //            Text(task.taskId,maxLines: 1,overflow: TextOverflow.ellipsis,),
// //         //            Text('Status : ${task.status} ,Progress: ${task.progress}',maxLines: 1,overflow: TextOverflow.ellipsis,),
// //         //           ],
// //         //         ),
// //         //       );
// //         //       // ListTile(
// //         //       //     title: Text(task.taskId),
// //         //       //     subtitle: Text('Status : ${task.status} ,Progress: ${task.progress}'),
// //         //       //     trailing: Row(
// //         //       //       children: [
// //         //       //        IconButton(
// //         //       //         icon: Icon(Icons.pause),
// //         //       //         onPressed: () => downloadProvider.pauseTask(task.taskId),
// //         //       //       ),
// //         //       //       IconButton(
// //         //       //         icon: Icon(Icons.play_arrow),
// //         //       //         onPressed: () => downloadProvider.resumeTask(task.taskId),
// //         //       //       ),
// //         //       //       IconButton(
// //         //       //         icon: Icon(Icons.refresh),
// //         //       //         onPressed: () => downloadProvider.retryTask(task.taskId),
// //         //       //       ),
// //         //       //       IconButton(
// //         //       //         icon: Icon(Icons.cancel),
// //         //       //         onPressed: () => downloadProvider.cancelTask(task.taskId),
// //         //       //       ),
// //         //       //       ],
// //         //       //     ),
// //         //       // );
// //         //     }) );
// //         //  }, 
          
// //         // )
// //     );
// //   }
// //   AppBar normalAppBar(
// //     BuildContext context, String title, DarkThemeProvider themeProvider) {
// //   return AppBar(
// //     centerTitle: true,
// //     leading: IconButton(
// //         onPressed: () => Navigator.pop(context),
// //         icon: SvgPicture.asset(
// //           'assets/images/back.svg',
// //           color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
// //           height: 30,
// //         )),
// //     title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
// //   );
// // }
// // }