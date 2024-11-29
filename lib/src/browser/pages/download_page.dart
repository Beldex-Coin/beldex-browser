

import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/utils/download_controller.dart';
import 'package:beldex_browser/src/utils/read_write.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _downloadCon = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: normalAppBar(context, 'Downloads', themeProvider),
      body: _downloadCon.downloadList.isEmpty
            ? const Center(
              child: Text('No recent downloads')
            )

     : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          color: themeProvider.darkTheme
                              ? Color(0xff39394B)
                              : Color(0xffF3F3F3),
                          border: Border.all(color: Color(0xffFF3D00)),
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/delete.svg',
                            height: 15,
                            width: 15,
                            color: themeProvider.darkTheme
                                ? Color(0xffFFFFFF)
                                : Color(0xff222222),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Clear Downloads',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 5, child: SizedBox())
                ],
              ),
              // Container(
              //   margin: EdgeInsets.symmetric(vertical: 15),
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(15.0),
              //       color:
              //        themeProvider.darkTheme
              //           ? Color(0xff292937)
              //           : Color(0xffF3F3F3)),
              //   padding:
              //       EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),
              //   child: ListView.builder(
              //       padding: EdgeInsets.zero,
              //       itemCount: _downloadCon.downloadList.length,
              //       shrinkWrap: true,
              //       physics: NeverScrollableScrollPhysics(),
              //       itemBuilder: ((context, index) {
              //         var data = _downloadCon.downloadList[index];
              //         return data.status == "Downloading" || data.status == "Failed" ? Column(
              //           children: [
              //             Row(
              //               children: [
              //                 Expanded(
              //                   flex: 5,
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       SizedBox(
              //                         width: MediaQuery.of(context).size.width * 0.7,
              //                         child: Text(
              //                           data.name,
              //                           style: TextStyle(
              //                             fontWeight: FontWeight.bold,
              //                             // color: data.status == 'Failed'
              //                             //         ? Colors.grey
              //                             //         : Colors.white
              //                           ),
              //                           overflow: TextOverflow.ellipsis,
              //                           maxLines: 1,
              //                         ),
              //                       ),
              //                       Row(
              //                         children: [
              //                           SizedBox(
              //                             width:
              //                                 MediaQuery.of(context).size.width * 0.2,
              //                             child: Text(
              //                               '${(data.fileSize / 1000000).toStringAsFixed(2)} MB',
              //                               style: TextStyle(
              //                                   // color: data.status == 'Failed'
              //                                   //       ? Colors.grey
              //                                   //       : Colors.white
              //                                   ),
              //                             ),
              //                           ),
              //                           Expanded(
              //                             child: SizedBox(
              //                               // width:
              //                               //     MediaQuery.of(context).size.width * 0.5,
              //                               child: Text(
              //                                 data.status == null ||
              //                                         data.status == 'Downloading'
              //                                     ? 'Downloading'
              //                                     : data.status == 'Failed'
              //                                         ? 'Failed'
              //                                         : data.url,
              //                                 overflow: TextOverflow.ellipsis,
              //                                 maxLines: 1,
              //                                 softWrap: true,
              //                                 style: TextStyle(
              //                                     color:
              //                                      data.status == 'Failed'
              //                                           ? Colors.grey
              //                                           : themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81)
              //                                     ),
              //                               ),
              //                             ),
              //                           ),
              //                         ],
              //                       )
              //                     ],
              //                   ),
              //                 ),
              //                 SizedBox(
              //                     width: 40,
              //                     child: IconButton(
              //                         onPressed: () {
              //                           setState(() {
              //                             _downloadCon.downloadList.removeAt(index);
              //                             List downloadJsonList = _downloadCon
              //                                 .downloadList
              //                                 .map((item) => item.toJson())
              //                                 .toList();
              //                             write('downloadList', downloadJsonList);
              //                           });
              //                         },
              //                         icon: Icon(
              //                           Icons.close,
              //                           color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5),
              //                           size: 20,
              //                         )))
              //               ],
              //             ),
              //           index < _downloadCon.downloadList.length - 1 ? Padding(
              //              padding: const EdgeInsets.all(8.0),
              //              child: Divider(
              //               height: 1,
              //               color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
              //              ),
              //            ): Container()
              //           ],
              //         ):null;
              //       })),
              // ),
           Text('Completed',style: TextStyle(color: Colors.green),),
          
           Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: themeProvider.darkTheme
                        ? Color(0xff292937)
                        : Color(0xffF3F3F3)),
                padding:
                    EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _downloadCon.downloadList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {
                      var data = _downloadCon.downloadList[index];
                      return data.status == "Completed" ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.7,
                                      child: Text(
                                        data.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          // color: data.status == 'Failed'
                                          //         ? Colors.grey
                                          //         : Colors.white
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width * 0.2,
                                          child: Text(
                                            '${(data.fileSize / 1000000).toStringAsFixed(2)} MB',
                                            style: TextStyle(
                                                // color: data.status == 'Failed'
                                                //       ? Colors.grey
                                                //       : Colors.white
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            // width:
                                            //     MediaQuery.of(context).size.width * 0.5,
                                            child: Text(
                                              data.status == null ||
                                                      data.status == 'Downloading'
                                                  ? 'Downloading'
                                                  : data.status == 'Failed'
                                                      ? 'Failed'
                                                      : data.url,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              softWrap: true,
                                              style: TextStyle(
                                                  color:
                                                   data.status == 'Failed'
                                                        ? Colors.grey
                                                        : themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81)
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _downloadCon.downloadList.removeAt(index);
                                          List downloadJsonList = _downloadCon
                                              .downloadList
                                              .map((item) => item.toJson())
                                              .toList();
                                          write('downloadList', downloadJsonList);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5),
                                        size: 20,
                                      )))
                            ],
                          ),
                        index < _downloadCon.downloadList.length - 1 ? Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Divider(
                            height: 1,
                            color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
                           ),
                         ): Container()
                        ],
                      ):null;
                    })),
              ),
          
            ],
          ),
        ),
      ),


    );
  }

  downloadListTile(data, index) {
    return SizedBox(
        //height: 52.0,
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // SizedBox(
          //   height: 30.0,
          //   width: 30.0,
          //   child:  Mimecon(
          //     mimetype: data.mimeType,
          //     color: Colors.red,
          //     size: 25,
          //     isOutlined: true,
          //   ),
          // ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  data.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: data.status == 'Failed'
                    //         ? Colors.grey
                    //         : Colors.white
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text(
                      '${(data.fileSize / 1000000).toStringAsFixed(2)} MB',
                      style: TextStyle(
                          // color: data.status == 'Failed'
                          //       ? Colors.grey
                          //       : Colors.white
                          ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      data.status == null || data.status == 'Downloading'
                          ? 'Downloading'
                          : data.status == 'Failed'
                              ? 'Failed'
                              : data.url,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                      style: TextStyle(
                          // color: data.status == 'Failed'
                          //       ? Colors.grey
                          //       : Colors.white
                          ),
                    ),
                  ),
                ],
              )
            ],
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _downloadCon.downloadList.removeAt(index);
                  List downloadJsonList = _downloadCon.downloadList
                      .map((item) => item.toJson())
                      .toList();
                  write('downloadList', downloadJsonList);
                });
              },
              icon: const Icon(
                Icons.close,
              ))
        ],
      ),
    ));
  }

 
}
