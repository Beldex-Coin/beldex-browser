
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:beldex_browser/main.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/widget/downloads/download_task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadProvider extends ChangeNotifier {
  List<DownloadTasks> tasks = [];
  ReceivePort _port = ReceivePort();

  DownloadProvider() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback); // using top-level callback
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) async {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      DownloadTasks task = tasks.firstWhere((task) => task.taskId == id, orElse: () => DownloadTasks(taskId: id, url: "", name: "New Task", status: status, progress: 0, totalSize: 0, dir: '', createdDate: DateTime.now()));
      task.progress = progress;
      task.status = status;

      if (status == DownloadTaskStatus.complete.index) {
        print('status is completed');
        File file = File(task.dir + '/' + task.name);
        int fileSize = await file.length();
        task.totalSize = fileSize;
        print('and the file size is $fileSize');
        openSnackbar(task.taskId, task.name);
        notifyListeners();
      }

      tasks.sort((a, b) {
        if (a.status != b.status) {
          return a.status.compareTo(b.status);
        } else {
          return b.taskId.compareTo(a.taskId);
        }
      });

      print('call this function from provider $status ');
      print('call this function for $progress');
      notifyListeners();
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  Future<void> addTask(String url, dir, fileName) async {
    print('whole tasks ----> ${tasks.length}');
    try {
      showMessage('Start downloading');
      String newFileName = fileName;
      int fileNumber = 1;
      String baseName = fileName;
      String extension = '';
      File existingFile = File('$dir/$newFileName');

      while (await existingFile.exists()) {
        int extensionIndex = fileName.lastIndexOf('.');
        if (extensionIndex != -1) {
          baseName = fileName.substring(0, extensionIndex);
          extension = fileName.substring(extensionIndex);
        }
        newFileName = '$baseName($fileNumber)$extension';
        existingFile = File('$dir/$newFileName');
        fileNumber++;
      }

      print('the directory after the image $dir');

      String? taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: newFileName,
        savedDir: dir,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      tasks.add(DownloadTasks(
        taskId: taskId!,
        url: url,
        status: DownloadTaskStatus.undefined.index,
        progress: 0,
        name: newFileName,
        totalSize: 0,
        dir: dir,
        createdDate: DateTime.now(),
      ));
      notifyListeners();
    } catch (e) {
      print('error with provider $e');
    }
  }

  double bytesToMegabytes(int bytes) {
    return bytes / (1024 * 1024);
  }

  double convertToDoubleProgress(int progress) {
    double number = progress / 100;
    if (number < 0) {
      return 0;
    } else if (number > 100) {
      String numberStr = number.toString();
      String firstTwoDigits = numberStr.substring(0, 2);
      return double.parse(firstTwoDigits);
    } else {
      return number;
    }
  }

  Future<String> checkAndDisplayFileSize(String name, String dir) async {
    File file = File(dir + '/' + name);
    int fileSize = await file.length();
    return '$fileSize';
  }

  void retryTask(String taskId) async {
    try {
      await FlutterDownloader.retry(taskId: taskId);
      print('Retry successful');
    } catch (error) {
      print('Error retrying task: $error');
    }
  }

  void pauseTask(String taskId) async {
    try {
      await FlutterDownloader.pause(taskId: taskId);
      print('successfully paused');
    } catch (error) {
      print('Error pausing task: $error');
    }
  }

  void resumeTask(String taskId) async {
    try {
      await FlutterDownloader.resume(taskId: taskId);
      print('successfully resuming');
    } catch (error) {
      print('Error resuming task: $error');
    }
  }

  void cancelTask(String taskId) async {
    try {
      await FlutterDownloader.cancel(taskId: taskId);
      print('cancelled successfully');
    } catch (error) {
      print('Error cancelling task: $error');
    }
  }

  // Future openSnackbar(String taskId, String taskName) async {
  //   scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
  //     content: Text(
  //       'Download complete $taskName',
  //       maxLines: 2,
  //       overflow: TextOverflow.ellipsis,
  //     ),
  //     duration: Duration(seconds: 3),
  //     behavior: SnackBarBehavior.floating,
  //     action: SnackBarAction(
  //       label: 'Open',
  //       onPressed: () => openDownloadedFile(taskId),
  //       textColor: Color(0xff0BA70F),
  //     ),
  //   ));
  // }

  Future<void> openSnackbar(String taskId, String taskName) async {
  if (scaffoldMessengerKey.currentState?.mounted ?? false) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            'Download complete $taskName',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => openDownloadedFile(taskId),
            textColor: Color(0xff0BA70F),
          ),
        ),
      );
    });
  } else {
    debugPrint("ScaffoldMessenger is not ready. Skipping snackbar.");
  }
}


  Future<bool> openDownloadedFile(String taskId) async {
    if (taskId == null) {
      return false;
    }
    return FlutterDownloader.open(taskId: taskId);
  }

  void removeTask(String taskId) {
    tasks.removeWhere((task) => task.taskId == taskId);
    notifyListeners();
  }

  void removeAllTasks() {
    tasks.clear();
    notifyListeners();
  }

  void clearDownloads() {
    tasks.removeWhere((task) =>
        task.status == DownloadTaskStatus.failed.index ||
        task.status == DownloadTaskStatus.complete.index);
    notifyListeners();
  }

  int getDownloadingCount() {
    return tasks.where((task) => task.status == DownloadTaskStatus.running.index).length;
  }

  int getDownloadingAndFailedCount() {
    return tasks.where((task) =>
        task.status == DownloadTaskStatus.running.index ||
        task.status == DownloadTaskStatus.failed.index).length;
  }

  int getCompletedCount() {
    return tasks.where((task) => task.status == DownloadTaskStatus.complete.index).length;
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    print('call this function from provider dispose');
    super.dispose();
  }
}

