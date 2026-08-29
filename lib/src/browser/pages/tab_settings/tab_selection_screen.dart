// import 'package:beldex_browser/src/browser/ai/view_models/folder_system/folder_tab_system.dart';
// import 'package:beldex_browser/src/browser/ai/view_models/folder_system/group_provider.dart';
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/folder_tab_system.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class TabSelectionScreen
    extends StatelessWidget {

  const TabSelectionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final provider =
        Provider.of<GroupProvider>(
      context,
    );
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final browser =
        provider.browserProvider!;

    final allTabs =
        browser.webViewTabs
            .map(
              (e) => e.webViewModel,
            )
            .toList();

    return PopScope(
      onPopInvoked: (didPop) {

    provider.disableSelectionMode();
  },
      child: Stack(
        children: [
          Positioned.fill(
        child: themeProvider.darkTheme ? Image.asset(
          'assets/images/ai-icons/new/background_map.gif',
          fit: BoxFit.cover,
        ): Image.asset(
          'assets/images/ai-icons/new/BG_wht_theme.gif',
          fit: BoxFit.cover,
        ),
      ),
          Scaffold(
          
            backgroundColor:
                Colors.transparent,
          
            appBar: AppBar(
          
              backgroundColor: Colors.transparent,
                 // Colors.black,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                   GestureDetector(
          onTap:()=> Navigator.pop(context),
          child: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
            height: 25,
          ),
        ),
        SizedBox(width: 8,),
                  Expanded(
                    child: Text(
                      "${provider.selectedTabs.length} ${loc.selected}",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),maxLines: 1,overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          
             actions: [
          PopupMenuButton<String>(
           menuPadding: EdgeInsets.zero,
                         color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
  elevation: 0,
  shadowColor: Colors.transparent,
  surfaceTintColor:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9) :Color(0xffEBEBEB).withOpacity(0.9),
       // color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
        constraints: BoxConstraints(
                  maxWidth: 220,
                 ),
              icon: SvgPicture.asset('assets/images/ai-icons/new/vert_menu.svg',color:themeProvider.darkTheme ? Colors.white : Colors.black),// Icon(Icons.more_horiz,
                  //color: themeProvider.darkTheme ? Colors.white : Colors.black),
       // onSelected: _popupMenuChoiceAction,
        offset: Offset(0, 47),
        shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
    side: BorderSide(
      color:themeProvider.darkTheme ? Color(0xff333333) :  Color(0xffD4D4D4), //.withOpacity(0.2),
      width: 1,
    ),
  ),
            onSelected: (value) async {
          
              /// SELECT / DESELECT ALL
              if (value == "toggle_select_all") {
          
          provider.toggleSelectAllTabs();
              }
          
              /// CLOSE TABS
              else if (value == "close_tabs") {
          
          if (provider.selectedTabs.isEmpty) {
            return;
          }
          
          await provider.closeSelectedTabs(
            context,
          );
           Navigator.pop(context);
              }
          
              /// ADD TO GROUP
              else if (value == "add_to_group") {
          
          if (provider.selectedTabs.isEmpty) {
            return;
          }
           showAddToGroupBottomSheet(context,loc);
          // showCreateGroupDialog(
          
          //   context: context,
          
          //   tabs: provider.selectedTabs,
          // );
              }
            },
          
            itemBuilder: (_) => [
          
              /// SELECT / DESELECT ALL
              PopupMenuItem(
            
          value: "toggle_select_all",
            height: 35,
                  padding: EdgeInsets.zero,
          child: GlassSettingPanel(
             color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
            child: Container(
              height: 35,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: Row(
                  children: [
                            provider.allTabsSelected ?
                 SvgPicture.asset('assets/images/ai-icons/new/Deselect_all.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836))
                : SvgPicture.asset('assets/images/ai-icons/new/Selecttabs.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                                
                    Expanded(
                      child: Text(provider.allTabsSelected ? "${loc.deselectAll}" : "${loc.selectAll}",
                            style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
              ),
          
              /// CLOSE TABS
              PopupMenuItem(
          
          enabled:
              provider.selectedTabs.isNotEmpty,
          
          value: "close_tabs",
          height: 35,
          padding: EdgeInsets.zero,
          child: GlassSettingPanel(
            color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
            child: Container(
              height: 35,
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Row(
                children: [
                   SvgPicture.asset('assets/images/ai-icons/new/Close All Tabs.svg' ,color:provider
                              .selectedTabs
                              .isNotEmpty ? themeProvider.darkTheme
                                                        ?const Color(0xffFFFFFF)
                                                        :const Color(0xff282836) : Colors.grey),
                                                        SizedBox(width: 8,),
                                  
                      Expanded(
                        child: Text(provider.selectedTabs.length <= 1  ? "${loc.closeTab}" : "${loc.closeTabs}",
                              style:TextStyle(fontSize: 14,fontFamily: 'Inter',color:provider
                                .selectedTabs
                                .isNotEmpty ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B) : Colors.grey),overflow: TextOverflow.ellipsis,maxLines: 1,
                        ),
                      ),
                  // Icon(
              
                  //   Icons.close,
              
                  //   color: provider
                  //           .selectedTabs
                  //           .isNotEmpty
              
                  //       ? null
                  //       : Colors.grey,
                  // ),
              
                  // const SizedBox(width: 10),
              
                  // Text(
              
                  //   provider.selectedTabs.length <= 1
              
                  //       ? "Close tab"
              
                  //       : "Close tabs",
              
                  //    style:TextStyle(fontSize: 14,fontFamily: 'Inter',color:provider
                  //             .selectedTabs
                  //             .isNotEmpty ?  themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B) : Colors.grey),overflow: TextOverflow.ellipsis,maxLines: 1,
                    
                  // ),
                ],
              ),
            ),
          ),
              ),
          
              /// ADD TO GROUP
              PopupMenuItem(
          
            enabled: provider.selectedTabs.isNotEmpty,
          
            value: "add_to_group",
           height: 35,
           padding: EdgeInsets.zero,
            child: GlassSettingPanel(
              color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
              child: Container(
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: Row(
                  children: [
                  SvgPicture.asset('assets/images/ai-icons/new/New Tab Group.svg' ,color:provider
                                  .selectedTabs
                                  .isNotEmpty ? themeProvider.darkTheme
                                                            ?const Color(0xffFFFFFF)
                                                            :const Color(0xff282836) : Colors.grey),
                                                            SizedBox(width: 8,),
                                      
                          Expanded(
                            child: Text(provider.selectedTabs.length <= 1  ? loc.addToTabGroup : loc.addToTabGroup,
                                  style:TextStyle(fontSize: 14,fontFamily: 'Inter',color:provider
                                    .selectedTabs
                                    .isNotEmpty ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B) : Colors.grey),overflow: TextOverflow.ellipsis,maxLines: 1,
                            ),
                          ),
                //           Icon(
                // Icons.group_work_outlined,
                // color: provider.selectedTabs.isNotEmpty
                //     ? null
                //     : Colors.grey,
                //           ),
                          
                //           const SizedBox(width: 10),
                          
                //           Text(
                          
                // provider.selectedTabs.length <= 1
                //     ? "Add tab to group"
                //     : "Add tabs to group",
                          
                // style: TextStyle(
                //   color: provider.selectedTabs.isNotEmpty
                //       ? null
                //       : Colors.grey,
                // ),
                //           ),
                  ],
                ),
              ),
            ),
          ),
              // PopupMenuItem(
          
              //   enabled:
              //       provider.selectedTabs.isNotEmpty,
          
              //   value: "add_to_group",
          
              //   child: Row(
              //     children: [
          
              //       Icon(
          
              //         Icons.group_work_outlined,
          
              //         color: provider
              //                 .selectedTabs
              //                 .isNotEmpty
          
              //             ? null
              //             : Colors.grey,
              //       ),
          
              //       const SizedBox(width: 10),
          
              //       Text(
          
              //         "Add tabs to group",
          
              //         style: TextStyle(
          
              //           color: provider
              //                   .selectedTabs
              //                   .isNotEmpty
          
              //               ? null
              //               : Colors.grey,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          )
            // PopupMenuButton<String>(
          
            //   color: Colors.grey.shade900,
          
            //   onSelected: (value) async {
          
            //     /// SELECT ALL
            //     if (value == "select_all") {
          
            //       provider.selectAllTabs();
            //     }
          
            //     /// CLOSE TABS
            //     else if (value == "close_tabs") {
          
            //       await provider.closeSelectedTabs(
            //         context,
            //       );
            //     }
          
            //     /// ADD TO GROUP
            //     else if (value == "add_to_group") {
          
            //       // showCreateGroupDialog(
            //       //   context: context,
            //       //   tabs: provider.selectedTabs,
            //       // );
            //     }
            //   },
          
            //   itemBuilder: (_) => [
          
            //     const PopupMenuItem(
          
            //       value: "select_all",
          
            //       child: Row(
            //         children: [
          
            //           Icon(Icons.select_all),
          
            //           SizedBox(width: 10),
          
            //           Text("Select all"),
            //         ],
            //       ),
            //     ),
          
            //     PopupMenuItem(
          
            //       value: "close_tabs",
          
            //       child: Row(
            //         children: [
          
            //           const Icon(Icons.close),
          
            //           const SizedBox(width: 10),
          
            //           Text(
          
            //             provider.selectedTabs.length <= 1
            //                 ? "Close tab"
            //                 : "Close tabs",
            //           ),
            //         ],
            //       ),
            //     ),
          
            //     const PopupMenuItem(
          
            //       value: "add_to_group",
          
            //       child: Row(
            //         children: [
          
            //           Icon(Icons.group_work_outlined),
          
            //           SizedBox(width: 10),
          
            //           Text("Add tabs to group"),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          
            // IconButton(
          
            //   onPressed: () {
          
            //     provider.disableSelectionMode();
          
            //     Navigator.pop(context);
            //   },
          
            //   icon: const Icon(
            //     Icons.close,
            //   ),
            // ),
          ],
            ),
          
            body: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                
                  padding:
                      const EdgeInsets.all(16),
                 crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                
                  children: [
                
                    /// UNGROUPED TABS
                    ...provider.outsideTabs.map(
                      (tab) {
                
                final selected =
                    provider.isSelected(
                  tab,
                );
                
                return SizedBox(
                   width: constraints.maxWidth,
          height: constraints.maxHeight,
                  child: buildBox(
                  
                    title:
                        tab.title ?? "Tab",
                  
                    screenshot:
                        tab.screenshot,
                  
                    color:
                        Colors.deepPurple,
                  
                    onClose: () {},
                  
                    onTap: () {
                      print('THIS IS CLIKCED FOR TAB');
                      provider.toggleTabSelection(
                        tab,
                      );
                    },
                  
                    selectionMode: provider.selectionMode, //true,
                  
                    isSelected:provider.isSelected(
                    tab,
                  ),
                       // selected,
                  
                    onSelect: () {
                                  print('THIS IS CLIKCED FOR TAB selected');
                  
                      provider.toggleTabSelection(
                        tab,
                      );
                    }, isCurrentTab: false, themeProvider: themeProvider,
                  ),
                );
                      },
                    ),
                
                    /// GROUPS
                    ...provider.groups.where((group) => !group.isClosed).map(
                      (group) {
                
                return
                SelectableGroupWidget(
                  group: group,
                );
                      },
                    ),
                  ],
                );
              }
            ),
          bottomNavigationBar: Container(
            height: 65,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3)))
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                 child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Row(
                    children: [
                      GestureDetector(
                        onTap:provider.allTabsSelected ? () {
                          provider.toggleSelectAllTabs();
                        }: null,
                        child: Container(
                          height: 20,width: 20,
                          child: SvgPicture.asset('assets/images/ai-icons/new/Deselect_all.svg',color: provider.allTabsSelected ? themeProvider.darkTheme ? Colors.white : Colors.black : Color(0xff737373) ,)),
                      ),
                      SizedBox(width: 8,),
                      Text(loc.deselectAll,style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: provider.allTabsSelected ? themeProvider.darkTheme ? Colors.white : Colors.black : Color(0xff737373)),overflow: TextOverflow.ellipsis,maxLines: 1,),

                    ],
                   ),
                   Row(
                    children: [
                       GestureDetector(
                        onTap: (){
                          provider.toggleSelectAllTabs();
                        },
                         child: Container(
                          height: 20,width: 20,
                          decoration: BoxDecoration(
                            color: provider.allTabsSelected ? Colors.white : Colors.transparent,
                            border: Border.all(color: themeProvider.darkTheme ? Colors.transparent : Colors.black)
                          ),
                          child: provider.allTabsSelected ? Icon(Icons.check,size: 15, color: Colors.black,) : SvgPicture.asset('assets/images/ai-icons/new/Selecttabs.svg')),
                       ),
                      SizedBox(width: 8,),
                      Text(loc.selectAll,style: TextStyle(fontFamily: 'Inter',fontSize: 14),overflow: TextOverflow.ellipsis,maxLines: 1,),
                      
                    ],
                   )
                  ],
                  )
          ),
          
          ),
        ],
      ),
    );
  }

  // Widget _groupLabel(
  //   GroupProvider provider,
  //   WebViewModel tab,
  // ) {

  //   GroupModel? foundGroup;

  //   for (final g in provider.groups) {

  //     final exists =
  //         g.tabs.any(
  //       (e) => e.uuid == tab.uuid,
  //     );

  //     if (exists) {

  //       foundGroup = g;
  //       break;
  //     }
  //   }

  //   if (foundGroup == null) {
  //     return const SizedBox();
  //   }

  //   return Container(

  //     padding:
  //         const EdgeInsets.symmetric(
  //       horizontal: 10,
  //       vertical: 4,
  //     ),

  //     decoration: BoxDecoration(

  //       color: foundGroup.color,

  //       borderRadius:
  //           BorderRadius.circular(
  //         20,
  //       ),
  //     ),

  //     child: Text(

  //       foundGroup.name,

  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 11,
  //         fontWeight:
  //             FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
}


