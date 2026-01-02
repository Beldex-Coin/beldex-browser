import 'package:beldex_browser/l10n/generated/app_localizations.dart';
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/images/back.svg',
              color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
              height: 30,
            )),
        title: TextWidget(text:loc.downloads, style: Theme.of(context).textTheme.bodyLarge),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: downloadProvider.tasks.length > 0
              ? Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () {
                          downloadProvider.clearDownloads();
                        },
                        child: Container(
                          height: 45,
                          margin:const EdgeInsets.only(left: 10),
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
                                    ?const Color(0xffFFFFFF)
                                    :const Color(0xff222222),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextWidget(
                                 text:loc.clearDownloads,// 'Clear Downloads',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex: 5, child:const SizedBox())
                  ],
                )
              : SizedBox(),
        ),
      ),

      //normalAppBar(context, 'Downloads', themeProvider),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: downloadProvider.tasks.length == 0
              ?  Center(child: TextWidget(text:loc.noRecentDownloads //'No recent downloads'
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
                                            child: TextWidget(text:loc.downloading //'Downloading '
                                            ),
                                          ),
                                          downloadProvider
                                                      .getDownloadingCount() ==
                                                  0
                                              ? SizedBox.shrink()
                                              : Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xff00B134)),
                                                  child: Center(
                                                      child: TextWidget(
                                                   text: downloadProvider
                                                        .getDownloadingCount()
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  )),
                                                )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding:const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        decoration: BoxDecoration(
                                            color: downloadProvider
                                                        .getDownloadingAndFailedCount() ==
                                                    1
                                                ? Colors.transparent
                                                : themeProvider.darkTheme
                                                    ?const Color(0xff292937)
                                                    :const Color(0xffF3F3F3),
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
                                                  return Column(
                                                    children: [
                                                      Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 3),
                                                          decoration: BoxDecoration(
                                                              color: themeProvider
                                                                      .darkTheme
                                                                  ? const Color(
                                                                      0xff292937)
                                                                  :const Color(
                                                                      0xffF3F3F3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                 height: 30,
                                                                 width: 30,
                                                                   decoration: BoxDecoration(
                                                                color: themeProvider
                                                                        .darkTheme
                                                                    ?const Color(
                                                                        0xff404054)
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
                                                                child: task.status ==
                                                                        DownloadTaskStatus.failed.index
                                                                    ? SvgPicture.asset('assets/images/failed.svg')
                                                                    : TextWidget(
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
                                                                              14,
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
                                                                        0xff42425F)
                                                                    :const Color(
                                                                        0xffDADADA),
                                                              ),
                                                            )
                                                          : Container()
                                                    ],
                                                  );
                                                }),
                                          );
                                        }),
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
                                            color: themeProvider.darkTheme
                                                ? Color(0xff6D6D81)
                                                : Color(0xffDADADA)),
                                        Center(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: TextWidget(
                                           text:loc.noCompletedDownloads, //'No completed downloads',
                                            style: TextStyle(
                                                color: themeProvider.darkTheme
                                                    ?const Color(0xff6D6D81)
                                                    :const Color(0xffDADADA),
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
                                                            color: Color(
                                                                0xff0BA70F),
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            decoration: BoxDecoration(
                                                color: themeProvider.darkTheme
                                                    ?const Color(0xff292937)
                                                    :const Color(0xffF3F3F3),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
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
                                                                  color: themeProvider
                                                                          .darkTheme
                                                                      ?const Color(
                                                                          0xff292937)
                                                                      :const Color(
                                                                          0xffF3F3F3),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
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
                                                                                TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
                                                                                  style: TextStyle(fontSize: 13),
                                                                                ),
                                                                              ),
                                                                              Expanded(child: TextWidget(text:'${task.url}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xff6D6D81))))
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
                                                                      child: Icon(
                                                                          Icons
                                                                              .close,
                                                                          size:
                                                                              20,
                                                                          color: themeProvider.darkTheme
                                                                              ?const Color(0xff6D6D81)
                                                                              :const Color(0xff6D6D81)),
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
                                                                            0xff42425F)
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
                                      ],
                                    ),
                            );
                          }

                          return Container();
                        })),
                  );
                }))
          ),
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