// import 'dart:io';
// import 'dart:isolate';
// import 'dart:math';
// import 'dart:ui';

// import 'package:beldex_browser/main.dart';
// import 'package:beldex_browser/src/utils/show_message.dart';
// import 'package:beldex_browser/src/widget/downloads/download_task_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class DownloadProvider extends ChangeNotifier{

// List<DownloadTasks> tasks =[];
// ReceivePort _port = ReceivePort();


// DownloadProvider(){
//   _bindBackgroundIsolate();
//   FlutterDownloader.registerCallback(downloadCallback);
// }

// void _bindBackgroundIsolate(){
//   // print('call this function from provider');
//  bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
//  //print('$isSuccess ---> call this function from provider');
//  if (!isSuccess) {
//       _unbindBackgroundIsolate();
//       _bindBackgroundIsolate();
//       return;
//     }
//   _port.listen((dynamic data) async{
//     String id = data[0];
//     int status = data[1];
//     int progress = data[2];
//     DownloadTasks task = tasks.firstWhere((task) => task.taskId == id ,
//     // orElse: () {
//     //   DownloadTasks newTask = DownloadTasks(taskId: id, url: "", name: "New Task", status: status, progress: 0, totalSize: 0, dir: '');
//     //   tasks.add(newTask);
//     //   return newTask;
//     // }
//     );
    
//     task.progress = progress;
//     task.status = status;

//     if(status == DownloadTaskStatus.complete.index){
//       print('status is completed');
//       File file = File(task.dir + '/' + task.name);
//       int fileSize = await file.length();
//       task.totalSize = fileSize;
//       print('and the file size is $fileSize');
      
//      // openDownloadedFile(task.taskId);
//       openSnackbar(task.taskId,task.name);
//       notifyListeners();
//     }
//     //sort tasks based on status and time of addition
//     tasks.sort((a, b) {
//       if(a.status != b.status){
//         return a.status.compareTo(b.status);
//       }else{
//         return b.taskId.compareTo(a.taskId);
//       }
//     });
  

//     print('call this function from provider $status ');
//     print('call this function for $progress');
//     notifyListeners();
//   });
// }

// @pragma('vm:entry-point')
// static void downloadCallback(String id,int status ,int progress){
//   final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
//   send?.send([id,status,progress]);
  
// }

// void _unbindBackgroundIsolate(){
//    IsolateNameServer.removePortNameMapping('downloader_send_port');
// }

// Future<void> addTask(String url,dir,fileName)async{
//   print('whole tasks ----> ${tasks.length}');
//   try{
//     showMessage('Start downloading');
//     String newFileName = fileName;
//     int fileNumber = 1;
//       String baseName = fileName;
//     String extension = '';
//     File existingFile = File('$dir/$newFileName');

//     while( await existingFile.exists()){

//      int extensionIndex = fileName.lastIndexOf('.');
//      if(extensionIndex != -1){
//       baseName = fileName.substring(0,extensionIndex);
//       extension = fileName.substring(extensionIndex);
//      }
//      newFileName = '$baseName($fileNumber)$extension';
//      // newFileName = '$fileName($fileNumber)';
//       existingFile = File('$dir/$newFileName');
//       fileNumber++;
//     }