class SelectableGroupWidget
    extends StatelessWidget {

  final GroupModel group;

  const SelectableGroupWidget({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<GroupProvider>(
      context,
    );
    
    final themeProvider = Provider.of<DarkThemeProvider>(context);

    final selected =
        group.tabs.every(
      (tab) =>
          provider.isSelected(tab),
    );

    return GestureDetector(

      onTap: () {
      print('THIS IS CLICKERD');
        /// SELECT/UNSELECT WHOLE GROUP
        for (final tab in group.tabs) {

          provider.toggleTabSelection(
            tab,
          );
        }
      },

      child: Stack(

        children: [
           GlassGroupPanel(
            color: group.color,
            child: AnimatedContainer(
            
              duration:
                  const Duration(
                milliseconds: 220,
              ),
            
              decoration: BoxDecoration(
                //color: Colors.grey,
                border: Border.all(color: provider.groupContainsCurrentTab(group) ? group.color : Colors.transparent ,width: 0.40),
                // borderRadius:
                //     BorderRadius.circular(
                //   16,
                // ),
            
                // boxShadow:
                //     candidateData.isNotEmpty
                //         ? [
                //             BoxShadow(
                //               color: Colors.green
                //                   .withOpacity(
                //                 0.5,
                //               ),
                //               blurRadius: 18,
                //               spreadRadius: 3,
                //             ),
                //           ]
                //         : [],
              ),
              child: ClipRRect(
            
              // borderRadius:
              //     BorderRadius.circular(16),
            
              child: Column(
                children: [
            
                  /// TOP BAR
                  Container(
            
                    height: 42,
            
                    padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
                    ),
            
                    color:Colors.transparent, //group.color,
            
                    child: Row(
            children: [
              Container(height: 8,width: 8,decoration: BoxDecoration(shape: BoxShape.circle,color: group.color),),
              SizedBox(width: 5,),
              Expanded(
                child: Text(
            
                  group.name,
            
                  maxLines: 1,
            
                  overflow:
                      TextOverflow.ellipsis,
            
                  style:
                       TextStyle(
                    color:themeProvider.darkTheme ? Colors.white : Colors.black,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            
              Container(

              width: 15,
              height: 15,

              decoration: BoxDecoration(
                 border: Border.all(color:themeProvider.darkTheme ? Colors.white : Color(0xff0B0B0B)),
               // shape: BoxShape.circle,

                color: 
                selected
                    ? themeProvider.darkTheme ? Colors.white : Color(0xffffffff)
                    : themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
              ),

              child: Icon(
                  Icons.check,
                // selected
                //     ? Icons.check
                //     : Icons.circle_outlined,

                size: 12,

                color: selected
                    ? Colors.black
                    : Colors.transparent,
              ),
            ),
                //  Text(
            
                //   "${group.tabs.length}",
            
                //   style:
                //       const TextStyle(
                //     color: Colors.white,
                //     fontSize: 11,
                //     fontWeight:
                //         FontWeight.bold,
                //   ),
                // ),
              
            ],
                    ),
                  ),
            



Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {

      List<WebViewModel> tabs = List.from(group.tabs);

      while (tabs.length < 4) {
        tabs.add(WebViewModel(uuid: '')); // placeholder
      }

      Widget buildPreview(int index) {

        final tab = tabs[index];

        return Container(
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
           color:  themeProvider.darkTheme ? Colors.black.withOpacity(0.7): Color(0xffffffff)
            // border: Border.all(
            //   color: const Color(0xff102436),
            //   width: 1,
            // ),
          ),
          child: tab.screenshot != null
              ? Image.memory(
                  tab.screenshot!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: themeProvider.darkTheme ? Colors.black.withOpacity(0.7): Color(0xffffffff),
                  child: Center(
                    child: SvgPicture.asset('assets/images/ai-icons/new/Default_Image.svg',color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4),height: 20,)
                  ),
                ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildPreview(0)),
                Expanded(child: buildPreview(1)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildPreview(2)),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      buildPreview(3),

                      if (group.tabs.length > 4)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: Text(
                            '+${group.tabs.length - 4}',
                            style: TextStyle(
                              color:themeProvider.darkTheme ? Colors.white : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  ),
)

                ],
              ),
            ),
              // child: Stack(
              //   children: [
            
              //     Positioned(
              //       left: 8,
              //       top: 8,
            
              //       child: miniPreview(
              //         group.tabs,
              //       ),
              //     ),
            
              //     Center(
              //       child: Text(
              //         "Group\n${group.tabs.length} tabs",
            
              //         textAlign:
              //             TextAlign.center,
            
              //         style:
              //             const TextStyle(
              //           color: Colors.white,
              //           fontWeight:
              //               FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),
          /// GROUP PREVIEW
          // Container(

          //   decoration: BoxDecoration(

          //     color: group.color,

          //     borderRadius:
          //         BorderRadius.circular(
          //       18,
          //     ),
          //   ),

          //   child: Column(
          //     children: [

          //       Expanded(
          //         child: groupPreviewGrid(
          //           group.tabs,
          //         ),
          //       ),

          //       Padding(
          //         padding:
          //             const EdgeInsets.all(
          //           12,
          //         ),

          //         child: Text(

          //           "${group.name}\n${group.tabs.length} tabs",

          //           textAlign:
          //               TextAlign.center,

          //           style:
          //               const TextStyle(
          //             color: Colors.white,
          //             fontWeight:
          //                 FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          /// CHECK ICON
          // Positioned(

          //   top: 10,
          //   right: 10,

          //   child: Container(

          //     width: 15,
          //     height: 15,

          //     decoration: BoxDecoration(
          //        border: Border.all(color:themeProvider.darkTheme ? Colors.white : Color(0xff0B0B0B)),
          //      // shape: BoxShape.circle,

          //       color: 
          //       selected
          //           ? themeProvider.darkTheme ? Colors.white : Color(0xffffffff)
          //           : themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
          //     ),

          //     child: Icon(
          //         Icons.check,
          //       // selected
          //       //     ? Icons.check
          //       //     : Icons.circle_outlined,

          //       size: 12,

          //       color: selected
          //           ? Colors.black
          //           : Colors.transparent,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
Widget groupPreviewGrid(
  List<WebViewModel> tabs,
) {

  final previewTabs =
      tabs.take(4).toList();

  return GridView.builder(

    physics:
        const NeverScrollableScrollPhysics(),

    padding: EdgeInsets.zero,

    itemCount: previewTabs.length,

    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

      crossAxisCount: 2,

      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    ),

    itemBuilder: (
      context,
      index,
    ) {

      final tab =
          previewTabs[index];

      return Stack(

        fit: StackFit.expand,

        children: [

          /// SCREENSHOT
          tab.screenshot != null

              ? Image.memory(

                  tab.screenshot!,

                  fit: BoxFit.cover,
                )

              : Container(

                  color:
                      Colors.grey.shade300,

                  child: const Icon(
                    Icons.language,
                    color:
                        Colors.white54,
                  ),
                ),

          /// DARK OVERLAY
          Container(
            color: Colors.black
                .withOpacity(0.08),
          ),

          /// +MORE OVERLAY
          if (index == 3 &&
              tabs.length > 4)

            Container(

              alignment:
                  Alignment.center,

              color: Colors.black
                  .withOpacity(0.55),

              child: Text(

                "+${tabs.length - 4}",

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    },
  );
}



void showAddToGroupBottomSheet(
  BuildContext context,AppLocalizations loc
)async {
  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final themeProvider  = Provider.of<DarkThemeProvider>(context,listen: false);
 final ScrollController scrollController = ScrollController();
 await showDialog(
   barrierColor: Colors.black.withOpacity(0.7),
    context: context,

    // shape: const RoundedRectangleBorder(
    //   borderRadius: BorderRadius.vertical(
    //     top: Radius.circular(24),
    //   ),
    // ),

    builder: (_) {
//  final selectedGroups =
//     provider.getSelectedGroups();
final openGroups = provider.groups
    .where((g) => !g.isClosed)
    .toList();

final selectedGroups = provider
    .getSelectedGroups()
    .where((g) => !g.isClosed)
    .toList();

final availableGroups = openGroups.where((group) {
  if (openGroups.length == 1 &&
      selectedGroups.length == 1 &&
      selectedGroups.first.id == group.id) {
    return false;
  }
  return true;
}).toList();
      return Dialog(
         insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
        child: GlassPanel(
          child: Container(
        //      constraints: BoxConstraints(
        //  // minHeight: 250,
        //   maxHeight: MediaQuery.of(context).size.height * 0.75,
        //   minWidth: MediaQuery.of(context).size.width,
        // ),
            child: Container(
              margin: EdgeInsets.all(20),
                   // width: MediaQuery.of(context).size.width,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
              
                children: [
              
                  const SizedBox(height: 12),
              
                  Text(loc.addTo.toUpperCase(),
                     //"ADD TO ",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Conthrax",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: (){
                       Navigator.pop(context);
              
                      showCreateGroupDialog(
                        context,loc
                      );
                    },
                    child: Container(
                       //margin: EdgeInsets.symmetric(horizontal: 15),
                      height: 50,decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff444444)),
                        //color: Colors.black26
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.addtoNewTabGroup,// 'Add to new tab group',
                            style: TextStyle(fontSize: 14,fontFamily: 'Inter'),),
                             Icon(Icons.add, size: 15,)
                          ],
                        ),
                    ),
                  ),
                  /// NEW GROUP
                  // ListTile(
              
                  //   leading: const Icon(
                  //     Icons.add_circle_outline,
                  //   ),
              
                  //   title: const Text(
                  //     "New Tab Group",
                  //   ),
              
                  //   onTap: () {
              
                  //     Navigator.pop(context);
              
                  //     showCreateGroupDialog(
                  //       context,
                  //     );
                  //   },
                  // ),
              
                  //const Divider(),
              
                  /// EXISTING GROUPS
                  // ...provider.groups.map(
                  //   (group) {
                  
              
              // ...provider.groups
              //     .where(
              //       (group) =>
              //           !selectedGroups.any(
              //         (g) => g.id == group.id,
              //       ),
              //     )
              //     .map(
              //       (group) {
              

             

            availableGroups.length != 0 ? Flexible(
                
                child: ConstrainedBox(
                   constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.45,
    ),
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: availableGroups.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final group = availableGroups[index];
                  
                        return GestureDetector(
                          onTap: (){
                                Navigator.pop(
                              context,
                            );
                                
                            provider
                                .addSelectedTabsToGroup(
                              group,
                            );
                                
                            provider
                                .disableSelectionMode();
                             Navigator.pop(context);  

                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical:8.0),
                            child: GlassGroupPanel(
                              color: group.color,
                              child: Container(
                                height: 90,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: provider
                                            .groupContainsCurrentTab(
                                                group)
                                        ? group.color
                                        : Colors.transparent,
                                    width: 0.40,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    buildGroupThumbnail(group,themeProvider),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 9,
                                              width: 9,
                                              decoration:
                                                  BoxDecoration(
                                                shape:
                                                    BoxShape.circle,
                                                color: group.color,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 6),
                                            Text(
                                              group.name,
                                              style:
                                                  const TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height: 2),
                                        Text(
                                          "${group.tabs.length} ${loc.tabs}",
                                          style:
                                              const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ):SizedBox(),





              // ...availableGroups.map((group) {
              //         return 
              //         Padding(
              //           padding: const EdgeInsets.symmetric(vertical:8.0),
              //           child: GlassGroupPanel(
              //             color: group.color,
              //             child: Container(
              //                height: 90,
                             
              //                  padding: const EdgeInsets.all(10),
              //                  decoration: BoxDecoration(
              //                    color:Colors.transparent, //group.color,
              //                    border: Border.all(color: provider.groupContainsCurrentTab(group) ? group.color : Colors.transparent ,width: 0.40),
              //                   // borderRadius: BorderRadius.circular(12),
              //                  ),
              //                  child: Row(
              //                   children: [
              //                     buildGroupThumbnail(group),
              //                     const SizedBox(width: 12),
                                           
              //                    Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Row(
              //                 children: [
              //                   Container(
              //                     height: 9,width: 9,
              //                     decoration: BoxDecoration(shape: BoxShape.circle,color: group.color),
              //                   ),
              //                   Text(
              //                     group.name,
              //                     style: const TextStyle(
              //                       fontSize: 12,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 2),
              //               Text(
              //                 "${group.tabs.length} tabs",
              //                 style: const TextStyle(fontSize: 14),
              //               ),
              //             ],
              //           )
              //                   ],
              //                  ),
              //             ),
              //           ),
              //         );
              //         // ListTile(
              
              //         //   leading: CircleAvatar(
              //         //     backgroundColor:
              //         //         group.color,
              //         //   ),
              
              //         //   title: Text(
              //         //     group.name,
              //         //   ),
              
              //         //   subtitle: Text(
              //         //     "${group.tabs.length} tabs",
              //         //   ),
              
              //         //   onTap: () {
              
              //         //     Navigator.pop(
              //         //       context,
              //         //     );
              
              //         //     provider
              //         //         .addSelectedTabsToGroup(
              //         //       group,
              //         //     );
              
              //         //     provider
              //         //         .disableSelectionMode();
              //         //   },
              //         // );
              //       },
              //     ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showCreateGroupDialog(
  BuildContext context,AppLocalizations loc
) {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );

final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
  final controller =
      TextEditingController(text:  "New group" );

  final FocusNode focusNode = FocusNode();

  final colors = [
    Color(0xffEBEBEB),
    Color(0xff4ED971),
    Color(0xff4EAFFF),
    Color(0xffBB70F9),
    Color(0xffFF8383),
    Color(0xffE3AD2F),
  ];

Color selectedColor = Color(0xffEBEBEB);

  showDialog(

    context: context,
    barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8) ,
    builder: (_) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
  focusNode.requestFocus();

  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );
});
      return StatefulBuilder(

        builder: (
          context,
          setState,
        ) {

          return Dialog(
             insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,

                        child: GlassCommonPanel(
                          child: Container(
                            margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                            child: Column(
                            
                                          mainAxisSize:
                                              MainAxisSize.min,
                            
                                          children: [
                            SizedBox(
                       child: Text(loc.newTabGroup.toUpperCase(),style: TextStyle(fontFamily: 'Conthrax',fontSize: 14),),
                    ),
                   const SizedBox(height: 8,),
                  Text(loc.groupName,style: TextStyle(color: Color(0xff8D8D8D)),),
                 const SizedBox(height: 8,),
                                            Container(
                                              height: 50,decoration: BoxDecoration(
                    border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),
                    color:themeProvider.darkTheme ? Colors.black26 : Color(0xffffffff)),
                                              child: TextField(
                                                                          
                                                controller:
                                                    controller,
                                                                          
                                              style:  TextStyle(fontSize: 12, fontFamily:"Roboto"),  
                        
                        decoration:
                             InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 5),
                              hintStyle: TextStyle(fontFamily: 'Roboto',fontSize: 12,color:themeProvider.darkTheme ? Color(0xff737373): Color(0xffACACAC)),
                          hintText:
                              "Group Name",border: InputBorder.none,
                         // border: 
                             // OutlineInputBorder(),
                        ),
                                              ),
                                            ),
                            
                                           const SizedBox(
                      height: 14,
                    ),
                     Text(loc.groupColor,style: TextStyle(color: Color(0xff8D8D8D)),),
                     const SizedBox(
                      height: 14,
                    ),
                                          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                     spacing: 6,
                
                      children:
                          colors.map(
                        (color) {
                          print('Selected color is $selectedColor');
                         final selected =
                  selectedColor.toARGB32() == color.toARGB32();
                          // final selected =
                          //     selectedColor ==
                          //         color;
                
                          return GestureDetector(
                
                            onTap: () {
                
                              setState(() {
                                selectedColor =
                                    color;
                              });
                            },
                
                            child:
                                AnimatedContainer(
                
                              duration:
                                  const Duration(
                                milliseconds:
                                    100,
                              ),
                
                              width:32,
                              //  selected
                              //     ? 42
                              //     : 36,
                
                              height: 32,
                              // selected
                              //     ? 42
                              //     : 36,
                
                              decoration:
                                  BoxDecoration(
                                color: color,
                                shape:
                                   selected ? BoxShape
                                        .circle : BoxShape.rectangle,
                                  //border:Border.all(color: selected),
                
                                border:
                                    Border.all(
                                  color: selected
                                      ? Colors.green
                                      : Colors
                                          .transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),

const SizedBox(height: 14,),
                    GestureDetector(
                      onTap: ()async {
                        if(controller.text.trim().isNotEmpty){
                        provider
                      .createGroupFromSelectedTabs(

                    name:
                        controller.text
                                .trim()
                                .isEmpty
                            ? "New Group"
                            : controller.text
                                .trim(),

                    color:
                        selectedColor,
                  );

                  provider
                      .disableSelectionMode();

                  Navigator.pop(
                    context,
                  );
                        
                 Navigator.pop(context);

                        }
                              

                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)
                        ),
                        child: Center(child: Text(loc.create,style: TextStyle(color:themeProvider.darkTheme ? Colors.black : Colors.white,fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
                      ),
                    ),
                     const SizedBox(height: 14,),
                    GestureDetector(
                      onTap: ()=> Navigator.pop(context),
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Center(child: Text(loc.cancel,style: TextStyle(color: Color(0xffACACAC),fontSize: 18,fontFamily: 'Inter',fontWeight: FontWeight.w600),)),
                      ),
                    )

                                          ],
                                        ),
                          ),
                        ),

            // actions: [

            //   TextButton(

            //     onPressed: () {

            //       Navigator.pop(
            //         context,
            //       );
            //     },

            //     child: const Text(
            //       "Cancel",
            //     ),
            //   ),

            //   ElevatedButton(

            //     onPressed: () {

            //       provider
            //           .createGroupFromSelectedTabs(

            //         name:
            //             controller.text
            //                     .trim()
            //                     .isEmpty
            //                 ? "New Group"
            //                 : controller.text
            //                     .trim(),

            //         color:
            //             selectedColor,
            //       );

            //       provider
            //           .disableSelectionMode();

            //       Navigator.pop(
            //         context,
            //       );
            //     },

            //     child: const Text(
            //       "Create",
            //     ),
            //   ),
            // ],
          );
        },
      );
    },
  );
}