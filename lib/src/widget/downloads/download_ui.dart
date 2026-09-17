import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
import 'package:beldex_browser/src/widget/downloads/download_task_model.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:square_progress_indicator/square_progress_indicator.dart';

class DownloadUI extends StatefulWidget {
  @override
  State<DownloadUI> createState() => _DownloadUIState();
}

class _DownloadUIState extends State<DownloadUI> {
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  String formatFileSize(int fileSizeInBytes) {
    double kbSize = fileSizeInBytes / 1024; // Convert bytes to kilobytes
    double mbSize = kbSize / 1024; // Convert kilobytes to megabytes

    if (mbSize < 1.00) {
      // Display in KB if less than 0.01 MB
      return '${kbSize.toStringAsFixed(2)} KB';
    } else {
      // Display in MB if equal to or greater than 0.01 MB
      return '${mbSize.toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final downloadProvider = Provider.of<DownloadProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Positioned.fill(
        child:themeProvider.darkTheme ? Image.asset(
          'assets/images/ai-icons/new/background_map.gif',
          fit: BoxFit.cover,
        ): Image.asset(
          'assets/images/ai-icons/new/BG_wht_theme.gif',
          fit: BoxFit.cover,
        ),
      ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: Row(
      children: [
        GestureDetector(
          onTap: ()=>Navigator.pop(context),
          child: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
            height: 25,
          ),
        ),
        SizedBox(width: 8,),
        Text(loc.downloads, style: TextStyle(fontFamily: 'Inter',fontSize: 16,fontWeight: FontWeight.w900)),
      ],
    ),
            // centerTitle: true,
            // leading: IconButton(
            //     onPressed: () => Navigator.pop(context),
            //     icon: SvgPicture.asset(
            //       'assets/images/back.svg',
            //       color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
            //       height: 30,
            //     )),
            // title: TextWidget(text:loc.downloads, style: Theme.of(context).textTheme.bodyLarge),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: 
              downloadProvider.tasks.length > 0
                  ? 
                  Column(
                    children: [
                      Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                downloadProvider.clearDownloads();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: GlassCommonPanel(
                                  child: Container(
                                    height: 45,
                                    padding: EdgeInsets.only(left: 12.0,right:12.0),
                                   // margin:const EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                                        // themeProvider.darkTheme
                                        //     ? Color(0xff39394B)
                                        //     : Color(0xffF3F3F3),
                                        //border: Border.all(color: Color(0xffFF3D00)),
                                        //borderRadius: BorderRadius.circular(15)
                                        ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/delete.svg',
                                          height: 13,
                                          width: 13,
                                          color: themeProvider.darkTheme
                                              ?const Color(0xffFFFFFF)
                                              :const Color(0xff222222),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: TextWidget(
                                           text:loc.clearDownloads,// 'Clear Downloads',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Inter',color:themeProvider.darkTheme
                                              ?const Color(0xffFFFFFF)
                                              :const Color(0xff222222) ,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //Expanded(flex: 5, child:const SizedBox())
                          ],
                        ),
                      // downloadProvider
                      //                                       .getDownloadingCount() ==
                      //                                   0 ?  Padding(
                      //                       padding: const EdgeInsets.symmetric(
                      //                           vertical: 10.0),
                      //                       child: Row(
                      //                         children: [
                      //                           Padding(
                      //                             padding: const EdgeInsets.only(
                      //                                 left: 8.0),
                      //                             child: TextWidget(text:loc.downloading ,style: TextStyle(fontFamily: 'Inter',
                      //                                         fontWeight: FontWeight.w600,fontSize: 14), //'Downloading '
                      //                             ),
                      //                           ),
                      //                           downloadProvider
                      //                                       .getDownloadingCount() ==
                      //                                   0
                      //                               ? SizedBox.shrink()
                      //                               : Container(
                      //                                   height: 20,
                      //                                   width: 20,
                      //                                   margin: EdgeInsets.only(left: 8),
                      //                                   decoration: BoxDecoration(
                      //                                      // shape: BoxShape.circle,
                      //                                       color: Color(0xff00B134)),
                      //                                   child: Center(
                      //                                       child: TextWidget(
                      //                                    text: downloadProvider
                      //                                         .getDownloadingCount()
                      //                                         .toString(),
                      //                                     style: TextStyle(
                      //                                         fontSize: 10,
                      //                                         color: Colors.white),
                      //                                   )),
                      //                                 )
                      //                         ],
                      //                       ),
                      //                     ):SizedBox(),
                    ],
                  )
                  : SizedBox(),
            ),
          ),
        
