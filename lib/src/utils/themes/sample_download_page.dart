// import 'package:beldex_browser/src/utils/themes/downloads_controller.dart';
// import 'package:flutter/material.dart';
// //import 'package:get/get.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

// class SampleDownloadsPage extends StatelessWidget {
//   final DownloadsListController _downloadController = Get.put(DownloadsListController());


// loadAllTasks()async{
//   List<DownloadTask>? task = await FlutterDownloader.loadTasks();
//    var data = task![0].progress;
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:const Text('Download Manager'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Obx(
//             () => Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Downloading:'),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: _downloadController.downloadingList.length,
//                   itemBuilder: (context, index) {
//                     String taskId = _downloadController.downloadingList[index];
//                     return ListTile(
//                       title: Text(taskId),
//                       // subtitle: Obx(() {
                         
//                       //   // DownloadTask task = FlutterDownloader.loadTasks();
//                       //   if (task != null) {
//                       //     return Text('${task.progress.toString()} B / ${task.total.toString()} B');
//                       //   } else {
//                       //     return Text('0 B / 0 B');
//                       //   }
//                       // }),
//                       trailing: IconButton( 
//                         icon: Icon(Icons.pause),
//                         onPressed: () {
//                          // _downloadController.pauseDownload(taskId);
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Obx(
//             () => Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                const Text('Completed:'),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: _downloadController.completedList.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(_downloadController.completedList[index]),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
