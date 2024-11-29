

import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DownloadsListController extends GetxController{

 RxList<String> downloadingList = <String>[].obs;
  RxList<String> completedList = <String>[].obs;






fileDownloadPermission(url,dir) {
    return Get.dialog(
      DialogBox(url: url,dir:dir)  

    );
  }




// Future<void> startDownload(url,dir)async{
//    try{
//    String? taskId = await FlutterDownloader.enqueue(
//           url: url.url.toString(),
//           fileName:url.suggestedFilename , //generateUniqueFilename(baseFilename, itemCount, _dir), //fileName,
//           savedDir: dir,
//           showNotification: true,
//           openFileFromNotification: true,

//         );
//         showMessage('Start downloading...');
//      downloadingList.add(taskId!);

//    FlutterDownloader.registerCallback((id, status, progress) {
    
//      if(status == DownloadTaskStatus.complete) {
      
//       downloadingList.remove(id);
//       completedList.add(id);
//       showMessage('Download completed');
//      }
//    });



//    }catch(error){
//     showMessage(error);
//     print('Download error: $error');
//    }
// }


// void pauseDownload(String taskId){
//   FlutterDownloader.pause(taskId: taskId);
// }

// void resumeDownload(String taskId){
//   FlutterDownloader.resume(taskId: taskId);
// }






}





class DialogBox extends StatelessWidget {
  final dynamic url;
  final String dir;
  const DialogBox({super.key, required this.url, required this.dir});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    // final _downloadCon = Get.put(DownloadsListController());
    // final downloadProvider = Provider.of<DownloadProvider>(context);
    return  Dialog(
                   backgroundColor:
                  themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
              insetPadding: EdgeInsets.all(10),
                  child: Container(
                      width:MediaQuery.of(context).size.width,
               // height: 200,
                padding: EdgeInsets.all(15),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Download',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        ),
                        Text('You are about to download ${url.suggestedFilename}. \n Are you sure?',
                        textAlign: TextAlign.center,
                        ),
       
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical:10.0,),
                                child: MaterialButton(
                                  elevation: 0,
                                color:themeProvider.darkTheme ? Color(0xff42425F)  : Color(0xffF3F3F3),
                                disabledColor: Color(0xff2C2C3B),
                                 minWidth: double.maxFinite,
                                height: 50,
                                child: Text('Cancel',style: TextStyle(color: Colors.white,fontSize:18)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust the radius as needed
                                ),
                                  onPressed: (){
                                     Get.back();
                                },
                                
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex:1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical:10.0),
                                child: MaterialButton(
                                  color: Color(0xff00B134),
                                disabledColor: Color(0xff2C2C3B),
                                 minWidth: double.maxFinite,
                                height: 50,
                                child: Text('Download',style: TextStyle(color: Colors.white,fontSize:18)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust the radius as needed
                                ),
                                  onPressed: (){
                                             Get.back();
                                             //downloadProvider.addTask(url, dir,url);
                                               // Provider.of<DownloadProvider>(context,listen: false).addTask(url, dir,url.suggestedFilename);
                                            //  _downloadCon.startDownload(url,dir);  
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
  }
}