//   print('the directory after the image $dir');



//     String? taskId = await FlutterDownloader.enqueue(
//     url: url,
//     fileName: newFileName,
//      savedDir:dir,
//      showNotification: true,
//      openFileFromNotification: true,
//      saveInPublicStorage: true
//      );
//      //int totalSize = 100 * 1024 * 1024;
//      tasks.add(DownloadTasks(taskId: taskId!, url: url,  status: DownloadTaskStatus.undefined.index, progress: 0, name: newFileName, totalSize:0, dir: dir, createdDate: DateTime.now() ,));
//      notifyListeners();

//   }catch(e){
//     print('error with provider $e');
//   }
//  }
//  double bytesToMegabytes(int bytes) {
//     return bytes / (1024 * 1024);
//   }


// // double randomValue(double data){

// //   // List<double> list = [35.0,40.0,83.0];
// //   // final random = Random();
// //   //   return list[random.nextInt(list.length)].toDouble() ;
// //    return 
// // }



// double convertToDoubleProgress(int progress) {
//   double number = progress / 100;
//   if (number < 0) {
//     return 0;
//   } else if (number > 100) {
//     String numberStr = number.toString();
//     String firstTwoDigits = numberStr.substring(0, 2);
//     return double.parse(firstTwoDigits);
//   } else {
//     return number;
//   }

//   //return progress / 100; // Assuming the maximum progress value is 100
// }


// Future<String> checkAndDisplayFileSize(String name,String dir)async{
//   File file = File(dir + '/' + name);
//       int fileSize = await file.length();

//       return '$fileSize';
// }




// void retryTask(String taskId)async{
//   try {
//     await FlutterDownloader.retry(taskId: taskId);
//     print('Retry successful');
//   } catch (error) {
//     print('Error retrying task: $error');
//   }
// }


// void pauseTask(String taskId)async{
//   try {
//     await FlutterDownloader.pause(taskId: taskId);
//     print('successfully paused');
//   } catch (error) {
//     print('Error pausing task: $error');
//   }
// }

// void resumeTask(String taskId)async{
//  try {
//     await FlutterDownloader.resume(taskId: taskId);
//     print('successfully resuming');
//   } catch (error) {
//     print('Error resuming task: $error');
//   }

// }

// void cancelTask(String taskId)async{
//  try {
//     await FlutterDownloader.cancel(taskId: taskId);
//     print('cancelled successfully');
//   } catch (error) {
//     print('Error cancelling task: $error');
//   }
// }


// Future openSnackbar(String taskId, String taskName)async{
//   scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
//                     content: Text('Download complete $taskName',
//                     maxLines: 2,overflow: TextOverflow.ellipsis,
//                     ),
//                     duration: Duration(seconds: 3),
//                     behavior: SnackBarBehavior.floating,
//                     action: SnackBarAction(label: 'Open', onPressed: ()=>openDownloadedFile(taskId),
//                     textColor: Color(0xff0BA70F),
//                     ),
//                     ));
// }



//  Future<bool> openDownloadedFile(String taskId) async {
//    // final taskId = task?.taskId;
//     if (taskId == null) {
//       return false;
//     }

//     return FlutterDownloader.open(taskId: taskId);
//   }

// void removeTask(String taskId){
//   tasks.removeWhere((task) => task.taskId == taskId );
//   notifyListeners();
// }

// void removeAllTasks() {

//     tasks.clear();
//     notifyListeners();
//   }


// void clearDownloads() {
//     // Remove failed and completed downloads from the tasks list
//     tasks.removeWhere((task) =>
//         task.status == DownloadTaskStatus.failed.index ||
//         task.status == DownloadTaskStatus.complete.index);
    
//     // Notify listeners to update the UI
//     notifyListeners();
//   }







//  // Function to get the number of downloading files
//   int getDownloadingCount() {
//     return tasks.where((task) => task.status == DownloadTaskStatus.running.index).length;
//   }

//   int getDownloadingAndFailedCount(){
//     return tasks.where((task)=> task.status == DownloadTaskStatus.running.index || task.status == DownloadTaskStatus.failed.index).length;
//   }
//   // Function to get the number of completed downloads
//   int getCompletedCount() {
//     return tasks.where((task) => task.status == DownloadTaskStatus.complete.index).length;
//   }

// @override
// void dispose(){
//   IsolateNameServer.removePortNameMapping('downloader_send_port');
//   print('call this function from provider dispose');
//   super.dispose();
// }

// }