          //normalAppBar(context, 'Downloads', themeProvider),
          body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: downloadProvider.tasks.length == 0
                  ?  Center(child: TextWidget(text:loc.noRecentDownloads,style: TextStyle(fontFamily: 'Inter', fontSize: 14,color:themeProvider.darkTheme
                                          ?const Color(0xffFFFFFF)
                                          :const Color(0xff222222) , ), //'No recent downloads'
                  ))
                  : Container(child: LayoutBuilder(builder: (context, constraints) {
                      return Container(
                        height: constraints.maxHeight,
                        // color: Colors.yellow,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 2,
                            itemBuilder: ((context, index) {
                              if (index == 0 &&
                                  downloadProvider.getDownloadingAndFailedCount() >
                                      0) {
                                return Container(
                                   decoration: BoxDecoration(
                                    color: Colors.transparent,
                                                  //  border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                                    //border: 
                                   ),
                                  // color: Colors.yellow,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tightForFinite(
                                        height: downloadProvider
                                                    .getDownloadingAndFailedCount() <=
                                                3
                                            ? constraints.maxHeight / 3
                                            : constraints.maxHeight / 2),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: TextWidget(text:loc.downloading ,style: TextStyle(fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w600,fontSize: 14), //'Downloading '
                                                ),
                                              ),
                                              downloadProvider
                                                          .getDownloadingCount() ==
                                                      0
                                                  ? SizedBox.shrink()
                                                  : Container(
                                                      height: 20,
                                                      width: 20,
                                                      margin: EdgeInsets.only(left: 8),
                                                      decoration: BoxDecoration(
                                                         // shape: BoxShape.circle,
                                                          color: Color(0xff00B134)),
                                                      child: Center(
                                                          child: TextWidget(
                                                       text: downloadProvider
                                                            .getDownloadingCount()
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white),
                                                      )),
                                                    )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: GlassSettingPanel(
                                            color: themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.3) : Color(0xffEBEBEB).withOpacity(0.4),
                                            child: Container(
                                              padding:const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                    border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                                                  // downloadProvider
                                                  //             .getDownloadingAndFailedCount() ==
                                                  //         1
                                                  //     ? Colors.transparent
                                                  //     : themeProvider.darkTheme
                                                  //         ?const Color(0xff292937)
                                                  //         :const Color(0xffF3F3F3),
                                                  // borderRadius:
                                                  //     BorderRadius.circular(10)
                                                      ),
                                              child: Consumer<DownloadProvider>(
                                                  builder:
                                                      (context, downloadProvider, _) {
                                                List<DownloadTasks>
                                                    downloadingOrFailedTasks =
                                                    downloadProvider.tasks
                                                        .where((task) =>
                                                            task.status ==
                                                                DownloadTaskStatus
                                                                    .running.index ||
                                                            task.status ==
                                                                DownloadTaskStatus
                                                                    .failed.index)
                                                        .toList();
                                                                                      
                                                return RawScrollbar(
                                                  controller: _scrollController1,
                                                  thumbVisibility: true,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          downloadingOrFailedTasks
                                                              .length,
                                                      controller: _scrollController1,
                                                      itemBuilder: (context, index) {
                                                        DownloadTasks task =
                                                            downloadingOrFailedTasks[
                                                                index];
                                                        return GlassSettingPanel(
                                                          color: themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.3) : Color(0xffEBEBEB).withOpacity(0.4),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal: 8,
                                                                          vertical: 3),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.transparent,
                                                                      // color: themeProvider
                                                                      //         .darkTheme
                                                                      //     ? const Color(
                                                                      //         0xff292937)
                                                                      //     :const Color(
                                                                      //         0xffF3F3F3),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                                  10)
                                                                      ),
                                                                  child: Row(
                                                                    children: [
                                                                     task.status ==
                                                                                DownloadTaskStatus.failed.index ? Container(
                                                                         height: 40,
                                                                         width: 40,
                                                                           decoration: BoxDecoration(
                                                                        //color: Color(0xffFF3D00)
                                                                        border: Border.all(color: Color(0xffFF3D00)),
                                                                        shape: BoxShape.circle
                                                                        // themeProvider
                                                                        //         .darkTheme
                                                                        //     ?const Color(
                                                                        //         0xff404054)
                                                                        //     :const Color(
                                                                        //         0xffffffff),
                                                                        // borderRadius:
                                                                        //     BorderRadius.circular(
                                                                        //         5)
                                                                        ),
                                                                        child:
                                                                      //   SquareProgressIndicator(
                                                                      // value: downloadProvider
                                                                      //     .convertToDoubleProgress(
                                                                      //         task.progress),
                                                                      // borderRadius:
                                                                      //     20,
                                                                      // color: task.status ==
                                                                      //         DownloadTaskStatus
                                                                      //             .failed.index
                                                                      //     ? Colors
                                                                      //         .transparent
                                                                      //     : Color(
                                                                      //         0xff00B134),
                                                                      // strokeWidth:
                                                                      //     1,
                                                                      // child:
                                                                          Center(child: SvgPicture.asset('assets/images/failed.svg')),
                                                                      //),
                                                                        ):
                                                                      Container(
                                                                         height: 30,
                                                                         width: 30,
                                                                           decoration: BoxDecoration(
                                                                        color: themeProvider
                                                                                .darkTheme
                                                                            ?const Color(
                                                                                0xff444444)
                                                                            :const Color(
                                                                                0xffffffff),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                5)),
                                                                        child:
                                                                        SquareProgressIndicator(
                                                                      value: downloadProvider
                                                                          .convertToDoubleProgress(
                                                                              task.progress),
                                                                      borderRadius:
                                                                          5,
                                                                      color: task.status ==
                                                                              DownloadTaskStatus
                                                                                  .failed.index
                                                                          ? Colors
                                                                              .transparent
                                                                          : Color(
                                                                              0xff00B134),
                                                                      strokeWidth:
                                                                          1,
                                                                      child:
                                                                          Container(
                                                                        child: 
                                                                        // task.status ==
                                                                        //         DownloadTaskStatus.failed.index
                                                                        //     ? SvgPicture.asset('assets/images/failed.svg')
                                                                        //     : 
                                                                            TextWidget(
                                                                               text: '${task.progress}%',
                                                                                style: TextStyle(color: Color(0xff00B134), fontSize: 11),
                                                                              ),
                                                                        //color: Colors.pink,
                                                                      ),
                                                                      ),
                                                                        ),
                                                                     const SizedBox(
                                                                        width: 15,
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .baseline,
                                                                          textBaseline:
                                                                              TextBaseline
                                                                                  .alphabetic,
                                                                          children: [
                                                                            TextWidget(
                                                                             text: task.name,
                                                                              style: TextStyle(
                                                                                  fontSize:
                                                                                      14,fontFamily: 'Inter',
                                                                                  fontWeight:
                                                                                      FontWeight.w800),
                                                                              overflow:
                                                                                  TextOverflow
                                                                                      .ellipsis,
                                                                              maxLines:
                                                                                  1,
                                                                            ),
                                                                            TextWidget(
                                                                             text: task.status ==
                                                                                      DownloadTaskStatus.failed.index
                                                                                  ? loc.downloadFailed// 'Download Failed!'
                                                                                  : task.status == DownloadTaskStatus.paused.index
                                                                                      ? 'Download paused'
                                                                                      : "${loc.downloading}...", //' Downloading...',
                                                                              style: TextStyle(
                                                                                  color: task.status == DownloadTaskStatus.failed.index
                                                                                      ? const Color(0xffFF3D00)
                                                                                      :const Color(0xff00B134),
                                                                                      fontFamily: 'Roboto',
                                                                                  fontSize: 13),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          downloadProvider
                                                                              .cancelTask(
                                                                                  task.taskId);
                                                                          downloadProvider
                                                                              .removeTask(
                                                                                  task.taskId);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height: 50,
                                                                          width: 50,
                                                                          child: Icon(
                                                                            Icons.close,
                                                                            size: 20,
                                                                            color: themeProvider
                                                                                    .darkTheme
                                                                                ?const Color(
                                                                                    0xff6D6D81)
                                                                                :const Color(
                                                                                    0xff6D6D81),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )),
                                                              index <
                                                                      downloadingOrFailedTasks
                                                                              .length -
                                                                          1
                                                                  ? Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(8.0),
                                                                      child: Divider(
                                                                        height: 1,
                                                                        color: themeProvider
                                                                                .darkTheme
                                                                            ?const Color(
                                                                                0xff444444)
                                                                            :const Color(
                                                                                0xffDADADA),
                                                                      ),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (index == 1) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints.expand(
                                      height: downloadProvider
                                                  .getDownloadingAndFailedCount() ==
                                              0
                                          ? constraints.maxHeight
                                          : constraints.maxHeight / 1.50),
                                  child: downloadProvider.getCompletedCount() == 0
                                      ? Container(
                                          child: Column(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.center,
                                          children: [
                                           
                                            SvgPicture.asset(
                                                'assets/images/no_downloads.svg',
                                                color:Color(0xff8D8D8D)
                                                 
                                                    ),
                                            Center(
                                                child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: TextWidget(
                                               text:loc.noCompletedDownloads, //'No completed downloads',
                                                style: TextStyle(
                                                    color: Color(0xff8D8D8D),fontFamily: 'Inter',fontWeight: FontWeight.w600, 
                                                    fontSize: 15),
                                              ),
                                            ))
                                          ],
                                        ))
                                      : Column(
                                          children: [
                                            downloadProvider.getCompletedCount() ==
                                                    0
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 10.0,
                                                            horizontal: 8),
                                                    child: Row(
                                                      children: [
                                                        TextWidget(text:loc.completed, //'Completed',
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              fontWeight: FontWeight.w600,
                                                                color: Color(
                                                                    0xff0BA70F),
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                            Expanded(
                                              child: GlassSettingPanel(
                                                color: themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.3) : Color(0xffEBEBEB).withOpacity(0.4),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10, horizontal: 8),
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                                                      // themeProvider.darkTheme
                                                      //     ?const Color(0xff292937)
                                                      //     :const Color(0xffF3F3F3),
                                                      // borderRadius:
                                                      //     BorderRadius.circular(10)
                                                          ),
                                                  child: Consumer<DownloadProvider>(
                                                    builder: (context,
                                                        downloadProvider, _) {
                                                      List<DownloadTasks>
                                                          completedTasks =
                                                          downloadProvider.tasks
                                                              .where((task) =>
                                                                  task.status ==
                                                                  DownloadTaskStatus
                                                                      .complete.index)
                                                              .toList();
                                                      completedTasks.sort(
                                                        (a, b) {
                                                          return b.createdDate
                                                              .compareTo(
                                                                  a.createdDate);
                                                        },
                                                      );
                                                      // completedTasks.isSortedBy
                                                      return RawScrollbar(
                                                        thumbVisibility: true,
                                                        controller:
                                                            _scrollController2,
                                                        child: ListView.builder(
                                                          controller:
                                                              _scrollController2,
                                                          // shrinkWrap: true,
                                                          itemCount:
                                                              completedTasks.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            DownloadTasks task =
                                                                completedTasks[index];
                                                            return Column(
                                                              children: [
                                                                Container(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            right: 8,
                                                                            top: 3,
                                                                            bottom:
                                                                                3),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.transparent
                                                                        // color: themeProvider
                                                                        //         .darkTheme
                                                                        //     ?const Color(
                                                                        //         0xff292937)
                                                                        //     :const Color(
                                                                        //         0xffF3F3F3),
                                                                        // borderRadius:
                                                                        //     BorderRadius
                                                                        //         .circular(
                                                                        //             10)
                                                                        ),
                                                                    child: Row(
                                                                      children: [
                                                                       const SizedBox(
                                                                          width: 15,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () async {
                                                                              final success =
                                                                                  await downloadProvider.openDownloadedFile(task.taskId);
                                                                              if (!success) {
                                                                                showMessage(loc.cannotOpenThisFile);
                                                                                // ScaffoldMessenger.of(context).showSnackBar(
                                                                                //   const SnackBar(
                                                                                //     content: Text('Cannot open this file'),
                                                                                //   ),
                                                                                // );
                                                                              }
                                                                            },
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.baseline,
                                                                              textBaseline:
                                                                                  TextBaseline.alphabetic,
                                                                              children: [
                                                                                TextWidget(
                                                                                  text:'${task.name}',
                                                                                  style:
                                                                                      TextStyle(fontSize: 14, fontWeight: FontWeight.w800,fontFamily: 'Inter'),
                                                                                  overflow:
                                                                                      TextOverflow.ellipsis,
                                                                                  maxLines:
                                                                                      1,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 8.0),
                                                                                      child: TextWidget(
                                                                                        text:formatFileSize(task.totalSize), //'${(task.totalSize / (1024 * 1024)).toStringAsFixed(2)} MB',
                                                                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600),
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(child: TextWidget(text:'${task.url}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: themeProvider.darkTheme ? Color(0xff8D8D8D) : Color(0xff444444))))
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: () =>
                                                                              downloadProvider
                                                                                  .removeTask(task.taskId),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            width: 50,
                                                                            child:
                                                                             Icon(
                                                                                Icons
                                                                                    .close,
                                                                                size:
                                                                                    20,
                                                                                color: themeProvider.darkTheme
                                                                                    ?const Color(0xff737373)
                                                                                    :const Color(0xff444444)),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )),
                                                                index <
                                                                        completedTasks
                                                                                .length -
                                                                            1
                                                                    ? Padding(
                                                                        padding:
                                                                            const EdgeInsets
                                                                                .all(
                                                                                8.0),
                                                                        child:
                                                                            Divider(
                                                                          height: 1,
                                                                          color: themeProvider
                                                                                  .darkTheme
                                                                              ?const Color(
                                                                                  0xff444444)
                                                                              :const Color(
                                                                                  0xffDADADA),
                                                                        ),
                                                                      )
                                                                    : Container()
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              }
        
                              return Container();
                            })),
                      );
                    }))
              ),
        ),
      ],
    );
  }

  AppBar normalAppBar(
      BuildContext context, String title, DarkThemeProvider themeProvider) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
            height: 30,
          )),
      title: TextWidget(text:title, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
