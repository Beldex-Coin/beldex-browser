import 'dart:typed_data';

//import 'package:beldex_browser/src/browser/ai/view_models/folder_system/group_provider.dart';
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/l10n/generated/app_localizations_af.dart';
import 'package:beldex_browser/src/browser/custom_popup_menu_item.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/bottom_nav_bar_provider.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';



import 'package:provider/provider.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => GroupProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<GroupProvider>(context);

    final widgets =
        provider.getHomeWidgets();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Provider Group Demo"),
        actions: [
          PopupMenuButton<String>(

  onSelected: (value) {

    if (value == "create_group") {

      showCreateEmptyGroupDialog(
        context,
      );
    }

    if(value == "select_tabs"){
        provider.enableSelectionMode();
    }
  },

  itemBuilder: (context) => [

    PopupMenuItem<String>(

      value: "create_group",

      child: Row(
        children: const [

          Icon(Icons.folder),

          SizedBox(width: 10),

          Text(
            "Create New Tab Group",
          ),
        ],
      ),
    ),
  ],
)
        ],
      ),

      body: Column(
        children: [

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              ElevatedButton(
                onPressed: () {
                  provider.changeViewMode(
                    ViewMode.all,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      provider.currentMode ==
                              ViewMode.all
                          ? Colors.blue
                          : Colors.grey,
                ),

                child: const Text(
                  "All Items",
                ),
              ),

              const SizedBox(width: 16),

              ElevatedButton(
                onPressed: () {
                  provider.changeViewMode(
                    ViewMode.groupsOnly,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      provider.currentMode ==
                              ViewMode.groupsOnly
                          ? Colors.green
                          : Colors.grey,
                ),

                child: const Text(
                  "Groups Only",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: provider.currentMode == ViewMode.groupsOnly

        ? ListView.separated(
            itemCount: widgets.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (_, index) {
              print('GROUPS ONLY IN LIST VIEW');
              return widgets[index];
            },
          )

        :    GridView.builder(
                itemCount: widgets.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),

                itemBuilder: (_, index) {
                  return widgets[index];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider =
//         Provider.of<GroupProvider>(context);

//     final widgets = [
//       ...provider.outsideItems.map(
//         (e) => ItemWidget(item: e),
//       ),
//       ...provider.groups.map(
//         (e) => GroupWidget(group: e),
//       ),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Provider Group Demo"),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           itemCount: widgets.length,
//           gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           ),
//           itemBuilder: (_, index) {
//             return widgets[index];
//           },
//         ),
//       ),
//     );
//   }
// }

class ItemWidget extends StatelessWidget {

  final WebViewModel tab;

  const ItemWidget({
    super.key,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    final browserProvider =
    Provider.of<BrowserModel>(
  context,
  listen: false,
);

    final provider =
        Provider.of<GroupProvider>(
      context,
      listen: false,
    );

   final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

    final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context,listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        return LongPressDraggable<WebViewModel>(
        
          data: tab,
        
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: constraints.maxWidth,
          height: constraints.maxHeight,
              child: buildBox(
                
                 title: tab.title ?? "Tab",//siteLogo: tab.favicon, 
                 color: Colors.blue,screenshot: tab.screenshot,onClose: (){}, onTap: () {  }, selectionMode: false, isSelected: false, onSelect: () {  }, isCurrentTab: provider.isCurrentTab(tab),themeProvider: themeProvider
              ),
            ),
          ),
        
          childWhenDragging: Opacity(
            opacity: 0.2,
            child: SizedBox(
               width: constraints.maxWidth,
          height: constraints.maxHeight,
              child: buildBox(
                title: tab.title ?? "Tab",//siteLogo:tab.favicon , 
                screenshot: tab.screenshot,onClose: (){} ,color: Colors.grey,onTap: () {  }, selectionMode: false, isSelected: false, onSelect: () {  }, isCurrentTab: provider.isCurrentTab(tab),themeProvider: themeProvider
              ),
            ),
          ),
        
          child: DragTarget<WebViewModel>(
        
            onWillAccept: (incoming) {
        
              return incoming != null &&
                  incoming.hashCode !=
                      tab.hashCode;
            },
        
            onAccept: (incoming) {
        
              // provider.createGroup(
              //   tab,
              //   incoming,
              // );
        
              showCreateGroupDialog(
          context: context,
          first: tab,
          second: incoming,
        );
            },
        
            builder: (
              context,
              candidateData,
              rejectedData,
            ) {
        
              return GestureDetector(
        
          onTap: () {
        
         if(provider.selectionMode){
          
        provider.toggleTabSelection(
          tab,
        );
        return;
         }
        
        final index =
            browserProvider.webViewTabs
                .indexWhere(
          (e) =>
              e.webViewModel.uuid ==
              tab.uuid,
        );
        
        if (index != -1) {
          bottomNavigationProvider.changeView(HomeView.home);
          browserProvider.showTabScroller = false;
        
          browserProvider.showTab(
            index,
          );
          
        }
          },
        
          child: buildBox(
        
        title: tab.title ?? "Tab",//siteLogo: tab.favicon, 
        screenshot: tab.screenshot, onClose: () { provider.closeSingleTab(context, tab); }, color: Colors.transparent, onTap: () {  }, selectionMode: provider.selectionMode, isSelected: provider.isSelected(tab), onSelect: () {
          //  provider.toggleTabSelection(tab);
         }, isCurrentTab: provider.isCurrentTab(tab),
         themeProvider: themeProvider
          ),
        );
            },
          ),
        );
      }
    );
  }
}

class GroupWidget extends StatelessWidget {

  final GroupModel group;

  const GroupWidget({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<GroupProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    final loc = AppLocalizations.of(context)!;

 if(provider.currentMode ==
          ViewMode.groupsOnly){
               return GestureDetector(
                onTap: (){
                   provider.reOpenCloseGroup(group);

                 
  showGeneralDialog(

    context: context,

    barrierDismissible: true,

    barrierLabel: "Group",

    barrierColor:
        Colors.black.withOpacity(0.5),

    transitionDuration:
        const Duration(
      milliseconds: 250,
    ),

    pageBuilder:
        (_, __, ___) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.changeViewMode(ViewMode.all);
    });
    
      return Center(

        child: Material(

          color: Colors.transparent,

          child: Container(

            width:
                MediaQuery.of(context)
                        .size
                        .width *
                    0.9,

            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.75,

            decoration: BoxDecoration(
              color:Color(0xff111111) ,//Colors.white,
              border: Border.all(color: Color(0xff444444),)
              // borderRadius:
              //     BorderRadius.circular(
              //   24,
              // ),
            ),

            child: GroupScreen(
              group: group,
            ),
          ),
        ),
      );
    },

    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {

      return Transform.scale(

        scale: Curves.easeOutBack
            .transform(
          animation.value,
        ),

        child: Opacity(
          opacity: animation.value,
          child: child,
        ),
      );
    },
  );
                },
                 child: GlassGroupPanel(
                  color: group.color,
                   child: Container(
                         height: 90,
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color:Colors.transparent, //group.color,
                           border: Border.all(color: provider.groupContainsCurrentTab(group) ? group.color : Colors.transparent ,width: 0.40),
                          // borderRadius: BorderRadius.circular(12),
                         ),
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Row(
                               children: [
                                                buildGroupThumbnail(group,themeProvider),
                                // const Icon(Icons.folder),
                                                
                                 const SizedBox(width: 12),
                                                
                                 Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Row(
                                   children: [
                                     Container(
                                       height: 9,width: 9,
                                       decoration: BoxDecoration(shape: BoxShape.circle,color: group.color),
                                     ),
                                     SizedBox(width: 10,),
                                     Text(
                                       group.name,
                                       style: const TextStyle(
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ],
                                 ),
                                 const SizedBox(height: 2),
                                 Text(
                                   "${group.tabs.length} ${loc.tabs}",
                                   style: const TextStyle(fontSize: 14),
                                 ),
                               ],
                             ),
                                                
                                 
                               ],
                             ),
                             GestureDetector(
                              onTap: (){
                                confirmDeleteGroup(
              context,
              group,loc
            );
                              },
                               child: GlassPanel(
                                 child: Container(
                                  height: 30,width: 30,
                                  padding: EdgeInsets.all(5),
                                  child: SvgPicture.asset('assets/images/ai-icons/new/Delete Tab Group.svg',color: themeProvider.darkTheme ? Color(0xff8D8D8D) : Color(0xff737373),),
                                 ),
                               ),
                             )
                           ],
                         ),
                       ),
                 ),
               );
          } 
           
 return LayoutBuilder(
   builder: (context, constraints) {
     return LongPressDraggable<GroupModel>(
     
      data: group,
     
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          // width: 250,
          // height: 250,
           width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Opacity(
            opacity: 0.8,
            child: _buildGroupTarget(
              context,group,
              provider,themeProvider,loc
            ),
          ),
        ),
      ),
     
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: SizedBox(
           width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: _buildGroupTarget(
            context,group,
            provider,themeProvider,loc
          ),
        ),
      ),
     
      child: SizedBox(
         width: constraints.maxWidth,
          height: constraints.maxHeight,
        child: _buildGroupTarget(
          context,group,
          provider,themeProvider,loc
        ),
      ),
     );
   }
 );


  }
}



Widget buildGroupThumbnail(GroupModel group,DarkThemeProvider themeProvider){
  return SizedBox(
    width: 56,
    height: 56,
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 4,
      itemBuilder: (_, index) {
        final hasTab = index < group.tabs.length;

        if (!hasTab) {
          return Container(
            color:themeProvider.darkTheme ? Colors.black.withOpacity(0.7): Color(0xffffffff),
          );
        }

        final tab = group.tabs[index];

        return Container(
          color: themeProvider.darkTheme ? Colors.black.withOpacity(0.7): Color(0xffffffff),
          child: tab.screenshot != null
              ? Image.memory(
                  tab.screenshot!,
                  fit: BoxFit.cover,
                )
              :  Center(
                  child: SvgPicture.asset('assets/images/ai-icons/new/Default_Image.svg',color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4),height: 20,)
                  // Icon(
                  //   Icons.language,
                  //   size: 12,
                  //   color: Colors.white54,
                  // ),
                ),
        );
      },
    ),
  );
}
// will display the boxes according to the count  of the tabs in the group
// Widget buildGroupThumbnail(GroupModel group) {
//   final tabs = group.tabs;

//   if (tabs.isEmpty) {
//     return Container(
//       width: 56,
//       height: 56,
//       color: Colors.black.withOpacity(0.5),
//     );
//   }

//   return SizedBox(
//     width: 56,
//     height: 56,
//     child: GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.zero,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 2,
//         mainAxisSpacing: 2,
//       ),
//       itemCount: tabs.length >= 4 ? 4 : tabs.length,
//       itemBuilder: (_, index) {
//         final tab = tabs[index];

//         return Container(
//           color: Colors.black.withOpacity(0.6),
//           child: tab.screenshot != null
//               ? Image.memory(
//                   tab.screenshot!,
//                   fit: BoxFit.cover,
//                 )
//               : const SizedBox(),
//         );
//       },
//     ),
//   );
// }

Widget _buildGroupTarget(BuildContext context,GroupModel group, GroupProvider provider,DarkThemeProvider themeProvider ,AppLocalizations loc){
 return DragTarget<Object>( //<WebViewModel>(

      onWillAccept: (data) {
        
        if(data is GroupModel){
           return data.id != group.id;
        }

        return true;
      },

      onAccept: (data) {

     if(data is WebViewModel){
        provider.addToGroup(
          data,
          group,
        );
     }
     if(data is GroupModel){
      provider.mergeGroups(
      sourceGroup: data,
      targetGroup: group,
    );
     }
        
      },

      builder: (
        context,
        candidateData,
        rejectedData,
      ) {

        return GestureDetector(

          onTap: () {
            provider.reOpenCloseGroup(group);

  showGeneralDialog(

    context: context,

    barrierDismissible: true,

    barrierLabel: "Group",

    barrierColor:
       themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8) ,

    transitionDuration:
        const Duration(
      milliseconds: 250,
    ),

    pageBuilder:
        (_, __, ___) {


      return Center(

        child: Material(

          color: Colors.transparent,

          child: Container(

            width:
                MediaQuery.of(context)
                        .size
                        .width *
                    0.9,

            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.75,

            decoration: BoxDecoration(
              color: Colors.transparent,
              // borderRadius:
              //     BorderRadius.circular(
              //   24,
              // ),
            ),

            child: GlassCommonPanel(
              child: GroupScreen(
                group: group,
              ),
            ),
          ),
        ),
      );
    },

    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {

      return Transform.scale(

        scale: Curves.easeOutBack
            .transform(
          animation.value,
        ),

        child: Opacity(
          opacity: animation.value,
          child: child,
        ),
      );
    },
  );

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) =>
            //         GroupScreen(
            //       group: group,
            //     ),
            //   ),
            // );
          },

          child: GlassGroupPanel(
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
            
                boxShadow:
                    candidateData.isNotEmpty
                        ? [
                            BoxShadow(
                              color: Colors.green
                                  .withOpacity(
                                0.5,
                              ),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ]
                        : [],
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
                      const TextStyle(
                        fontFamily: 'Inter',
                    //color: Colors.white,
                    // fontWeight:
                    //     FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            
              Container(
            
                // width: 24,
                // height: 24,
            
                // alignment:
                //     Alignment.center,
            
                // decoration:
                //     BoxDecoration(
                //   shape: BoxShape.circle,
                //   border: Border.all(
                //     color: Colors.white,
                //     width: 2,
                //   ),
                // ),
            
                child:
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
            
              onSelected: (value) {
            
                if (value == "close_group") {
                 print("THE AVALUE IS $value");
                  provider.closeGroup(group);
                
                }
                if(value == "rename_group"){
                  showEditGroupDialog(context:context , group: group);
                }
                if (value == "delete_group") {
            
                 confirmDeleteGroup(
              context,
              group,loc
            );
            
            
                  //provider.deleteGroup(group);
                }
                if(value == "ungroup_group"){
                  confirmUngroupAllTabs(context,group,loc);
                }
              },
            
              itemBuilder: (context) => [
                CustomPopupMenuItem<String>(
                  enabled: true,
                  value: "close_group",
                  height: 35,
                  padding: EdgeInsets.zero, //only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                          children: [
                           SvgPicture.asset('assets/images/ai-icons/new/Close All Tabs.svg' ,color: themeProvider.darkTheme
                                                    ?const Color(0xffFFFFFF)
                                                    :const Color(0xff282836)),
                                                    SizedBox(width: 8,),
                            Expanded(
                              child: Text(loc.close, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                            ),
                          ]),
                    ),
                  ),
                ),
                CustomPopupMenuItem<String>(
                  enabled: true,
                  value: "rename_group",
                  height: 35,
                  padding: EdgeInsets.zero,
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                          children: [
                           SvgPicture.asset('assets/images/ai-icons/new/Edit Group Name.svg' ,color: themeProvider.darkTheme
                                                    ?const Color(0xffFFFFFF)
                                                    :const Color(0xff282836)),
                                                    SizedBox(width: 8,),
                            Expanded(
                              child: Text(loc.rename, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                            ),
                          ]),
                    ),
                  ),
                ),
                CustomPopupMenuItem<String>(
                  enabled: true,
                  value: "ungroup_group",
                  height: 35,
                  padding: EdgeInsets.zero,
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      height: 35,
                      child: Row(
                          children: [
                           SvgPicture.asset('assets/images/ai-icons/new/Ungroup Tab.svg' ,color: themeProvider.darkTheme
                                                    ?const Color(0xffFFFFFF)
                                                    :const Color(0xff282836)),
                                                    SizedBox(width: 8,),
                            Expanded(
                              child: Text(loc.ungroupTab, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                            ),
                          ]),
                    ),
                  ),
                ),
                CustomPopupMenuItem<String>(
                  enabled: true,
                  value: "delete_group",
                  height: 35,
                  padding: EdgeInsets.zero,
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                          children: [
                           SvgPicture.asset('assets/images/ai-icons/new/Delete Tab Group.svg' ,color: themeProvider.darkTheme
                                                    ?const Color(0xffFFFFFF)
                                                    :const Color(0xff282836)),
                                                    SizedBox(width: 8,),
                            Expanded(
                              child: Text(loc.deleteGroup, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                            ),
                          ]),
                    ),
                  ),
                ),
                
                
            //     PopupMenuItem<String>(
            
            //       value: "close_group",
            
            //       child: Row(
            //         children: const [
            
            // Icon(Icons.close_fullscreen),
            
            // SizedBox(width: 10),
            
            // Text(
            //   "Close",
            // ),
            //         ],
            //       ),
            //     ),
            //     PopupMenuItem<String>(
            
            //       value: "rename_group",
            
            //       child: Row(
            //         children: const [
            
            // Icon(Icons.edit),
            
            // SizedBox(width: 10),
            
            // Text(
            //   "Rename",
            // ),
            //         ],
            //       ),
            //     ),
            //     PopupMenuItem<String>(
            
            //       value: "ungroup_group",
            
            //       child: Row(
            //         children: const [
            
            // Icon(Icons.swipe_up_alt_sharp),
            
            // SizedBox(width: 10),
            
            // Text(
            //   "Ungroup",
            // ),
            //         ],
            //       ),
            //     ),
            //     PopupMenuItem<String>(
            
            //       value: "delete_group",
            
            //       child: Row(
            //         children: const [
            
            // Icon(Icons.delete),
            
            // SizedBox(width: 10),
            
            // Text(
            //   "Delete",
            // ),
            //         ],
            //       ),
            //     ),
              ],
            )
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
              ),
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
                  color:themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffFFFFFF),
                  child:  Center(
                    child: SvgPicture.asset('assets/images/ai-icons/new/Default_Image.svg',color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4),height: 30,)
                    // Icon(
                    //   Icons.image_outlined,
                    //   color: Colors.white24,
                    //   size: 30,
                    // ),
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
                            style: const TextStyle(
                              color: Colors.white,
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
             
            ),
          ),
        );
      },
    );
}


Future<void> confirmDeleteGroup(
  BuildContext context,
  GroupModel group,AppLocalizations loc
) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

  final result =
      await showDialog<bool>(
barrierColor:  themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8),
    context: context,

    builder: (_) {

      return Dialog(
        insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
       

        child: GlassCommonPanel(
          
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                  GlassGroupPanel(
                    color: Color(0xffFFB4AB),
                       child: Container(
                        height: 46,width: 46,
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/images/ai-icons/new/DeleteTabGroup.svg',)),
                     ),
                     SizedBox(width: 10,),
                     //Spacer(),
                     //SizedBox(width: 10,),
                     Text(loc.deleteTabGroup.toUpperCase()
          ,style: TextStyle(fontFamily: 'Conthrax',fontSize: 14,fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 15,)
                  ],
                ),
                SizedBox(height: 14,),
                Text(
                  '${loc.thisActionWillPermenantClose} ${group.tabs.length > 1 ? "all ${group.tabs.length} tabs" : "tab"} ${loc.inside} "${group.name}". ${loc.thisCannotBeUndone}.',
                  style: TextStyle(
                        fontSize:16,
                        color:themeProvider.darkTheme ? Color(0xffACACAC) : Color(0xff737373)
                  ),
                ),
                const SizedBox(height: 14,),
                    GestureDetector(
                      onTap: (){
                       
              Navigator.pop(
                context,
                true,
              );
                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)
                        ),
                        child: Center(child: Text(loc.deleteGroup,style: TextStyle(color:themeProvider.darkTheme ? Colors.black : Colors.white,fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
                      ),
                    ),

                  const SizedBox(height: 14,),
                    GestureDetector(
                      onTap: (){
                         Navigator.pop(
                context,
                false,
              );
                            
                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Center(child: Text(loc.cancel,style: TextStyle(color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff737373),fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
                      ),
                    ),
              ],
            ),
          ),
        ),

        // actions: [

        //   TextButton(

        //     onPressed: () {
        //       Navigator.pop(
        //         context,
        //         false,
        //       );
        //     },

        //     child: const Text(
        //       "Cancel",
        //     ),
        //   ),

        //   ElevatedButton(

        //     onPressed: () {
        //       Navigator.pop(
        //         context,
        //         true,
        //       );
        //     },

        //     child: const Text(
        //       "Delete",
        //     ),
        //   ),
        // ],
      );
    },
  );

  if (result == true) {

   await provider.deleteGroupAndTabs(
      context,
      group,
    );

   // Navigator.pop(context);
  }
}


Future<void> confirmDeleteGroupScreen(
  BuildContext context,
  GroupModel group,AppLocalizations loc
) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

  final result =
      await showDialog<bool>(
barrierColor:  themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8),
    context: context,

    builder: (_) {

      return Dialog(
        insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
       

        child: GlassCommonPanel(
          
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                  GlassGroupPanel(
                    color: Color(0xffFFB4AB),
                       child: Container(
                        height: 46,width: 46,
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/images/ai-icons/new/DeleteTabGroup.svg',)),
                     ),
                     SizedBox(width: 10,),
                     //Spacer(),
                     //SizedBox(width: 10,),
                     Text(loc.deleteTabGroup.toUpperCase()
          ,style: TextStyle(fontFamily: 'Conthrax',fontSize: 14,fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 15,)
                  ],
                ),
                SizedBox(height: 14,),
                Text(
                  '${loc.thisActionWillPermenantClose} ${group.tabs.length > 1 ? "all ${group.tabs.length} tabs" : "tab"} ${loc.inside} "${group.name}". ${loc.thisCannotBeUndone}.',
                  style: TextStyle(
                        fontSize:16,
                        color:themeProvider.darkTheme ? Color(0xffACACAC) : Color(0xff737373)
                  ),
                ),
                const SizedBox(height: 14,),
                    GestureDetector(
                      onTap: (){
                       
              Navigator.pop(
                context,
                true,
              );
                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)
                        ),
                        child: Center(child: Text(loc.deleteGroup,style: TextStyle(color:themeProvider.darkTheme ? Colors.black : Colors.white,fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
                      ),
                    ),

                  const SizedBox(height: 14,),
                    GestureDetector(
                      onTap: (){
                         Navigator.pop(
                context,
                false,
              );
                            
                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Center(child: Text(loc.cancel,style: TextStyle(color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff737373),fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (result == true) {

   await provider.deleteGroupAndTabs(
      context,
      group,
    );
    Navigator.pop(context);
  }
}


Future<void> confirmUngroupAllTabs(
  BuildContext context,
  GroupModel group,AppLocalizations loc
) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

  final result =
      await showDialog<bool>(
 barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8) ,
    context: context,

    builder: (_) {

      return Dialog(
        insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
        // title: const Text(
        //   "Ungroup tab Group?",
        // ),

        child: GlassSettingPanel(
           color:themeProvider.darkTheme ? const Color(0xFF222222).withOpacity(0.5) : const Color(0xffFFFFFF).withOpacity(0.7),
            border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),

          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     GlassCommonPanel(
                       child: Container(
                        height: 46,width: 46,
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/images/ai-icons/new/Ungroup Tab.svg',color: themeProvider.darkTheme ? Color(0xffffffff) : Color(0xff737373),)),
                     ),
                     //Spacer(),
                     SizedBox(width: 10,),
                     Text(loc.ungroupTabGroup.toUpperCase()
          ,style: TextStyle(fontFamily: 'Conthrax',fontSize: 14,fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 15,)
                  ],
                ),
                SizedBox(height: 14,),
                Text(loc.doYouWantToUngroup
                  ,textAlign: TextAlign.justify, style: TextStyle(fontSize:16,color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff737373), fontFamily: 'Roboto'),
                ),
SizedBox(height: 14,),
                 GestureDetector(
                      onTap: (){
                       
                               Navigator.pop(
                context,
                true,
              );     

                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)
                        ),
                        child: Center(child: Text(loc.ungroup,style: TextStyle(color:themeProvider.darkTheme ? Colors.black : Colors.white,fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
                      ),
                    ),
                    SizedBox(height: 14,),
                    GestureDetector(
                      onTap: (){
                       
                               Navigator.pop(
                context,
                false,
              );     

                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Center(child: Text(loc.cancel,style: TextStyle(color: Color(0xffACACAC),fontSize: 18,fontWeight: FontWeight.w600),)),
                      ),
                    ),
                    //       Navigator.pop(
        //         context,
        //         true,
        //       );
              ],
            ),
          ),
        ),

        // actions: [

        //   TextButton(

        //     onPressed: () {
        //       Navigator.pop(
        //         context,
        //         false,
        //       );
        //     },

        //     child: const Text(
        //       "Cancel",
        //     ),
        //   ),

        //   ElevatedButton(

        //     onPressed: () {
        //       Navigator.pop(
        //         context,
        //         true,
        //       );
        //     },

        //     child: const Text(
        //       "Delete",
        //     ),
        //   ),
        // ],
      );
    },
  );

  if (result == true) {

    provider.ungroupAllTabs(
      group,
    );

   // Navigator.pop(context);
  }
}


class GroupScreen extends StatefulWidget {

  final GroupModel group;

  const GroupScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupScreen> createState() =>
      _GroupScreenState();
}

class _GroupScreenState
    extends State<GroupScreen> {


      final TextEditingController _groupNameController =
    TextEditingController();

    final FocusNode _groupNameFocusNode = FocusNode();

 final colors = [
    Color(0xffEBEBEB),
    Color(0xff4ED971),
    Color(0xff4EAFFF),
    Color(0xffBB70F9),
    Color(0xffFF8383),
    Color(0xffE3AD2F),
  ];

  late Color selectedColor;

  bool isEditColorEnabled = false;

    @override
void initState() {
  super.initState();

  _groupNameController.text = widget.group.name;
 
 final groupProvider =
        Provider.of<GroupProvider>(
      context,
      listen: false,
    );

   _groupNameFocusNode.addListener(() {
    if (!_groupNameFocusNode.hasFocus &&
      groupProvider.groupNameEditMode) {
        groupProvider.disableGroupNameEditMode();
        groupProvider.editGroupname(group: widget.group, name: _groupNameController.text);
      //_saveGroupName();
    }
  });

  

 selectedColor = colors.firstWhere(
  (c) => c.toARGB32() == widget.group.color.toARGB32(),
  orElse: () => colors.first,
);



  
}


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final provider =
        Provider.of<GroupProvider>(
      context,
      //listen: false,
    );
    final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    final browserModel =
        Provider.of<BrowserModel>(
      context,
      listen: false,
    );
    final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context); 
    final containsCurrentTab =
    provider.groupContainsCurrentTab(
      widget.group,
    );

    return WillPopScope(

      onWillPop: () async {

        /// EXIT SELECTION MODE FIRST
        if (provider.selectionMode) {

          setState(() {

            provider.selectionMode = false;

            provider.selectedTabs.clear();
          });

          return false;
        }
        provider.disableGroupNameEditMode();
        return true;
      },

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
           FocusScope.of(context).unfocus();

      if (provider.groupNameEditMode) {
         provider.editGroupname(group: widget.group, name: _groupNameController.text);

       }
        },
        child: Container(
          decoration: BoxDecoration(
             color:themeProvider.darkTheme ? Color(0xff111111) : Color(0xffFFFFFF),
             border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
          ),
          
          child: Column(
            children: [
          
              /// HEADER
              Container(
          
                height: 60,
          
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
          
                decoration: BoxDecoration(
                  color:Colors.transparent, //widget.group.color,
                 // border: Border.all(color: containsCurrentTab ? Colors.green : Colors.transparent,width: 2.0),
                  // borderRadius:
                  //     const BorderRadius.only(
                  //   topLeft:
                  //       Radius.circular(24),
                  //   topRight:
                  //       Radius.circular(24),
                  // ),
                ),
          
                child: Row(
                  children: [
          
                    /// BACK
                    GestureDetector(
          
                      onTap: () {
                       
                        /// EXIT SELECTION MODE
                        if (provider.selectionMode) {
          
                         // setState(() {
          
                            provider.selectionMode =
                                false;
          
                            provider.selectedTabs
                                .clear();
                          //});
          
                          return;
                        }
          
                        Navigator.pop(
                          context,
                        );
                      },
          
                      child: SvgPicture.asset('assets/images/ai-icons/new/back.svg', color: themeProvider.darkTheme ? Colors.white : Colors.black,)
                    ),
          
                    const SizedBox(
                      width: 12,
                    ),
                    
          
                    Container(
                      height: 14,width: 14,
                      decoration: BoxDecoration(color: widget.group.color,shape: BoxShape.circle),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
          
                    Expanded(
                              child: provider.selectionMode
                            ? Text(
                                "${provider.selectedTabs.length} selected",
                                style: TextStyle(
                                  color: themeProvider.darkTheme ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : provider.groupNameEditMode //isEditingGroupName
                                ? TextField(
                                    controller: _groupNameController,
                                    focusNode: _groupNameFocusNode,
                                    autofocus: true,
                                    style: TextStyle(
                    color:themeProvider.darkTheme ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                                    ),
                                    //cursorColor: Colors.white,
                                    decoration: InputDecoration(
                    isDense: true,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: themeProvider.darkTheme ? Color(0xff737373) : Color(0xffD4D4D4),
                        width: 1,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                       color:  themeProvider.darkTheme ? Color(0xff737373) : Color(0xffD4D4D4),
                        //color: Colors.blue,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:themeProvider.darkTheme ? Color(0xff737373) : Color(0xffD4D4D4),
                        width: 1,
                      ),
                    ),
                                    ),
                                    onSubmitted: (value) {
                    setState(() {});
                      widget.group.name = value.trim().isEmpty
                          ? widget.group.name
                          : value.trim();
                       provider.editGroupname(group: widget.group, name:value.trim().isEmpty
                          ? widget.group.name
                          : value.trim());
                      provider.disableGroupNameEditMode();
                     // isEditingGroupName = false;
                    
                            
                                     // provider.notifyListeners();
                                    },
                                  )
                                : GestureDetector(
                                   behavior: HitTestBehavior.opaque,
            onTap: () {
              print("On Tap for Group name edit ");
               provider.enableGroupNameEditMode();
          
              // _groupNameController.text =
              //     widget.group.name;
          
              // Future.delayed(
              //   const Duration(milliseconds: 50),
              //   () {
              //     _groupNameFocusNode.requestFocus();
          
              //     _groupNameController.selection =
              //         TextSelection(
              //       baseOffset: 0,
              //       extentOffset:
              //           _groupNameController.text.length,
              //     );
              //   },
              // );
              },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: themeProvider.darkTheme ? Color(0xff737373) : Color(0xffD4D4D4),width: 1))
                                    ),
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                        widget.group.name,
                                        style: TextStyle(
                                                      color:themeProvider.darkTheme ?Colors.white : Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ),
                                ),
                            ),
          
                    /// ADD TAB
                    if (!provider.selectionMode)
          
                      GestureDetector(
          
                        onTap: () {
          
                          Navigator.pop(
                            context,
                          );
                          bottomNavigationProvider.changeView(HomeView.home);
                          browserModel
                                  .showTabScroller =
                              false;
          
                          provider
                              .addNewTabToGroup(
                            widget.group,
                          );
                        },
          
                        child: Icon(Icons.add)
                      ),
          
                    const SizedBox(
                      width: 14,
                    ),
          
                    /// MENU
                    PopupMenuButton<String>(
                     menuPadding: EdgeInsets.symmetric(vertical: 8),
                           color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
                 // color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
          constraints: BoxConstraints(
                    maxWidth: 220,
                   ),
                icon: SvgPicture.asset('assets/images/ai-icons/new/vert_menu.svg',color:themeProvider.darkTheme ? Colors.white : Colors.black),// Icon(Icons.more_horiz,
                    //color: themeProvider.darkTheme ? Colors.white : Colors.black),
          //onSelected: _popupMenuChoiceAction,
          offset: Offset(0, 47),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color:themeProvider.darkTheme ? Color(0xff333333) :  Color(0xffD4D4D4), //.withOpacity(0.2),
                width: 1,
              ),
            ),
                      onSelected:
                          (value) async {
          
                        /// ENABLE SELECTION
                        if (value ==
                            "select_tabs") {
          
                          setState(() {
          
                            provider.selectionMode =
                                true;
                          });
                        }
          
                        /// SELECT ALL
                        else if (value ==
                            "select_all") {
          
                          setState(() {
          
                            if (provider.selectedTabs
                                    .length ==
                                widget
                                    .group
                                    .tabs
                                    .length) {
          
                              provider.selectedTabs
                                  .clear();
          
                            } else {
          
                              provider.selectedTabs
                                  .clear();
          
                              provider.selectedTabs
                                  .addAll(
                                widget
                                    .group
                                    .tabs,
                              );
                            }
                          });
                        }
          
                        /// CLOSE SELECTED
                        else if (value ==
                            "close_tabs") {
                              provider.closeSelectedTabs(context);
          
                        //   for (final tab
                        //       in provider.selectedTabs) {
          
                        //     provider
                        //         .removeFromGroup(
                        //       tab,
                        //       widget.group,
                        //     );
                        //   }
          
                        //  // setState(() {
          
                        //     provider.selectedTabs
                        //         .clear();
          
                        //     provider.selectionMode =
                        //         false;
                        //   //});
          
                        //   /// AUTO CLOSE IF EMPTY
                        //   if (widget.group.tabs
                        //       .isEmpty) {
          
                        //     Navigator.pop(
                        //       context,
                        //     );
                        //   }
                        }
                        
                        /// CREATE GROUP
                        else if (value ==
                            "create_group") {
          
                          showCreateEmptyGroupDialog(
                            context,
                          );
                        }
                         else if( value == "edit_group_name"){
                          
                         }
                        /// EDIT GROUP COLOR
                        else if (value ==
                            "edit_group_color") {
          
                              setState(() {
                                isEditColorEnabled = !isEditColorEnabled;
                              });
          
                          // showEditGroupColorDialog(
          
                          //   context: context,
          
                          //   group:
                          //       widget.group,
                          // );
                        }
          
                        /// CLOSE GROUP
                        else if (value ==
                            "close_group") {
          
                          Navigator.pop(
                            context,
                          );
          
                          provider.closeGroup(
                            widget.group,
                          );
                        }
          
                        /// DELETE GROUP
                        else if (value ==
                            "delete_group") {
                          
                          confirmDeleteGroupScreen(context,widget.group,loc);
                          // Navigator.pop(
                          //   context,
                          // );
          
                          // provider
                          //     .deleteGroupAndTabs(context,
                          //   widget.group,
                          // );
                        }
          
                        if(value == "ungroup_selected_tabs"){
                          print('UNGROUP is clicked in this popup');
                            if (provider.selectedTabs.isEmpty) {
                                 return;
                             }
                             print('UNGROUP is clicked in this popup 1');
                             
                             confirmUngroupSelectedTabs(context,widget.group,loc);
                         
                        }
                        if(value == "edit_group_name"){
                          if(provider.groupNameEditMode){
                            provider.disableGroupNameEditMode();
                          }else{
                           provider.enableGroupNameEditMode();
          
                          }
                          
                        }
          
                      },
          
                      itemBuilder: (_) => [
          
                        /// NORMAL MODE
                        if (!provider.selectionMode)
                          CustomPopupMenuItem<String>(
                    enabled: true,
                    value:"select_tabs",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Selecttabs.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(loc.selectTabs, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
                          // const PopupMenuItem(
          
                          //   value:
                          //       "select_tabs",
          
                          //   child: Row(
                          //     children: [
          
                          //       Icon(
                          //         Icons
                          //             .select_all,
                          //       ),
          
                          //       SizedBox(
                          //         width: 10,
                          //       ),
          
                          //       Text(
                          //         "Select tabs",
                          //       ),
                          //     ],
                          //   ),
                          // ),
          
                        /// SELECTION MODE
                        if (provider.selectionMode)
                           
                              CustomPopupMenuItem<String>(
                    enabled: true,
                    value:"select_all",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                            provider.selectedTabs
                                              .length ==
                                          widget
                                              .group
                                              .tabs
                                              .length
          
                                      ? SvgPicture.asset('assets/images/ai-icons/new/Deselect_all.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836))
                                      : SvgPicture.asset('assets/images/ai-icons/new/Selecttabs.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(provider.selectedTabs
                                              .length ==
                                          widget
                                              .group
                                              .tabs
                                              .length
          
                                      ? "${loc.deselectAll}"
          
                                      : "${loc.selectAll}", style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
                           
          
                          // PopupMenuItem(
          
                          //   value:
                          //       "select_all",
          
                          //   child: Row(
                          //     children: [
          
                          //       Icon(
          
                          //         provider.selectedTabs
                          //                     .length ==
                          //                 widget
                          //                     .group
                          //                     .tabs
                          //                     .length
          
                          //             ? Icons
                          //                 .deselect
          
                          //             : Icons
                          //                 .select_all,
                          //       ),
          
                          //       const SizedBox(
                          //         width: 10,
                          //       ),
          
                          //       Text(
          
                          //         provider.selectedTabs
                          //                     .length ==
                          //                 widget
                          //                     .group
                          //                     .tabs
                          //                     .length
          
                          //             ? "Deselect all"
          
                          //             : "Select all",
                          //       ),
                          //     ],
                          //   ),
                          // ),
          
                        if (provider.selectionMode)
                           
                        CustomPopupMenuItem<String>(
                    enabled: provider.selectedTabs.isNotEmpty,
                    value:"close_tabs",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Close All Tabs.svg' ,color:provider.selectedTabs.isEmpty ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) :Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(provider.selectedTabs.length <= 1
          
                ? "${loc.closeTab}"
          
                : "${loc.closeTabs}", style:TextStyle(fontSize: 14,fontFamily: 'Inter',color:provider.selectedTabs.isEmpty ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) :Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
          
          
          //                 PopupMenuItem(
          
          //   enabled:
          // provider.selectedTabs.isNotEmpty,
          
          //   value: "close_tabs",
          
          //   child: Row(
          //     children: [
          
          // Icon(
          
          //   Icons.close,
          
          //   color:
          //       provider.selectedTabs.isNotEmpty
          
          //           ? null
          
          //           : Colors.grey,
          // ),
          
          // const SizedBox(width: 10),
          
          // Text(
          
          //   provider.selectedTabs.length <= 1
          
          //       ? "Close tab"
          
          //       : "Close tabs",
          
          //   style: TextStyle(
          
          //     color:
          //         provider.selectedTabs.isNotEmpty
          
          //             ? null
          
          //             : Colors.grey,
          //   ),
          // ),
          //     ],
          //   ),
          // ),
                      if (provider.selectionMode)
          
          
                      CustomPopupMenuItem<String>(
                    enabled: provider.selectedTabs.isNotEmpty,
                    value:"ungroup_selected_tabs",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Ungroup Tab.svg' ,color:provider.selectedTabs.isEmpty ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) :Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(provider.selectedTabs.length <= 1
          
                ? "${loc.ungroupTab}"
          
                : "Ungroup tabs", style:TextStyle(fontSize: 14,fontFamily: 'Inter',color:provider.selectedTabs.isEmpty ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) :Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
          
          //                 PopupMenuItem(
          
          //   enabled:
          // provider.selectedTabs.isNotEmpty,
          
          //   value: "ungroup_selected_tabs",
          
          //   child: Row(
          //     children: [
          
          // Icon(
          
          //   Icons.close,
          
          //   color:
          //       provider.selectedTabs.isNotEmpty
          
          //           ? null
          
          //           : Colors.grey,
          // ),
          
          // const SizedBox(width: 10),
          
          // Text(
          
          //   provider.selectedTabs.length <= 1
          
          //       ? "Ungroup tab"
          
          //       : "Ungroup tabs",
          
          //   style: TextStyle(
          
          //     color:
          //         provider.selectedTabs.isNotEmpty
          
          //             ? null
          
          //             : Colors.grey,
          //   ),
          // ),
          //     ],
          //   ),
          // ),
                        /// NORMAL OPTIONS
                        if (!provider.selectionMode)
          
          
                        CustomPopupMenuItem<String>(
                    //enabled: provider.selectedTabs.isNotEmpty,
                    value:"edit_group_color",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Edit Group Color.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(loc.editGroupColor, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
          
          
          
          
          
          
          
          
                          // const PopupMenuItem(
          
                          //   value:
                          //       "edit_group_color",
          
                          //   child: Row(
                          //     children: [
          
                          //       Icon(
                          //         Icons.edit,
                          //       ),
          
                          //       SizedBox(
                          //         width: 10,
                          //       ),
          
                          //       Text(
                          //         "Edit group color",
                          //       ),
                          //     ],
                          //   ),
                          // ),
          
                         if (!provider.selectionMode)
                            CustomPopupMenuItem<String>(
                   // enabled: provider.selectedTabs.isNotEmpty,
                    value:"edit_group_name",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Edit Group Name.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(loc.editGroupName, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
                          // const PopupMenuItem(
          
                          //   value:
                          //       "edit_group_name",
          
                          //   child: Row(
                          //     children: [
          
                          //       Icon(
                          //         Icons.edit,
                          //       ),
          
                          //       SizedBox(
                          //         width: 10,
                          //       ),
          
                          //       Text(
                          //         "Edit group name",
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        if (!provider.selectionMode)
                           
          
                                CustomPopupMenuItem<String>(
                    //enabled: provider.selectedTabs.isNotEmpty,
                    value:"close_group",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Close All Tabs.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text("Close group", style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
           
          
                          // const PopupMenuItem(
          
                          //   value:
                          //       "close_group",
          
                          //   child: Row(
                          //     children: [
          
                          //       Icon(
                          //         Icons.close,
                          //       ),
          
                          //       SizedBox(
                          //         width: 10,
                          //       ),
          
                          //       Text(
                          //         "Close group",
                          //       ),
                          //     ],
                          //   ),
                          // ),
          
                        if (!provider.selectionMode)
                          
          
                       
                                CustomPopupMenuItem<String>(
                    //enabled: provider.selectedTabs.isNotEmpty,
                    value:"delete_group",
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                  child: GlassSettingPanel(
                    color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/Delete Tab Group.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(loc.deletetabGroup, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  ),
          
          
                          // const PopupMenuItem(
          
                          //   value:
                          //       "delete_group",
          
                          //   child: Row(
                          //     children: [
          
                          //       Icon(
                          //         Icons.delete,
                          //       ),
          
                          //       SizedBox(
                          //         width: 10,
                          //       ),
          
                          //       Text(
                          //         "Delete group",
                          //       ),
                          //     ],
                          //   ),
                          // ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isEditColorEnabled,
                child: Container(
                  height: 43,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff333333))
                  ),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                    
                                  width:25,
                                  //  selected
                                  //     ? 42
                                  //     : 36,
                    
                                  height: 25,
                                  // selected
                                  //     ? 42
                                  //     : 36,
                    
                                  decoration:
                                      BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                      //  selected ? BoxShape
                                      //       .circle : BoxShape.rectangle,
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
                      GestureDetector(
                        onTap: (){
                           provider.editGroupColor(
          
                      group: widget.group,
                      color:
                          selectedColor,
                    );
                       setState(() {
                         isEditColorEnabled = false;
                       });
          
                
                        },
                        child: Container(
                          child: SvgPicture.asset('assets/images/ai-icons/new/select_color.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black,),
                        ),
                      )
                
                    ],
                  ),
                ),
              ),
              /// BODY
              Expanded(
          
                child: Padding(
          
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
          
                  child: LayoutBuilder(
                    
                    builder: (context, constraints) {
                      return GridView.builder(
                              
                        itemCount:
                            widget.group.tabs.length,
                              
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                              
                          // crossAxisCount: 2,
                              
                          // crossAxisSpacing: 16,
                          // mainAxisSpacing: 16,
                              
                          // childAspectRatio: 0.7,
                        ),
                              
                        itemBuilder: (
                          _,
                          index,
                        ) {
                              
                          final tab =
                              widget.group.tabs[
                                  index];
                              
                          final isSelected =
                              provider.selectedTabs.any(
                            (e) =>
                                e.uuid ==
                                tab.uuid,
                          );
                              
                          return GestureDetector(
                            onTap:provider.selectionMode ? null : (){
                              final index =
                                browserModel.webViewTabs
                                    .indexWhere(
                              (e) =>
                                  e.webViewModel.uuid ==
                                  tab.uuid,
                                  );
                              
                                  if (index != -1) {
                              Navigator.pop(context);
                              bottomNavigationProvider.changeView(HomeView.home);
                              browserModel.showTabScroller = false;
                              
                              browserModel.showTab(
                                index,
                              );
                              
                                  }
                            },
                            child: SizedBox(
                                width: constraints.maxWidth,
            height: constraints.maxHeight,
                              child: buildBox(
                              
                                title:
                                    tab.title ??
                                        "${loc.newtab}",
                              
                                screenshot:
                                    tab.screenshot,
                              
                                color:
                                    widget.group.color,
                              
                                /// TAB OPEN
                                onTap: () {
                                                      print('The tab inside the group is clicked');
                              
                                  /// SELECTION MODE
                                  if (provider.selectionMode) {
                              
                                    setState(() {
                              
                                      if (isSelected) {
                              
                                        provider.selectedTabs
                                            .removeWhere(
                                          (e) =>
                                              e.uuid ==
                                              tab.uuid,
                                        );
                              
                                      } else {
                              
                                        provider.selectedTabs
                                            .add(
                                          tab,
                                        );
                                      }
                                    });
                              
                                    return;
                                  }
                                 print('The tab inside the group is clicked');
                                 bottomNavigationProvider.changeView(HomeView.home);
                                  browserModel
                                          .showTabScroller =
                                      false;
                              
                                  provider.openTab(
                                    context,//widget.group,
                                    tab,
                                  );
                                },
                              
                                /// REMOVE TAB
                                onClose: () {
                                   provider.closeSingleTab(context, tab);
                                  // provider
                                  //     .removeFromGroup(
                                  //   tab,
                                  //   widget.group,
                                  // );
                              
                                  if (widget.group.tabs
                                      .isEmpty) {
                              
                                    Navigator.pop(
                                      context,
                                    );
                                  }
                                },
                              
                                /// SELECTION MODE
                                selectionMode:
                                    provider.selectionMode,
                              
                                isSelected:
                                    isSelected,
                              
                                onSelect: () {
                                                      print('The tab inside the group is clicked');
                              
                                  setState(() {
                              
                                    if (isSelected) {
                              
                                      provider.selectedTabs
                                          .removeWhere(
                                        (e) =>
                                            e.uuid ==
                                            tab.uuid,
                                      );
                              
                                    } else {
                              
                                      provider.selectedTabs
                                          .add(
                                        tab,
                                      );
                                    }
                                  });
                                }, isCurrentTab: provider.isCurrentTab(tab), themeProvider: themeProvider,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}
Future<void> confirmUngroupSelectedTabs(
  BuildContext context,
  GroupModel group,AppLocalizations loc
) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

  final result =
      await showDialog<bool>(
    barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8),
    context: context,

    builder: (_) {

      return Dialog(
        
              insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
        // title: const Text(
        //   "Ungroup selected tabs from Group?",
        // ),

        child: GlassCommonPanel(
          child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                              border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))

              ),
                  width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     GlassCommonPanel(
                       child: Container(
                        height: 46,width: 46,
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/images/ai-icons/new/Ungroup Tab.svg',color: themeProvider.darkTheme ? Color(0xffffffff) : Color(0xff737373),)),
                     ),
                     //Spacer(),
                     SizedBox(width: 10,),
                     Text(loc.ungroupTabGroup.toUpperCase(),
          style: TextStyle(fontFamily: 'Conthrax',fontSize: 14,fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 15,)
                  ],
                ),
                SizedBox(height: 14,),
                Text(
                  "Do you really want to upgroup selected tabs from ${group.name}?",
                ),
                SizedBox(height: 14),
               GestureDetector(
                      onTap: (){
                        Navigator.pop(
                context,
                true,
              ); 
                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)
                        ),
                        child: Center(child: Text(loc.ungroup,style: TextStyle(color: themeProvider.darkTheme ? Colors.black : Colors.white,fontFamily: 'Inter', fontSize: 18,fontWeight: FontWeight.w600),)),
                      ),
                    ),
                    SizedBox(height: 14,),
                    GestureDetector(
                      onTap: ()=> Navigator.pop(context,false),
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Center(child: Text(loc.cancel,style: TextStyle(color: Color(0xffACACAC),fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.w600),)),
                      ),),

              ],
            ),
          ),
        ),

        // actions: [

        //   TextButton(

        //     onPressed: () {
        //       Navigator.pop(
        //         context,
        //         false,
        //       );
        //     },

        //     child: const Text(
        //       "Cancel",
        //     ),
        //   ),

        //   ElevatedButton(

        //     onPressed: () {
        //       Navigator.pop(
        //         context,
        //         true,
        //       );
        //     },

        //     child: const Text(
        //       "Delete",
        //     ),
        //   ),
        // ],
      );
    },
  );

  if (result == true) {
Navigator.pop(context);
   provider.ungroupSelectedTabs();
    // provider.ungroupAllTabs(
    //   group,
    // );

   // Navigator.pop(context);
  }
}


Widget miniPreview(
  List<WebViewModel> tabs,
) {

  return Wrap(

    spacing: 4,
    runSpacing: 4,

    children: tabs.take(4).map((e) {

      final title =
          e.title ?? "T";

      return Container(

        width: 22,
        height: 22,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            6,
          ),
        ),

        child: Text(

          title
              .trim()
              .substring(0, 1)
              .toUpperCase(),

          style: const TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      );
    }).toList(),
  );
}

Future<void> showCreateGroupDialog({
  required BuildContext context,
  required WebViewModel first,
  required WebViewModel second,
}) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final loc = AppLocalizations.of(context)!;
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

  final TextEditingController controller =
      TextEditingController(text: "New Group");
      final FocusNode focusNode = FocusNode();

 final colors = [
    Color(0xffEBEBEB),
    Color(0xff4ED971),
    Color(0xff4EAFFF),
    Color(0xffBB70F9),
    Color(0xffFF8383),
    Color(0xffE3AD2F),
  ];

  Color selectedColor = Colors.blue;

  await showDialog(
    barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8) ,
    context: context,

    builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
  focusNode.requestFocus();

  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );
});

      return StatefulBuilder(
        builder: (context, setState) {

          return Dialog(
             insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
            // shape: RoundedRectangleBorder(
            //   borderRadius:
            //       BorderRadius.circular(20),
            // ),

            // title: const Text(
            //   "Create Group",
            // ),

            child: GlassCommonPanel(
              child: Container(
                margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min,
                
                  children: [
                 SizedBox(
                       child: Text(loc.newTabGroup,style: TextStyle(fontFamily: 'Conthrax',fontSize: 14),),
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
                            focusNode: focusNode,
                        style: TextStyle(fontSize: 12, fontFamily:"Roboto"),  
                        
                        decoration:
                             InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 5),
                              hintStyle: TextStyle(fontFamily: 'Roboto',fontSize: 12,color:themeProvider.darkTheme ? Color(0xff737373): Color(0xffACACAC)),
                          hintText:
                              loc.groupName,border: InputBorder.none,
                         // border: 
                             // OutlineInputBorder(),
                        ),
                      ),
                    ),
                
                    const SizedBox(
                      height: 14,
                    ),
                     Text('${loc.groupColor}',style: TextStyle(color: Color(0xff8D8D8D)),),
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
                                     final groupName =
                      controller.text.trim();

                  if (groupName.isEmpty) {
                    return;
                  }

                  provider.createGroup(
                    name: groupName,
                    color: selectedColor,
                    first: first,
                    second: second,
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
                        child: Center(child: Text('${loc.create}',style: TextStyle(color:themeProvider.darkTheme ? Colors.black : Colors.white,fontSize: 18,fontFamily: 'Inter' ,fontWeight: FontWeight.w600),)),
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
                        child: Center(child: Text('${loc.cancel}',style: TextStyle(color: Color(0xffACACAC),fontSize: 18,fontFamily: 'Inter',fontWeight: FontWeight.w600),)),
                      ),
                    )
                  ],
                ),
              ),
            ),
       
            // actions: [

            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },

            //     child: const Text(
            //       "Cancel",
            //     ),
            //   ),

            //   ElevatedButton(
            //     onPressed: () {

            //       final groupName =
            //           controller.text.trim();

            //       if (groupName.isEmpty) {
            //         return;
            //       }

            //       provider.createGroup(
            //         name: groupName,
            //         color: selectedColor,
            //         first: first,
            //         second: second,
            //       );

            //       Navigator.pop(context);
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



Future<void> showCreateEmptyGroupDialog(
  BuildContext context,
) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
final loc = AppLocalizations.of(context)!;
  final controller =
      TextEditingController();

  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  Color selectedColor =
      Colors.blue;

  await showDialog(

    context: context,

    builder: (context) {

      return StatefulBuilder(
        builder: (
          context,
          setState,
        ) {

          return AlertDialog(

            title: Text(
              "Create Tab Group",
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            content: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(
                  controller:
                      controller,

                  decoration:
                      const InputDecoration(
                    hintText:
                        "Group Name",
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Wrap(
                  spacing: 12,

                  children:
                      colors.map(
                    (color) {

                      final selected =
                          selectedColor ==
                              color;

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
                                180,
                          ),

                          width: selected
                              ? 42
                              : 36,

                          height: selected
                              ? 42
                              : 36,

                          decoration:
                              BoxDecoration(
                            color: color,

                            shape:
                                BoxShape
                                    .circle,

                            border:
                                Border.all(
                              color: selected
                                  ? Colors
                                      .black
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
              ],
            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },

                child: const Text(
                  "Cancel",
                ),
              ),

              ElevatedButton(

                onPressed: () async {

                  final name =
                      controller.text
                          .trim();

                  if (name.isEmpty) {
                    return;
                  }

                  await provider
                      .createEmptyGroup(
                    name: name,
                    color:
                        selectedColor,
                  );

                  Navigator.pop(
                    context,
                  );
                },

                child: const Text(
                  "Create",
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
// working 

// class ItemWidget extends StatelessWidget {
//   final ItemModel item;

//   const ItemWidget({
//     super.key,
//     required this.item,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final provider =
//         Provider.of<GroupProvider>(
//       context,
//       listen: false,
//     );

//     return LongPressDraggable<ItemModel>(
//       data: item,

//       feedback: Material(
//         color: Colors.transparent,
//         child: buildBox(
//           item.title,
//           Colors.blue,
//         ),
//       ),

//       childWhenDragging: Opacity(
//         opacity: 0.2,
//         child: buildBox(
//           item.title,
//           Colors.grey,
//         ),
//       ),

//       child: DragTarget<ItemModel>(
//         onWillAccept: (incoming) {
//           return incoming != null &&
//               incoming.id != item.id;
//         },

//         onAccept: (incoming) {
//           provider.createGroup(
//             item,
//             incoming,
//           );
//         },

//         builder: (
//           context,
//           candidateData,
//           rejectedData,
//         ) {
//           return buildBox(
//             item.title,
//             Colors.orange,
//           );
//         },
//       ),
//     );
//   }
// }

// class GroupWidget extends StatelessWidget {
//   final GroupModel group;

//   const GroupWidget({
//     super.key,
//     required this.group,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final provider =
//         Provider.of<GroupProvider>(
//       context,
//       listen: false,
//     );

//     return DragTarget<ItemModel>(
//       onWillAccept: (_) => true,

//       onAccept: (item) {
//         provider.addToGroup(item, group);
//       },

//       builder: (
//         context,
//         candidateData,
//         rejectedData,
//       ) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => GroupScreen(
//                   group: group,
//                 ),
//               ),
//             );
//           },

//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius:
//                   BorderRadius.circular(16),
//             ),

//             child: Stack(
//               children: [
//                 Positioned(
//                   left: 8,
//                   top: 8,
//                   child: miniPreview(
//                     group.items,
//                   ),
//                 ),

//                 Center(
//                   child: Text(
//                     "Group\n${group.items.length} items",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class GroupScreen extends StatelessWidget {
//   final GroupModel group;

//   const GroupScreen({
//     super.key,
//     required this.group,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final provider =
//         Provider.of<GroupProvider>(
//       context,
//       listen: false,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Group Items"),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           itemCount: group.items.length,
//           gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           ),
//           itemBuilder: (_, index) {
//             final item = group.items[index];

//             return GestureDetector(
//               onLongPress: () {
//                 provider.removeFromGroup(
//                   item,
//                   group,
//                 );
//               },

//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.purple,
//                   borderRadius:
//                       BorderRadius.circular(16),
//                 ),

//                 child: Column(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       item.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     const Text(
//                       "Long press to remove",
//                       style: TextStyle(
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// Widget miniPreview(List<ItemModel> items) {
//   return Wrap(
//     spacing: 4,
//     runSpacing: 4,
//     children: items.take(4).map((e) {
//       return Container(
//         width: 20,
//         height: 20,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(6),
//         ),
//         child: Text(
//           e.title,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }).toList(),
//   );
// }


Widget buildBox({

  required String title,
  required Uint8List? screenshot,
  required VoidCallback onClose,
  required VoidCallback onTap,
  //required Favicon favIcon,
  required bool selectionMode,
  required bool isSelected,
  required VoidCallback onSelect,
  required bool isCurrentTab,
  required Color color,
  required DarkThemeProvider themeProvider
}) {

  return Stack(
  
    children: [
  
      GlassPanel(
        child: Container(
          
          width: 175,
          height: 225,
          
          decoration: BoxDecoration(
           // color: Colors.grey.shade900,
            //borderRadius:
                //BorderRadius.circular(18),
                border: Border.all(color: isCurrentTab ? Colors.green : Colors.transparent,width: 2)
          ),
          
          child: Column(
            children: [
          
              /// TOP BAR
              Container(
          
                height: 40,
          
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
          
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  // borderRadius:
                  //     const BorderRadius.only(
                  //   topLeft:
                  //       Radius.circular(18),
                  //   topRight:
                  //       Radius.circular(18),
                  // ),
                ),
          
                child: Row(
                  children: [
                    // favIcon == [] || favIcon.length == 0
                    //         ? Container()
                    //         : Image.network(
                    //             '${favIcon[0].url.toString()}',
                    //             errorBuilder: (context, error, stackTrace) {
                    //               return Icon(Icons.web);
                    //             },
                    //           ),
                    Expanded(
                      child: Text(
          
                        title,
          
                        maxLines: 1,
          
                        overflow:
                            TextOverflow.ellipsis,
          
                        style: const TextStyle(
                          fontFamily: 'Inter',
                         // color: Colors.white,
                          // fontWeight:
                          //     FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
          
                  selectionMode ?  GestureDetector(
  
            onTap: onSelect,
  
            child: AnimatedContainer(
  
              duration:
                  const Duration(
                milliseconds: 180,
              ),
  
              width: 15,
              height: 15,
  
              decoration: BoxDecoration(
  
                //shape: BoxShape.circle,
  
                color: isSelected
                    ? themeProvider.darkTheme ? Colors.white : Color(0xffffffff)
                    : themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
  
                border: Border.all(
                  color:  themeProvider.darkTheme ? Colors.white : Color(0xff0B0B0B) ,
                ),
              ),
  
              child: Icon(
                      Icons.check,
                // isSelected
                //     ? Icons.check
                //     : Icons.circle_outlined,
  
                size: 12,
  
                color: isSelected
                    ? Colors.black
                    : Colors.transparent,
              ),
            ),
          ) :  GestureDetector(
          
                      onTap: onClose,
          
                      child: const Icon(
                        Icons.close,
                       // color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
          
              /// SCREENSHOT
              Expanded(
          
                child: Container(
                   padding: EdgeInsets.all(5),
                  // borderRadius:
                  //     const BorderRadius.only(
                  //   bottomLeft:
                  //       Radius.circular(18),
                  //   bottomRight:
                  //       Radius.circular(18),
                  // ),
          
                  child: screenshot != null
          
                      ? Image.memory(
          
                          screenshot,
          
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
          
                      : Container(
          
                          color:themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffFFFFFF),
          
                          alignment:
                              Alignment.center,
          
                          child: SvgPicture.asset('assets/imaages/ai-icons/new/Default_Image.svg', color: themeProvider.darkTheme ?  Color(0xff333333) : Color(0xffD4D4D4),),
                          // const Icon(
                          //   Icons.language,
                          //   size: 50,
                          //   color: Colors.white54,
                          // ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
  
      /// SELECTION OVERLAY
      // if (selectionMode)
  
      //   Positioned(
  
      //     top: 10,
      //     right: 10,
  
      //     child: GestureDetector(
  
      //       onTap: onSelect,
  
      //       child: AnimatedContainer(
  
      //         duration:
      //             const Duration(
      //           milliseconds: 180,
      //         ),
  
      //         width: 15,
      //         height: 15,
  
      //         decoration: BoxDecoration(
  
      //           //shape: BoxShape.circle,
  
      //           color: isSelected
      //               ? themeProvider.darkTheme ? Colors.white : Color(0xffffffff)
      //               : themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
  
      //           border: Border.all(
      //             color:  themeProvider.darkTheme ? Colors.white : Color(0xff0B0B0B) ,
      //           ),
      //         ),
  
      //         child: Icon(
      //                 Icons.check,
      //           // isSelected
      //           //     ? Icons.check
      //           //     : Icons.circle_outlined,
  
      //           size: 12,
  
      //           color: isSelected
      //               ? Colors.black
      //               : Colors.transparent,
      //         ),
      //       ),
      //     ),
      //   ),
  
      /// SELECTED DARK OVERLAY
      // if (selectionMode && isSelected)
  
      //   Positioned.fill(
  
      //     child: Container(
  
      //       decoration: BoxDecoration(
  
      //         color: Colors.blue
      //             .withOpacity(0.15),
  
      //         borderRadius:
      //             BorderRadius.circular(
      //           18,
      //         ),
  
      //         border: Border.all(
      //           color: Colors.blue,
      //           width: 2,
      //         ),
      //       ),
      //     ),
      //   ),
    ],
  );
}



///////////////// working one

// Widget buildBox({
//   required String title,
//   required Uint8List? screenshot,
//   required VoidCallback onClose,
//   required Color color,
// }) {

//   return Container(

//     width: 170,
//     height: 220,

//     decoration: BoxDecoration(
//       color: Colors.grey.shade900,
//       borderRadius:
//           BorderRadius.circular(18),
//     ),

//     child: Column(
//       children: [

//         /// TOP BAR
//         Container(

//           height: 46,

//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 12,
//           ),

//           decoration: BoxDecoration(
//             color: color,
//             borderRadius:
//                 const BorderRadius.only(
//               topLeft:
//                   Radius.circular(18),
//               topRight:
//                   Radius.circular(18),
//             ),
//           ),

//           child: Row(
//             children: [

//               Expanded(
//                 child: Text(

//                   title,

//                   maxLines: 1,

//                   overflow:
//                       TextOverflow.ellipsis,

//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight:
//                         FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),

//               GestureDetector(

//                 onTap: onClose,

//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         /// SCREENSHOT
//         Expanded(

//           child: ClipRRect(

//             borderRadius:
//                 const BorderRadius.only(
//               bottomLeft:
//                   Radius.circular(18),
//               bottomRight:
//                   Radius.circular(18),
//             ),

//             child: screenshot != null

//                 ? Image.memory(

//                     screenshot,

//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   )

//                 : Container(

//                     color: Colors.black12,

//                     alignment:
//                         Alignment.center,

//                     child: const Icon(
//                       Icons.language,
//                       size: 50,
//                       color: Colors.white54,
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     ),
//   );
// }


//////////////////////////////////////////////////////////////////


Future<void> showEditGroupColorDialog({
  required BuildContext context,
  required GroupModel group,
}) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );

  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  Color selectedColor =
      group.color;

  await showDialog(

    context: context,

    builder: (_) {

      return StatefulBuilder(
        builder: (
          context,
          setState,
        ) {

          return AlertDialog(

            title: const Text(
              "Edit Group color",
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            content: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Wrap(

                  spacing: 12,

                  children:
                      colors.map(
                    (color) {

                      final selected =
                          selectedColor ==
                              color;

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
                                180,
                          ),

                          width: selected
                              ? 42
                              : 36,

                          height: selected
                              ? 42
                              : 36,

                          decoration:
                              BoxDecoration(
                            color: color,
                            shape:
                                BoxShape
                                    .circle,

                            border:
                                Border.all(
                              color: selected
                                  ? Colors
                                      .black
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
              ],
            ),

            actions: [

              TextButton(

                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },

                child: const Text(
                  "Cancel",
                ),
              ),

              ElevatedButton(

                onPressed: () {

                  provider.editGroupColor(

                    group: group,
                    color:
                        selectedColor,
                  );

                  Navigator.pop(
                    context,
                  );
                },

                child: const Text(
                  "Update",
                ),
              ),
            ],
          );
        },
      );
    },
  );
}




Future<void> showEditGroupDialog({
  required BuildContext context,
  required GroupModel group,
}) async {

  final provider =
      Provider.of<GroupProvider>(
    context,
    listen: false,
  );
  final loc = AppLocalizations.of(context)!;
 final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
  final controller =
      TextEditingController(
    text: group.name,
  );

  final colors = [
    Color(0xffEBEBEB),
    Color(0xff4ED971),
    Color(0xff4EAFFF),
    Color(0xffBB70F9),
    Color(0xffFF8383),
    Color(0xffE3AD2F),
  ];

Color selectedColor = colors.firstWhere(
  (c) => c.toARGB32() == group.color.toARGB32(),
  orElse: () => colors.first,
);

  await showDialog(
    barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8),
    context: context,

    builder: (_) {
   
      return StatefulBuilder(
        builder: (
          context,
          setState,
        ) {
          
          return Dialog(
           insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
            // title: const Text(
            //   "Edit Group",
            // ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child: GlassSettingPanel(
                          color:themeProvider.darkTheme ? const Color(0xFF222222).withOpacity(0.5) : const Color(0xffFFFFFF).withOpacity(0.7),
                          border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  //border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4))
                ),
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height/2,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min,
                
                  children: [
                    SizedBox(
                       child: Text(loc.renameGroup.toUpperCase() ,style: TextStyle(fontFamily: 'Conthrax',fontSize: 14),),
                    ),
                   const SizedBox(height: 8,),
                  Text(loc.groupName,style: TextStyle(color: Color(0xff8D8D8D)),),
                 const SizedBox(height: 8,),
                    Container(
                       //margin: EdgeInsets.symmetric(horizontal: 15),
                  height: 50,decoration: BoxDecoration(
                    border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),
                    color: themeProvider.darkTheme ? Colors.black26 : Color(0xffffffff)),
                      child: TextField(
                                      
                        controller:
                            controller,
                        style: TextStyle(fontSize: 12, fontFamily:"Roboto"),  
                        
                        decoration:
                             InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 5),
                              hintStyle: TextStyle(fontFamily: 'Roboto',fontSize: 12),
                          hintText:loc.groupName,
                              border: InputBorder.none,
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
                      onTap: (){
                        if(controller.text.trim().isNotEmpty){
                          provider.editGroup(

                    group: group,

                    name:
                        controller.text
                            .trim(),

                    color:
                        selectedColor,
                  );

                  Navigator.pop(
                    context,
                  );
                        }
                              

                      },
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)
                        ),
                        child: Center(child: Text(loc.done,style: TextStyle(color: themeProvider.darkTheme ? Colors.black : Colors.white,fontFamily: 'Inter', fontSize: 18,fontWeight: FontWeight.w600),)),
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
                        child: Center(child: Text(loc.cancel,style: TextStyle(color: Color(0xffACACAC),fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.w600),)),
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

            //       provider.editGroup(

            //         group: group,

            //         name:
            //             controller.text
            //                 .trim(),

            //         color:
            //             selectedColor,
            //       );

            //       Navigator.pop(
            //         context,
            //       );
            //     },

            //     child: const Text(
            //       "Save",
            //     ),
            //   ),
            // ],
          );
        },
      );
    },
  );
}
// Widget buildBox(
//   String text,
//   Color color,
// ) {
//   return Container(
//     width: 110,
//     height: 130,
//     alignment: Alignment.center,
//     decoration: BoxDecoration(
//       color: Colors.grey, //color,
//       borderRadius:
//           BorderRadius.circular(16),
//     ),
//     child: Text(
//       text,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   );
// }

// class ItemModel {
//   final String id;
//   final String title;

//   ItemModel({
//     required this.id,
//     required this.title,
//   });
// }

// class GroupModel {
//   final String id;
//   final List<ItemModel> items;

//   GroupModel({
//     required this.id,
//     required this.items,
//   });
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<ItemModel> outsideItems = [
//     ItemModel(id: '1', title: 'A'),
//     ItemModel(id: '2', title: 'B'),
//     ItemModel(id: '3', title: 'C'),
//     ItemModel(id: '4', title: 'D'),
//     ItemModel(id: '5', title: 'E'),
//   ];

//   List<GroupModel> groups = [];

//   void createGroup(
//     ItemModel first,
//     ItemModel second,
//   ) {
//     final group = GroupModel(
//       id: DateTime.now().toString(),
//       items: [first, second],
//     );

//     setState(() {
//       groups.add(group);

//       outsideItems.removeWhere((e) => e.id == first.id);
//       outsideItems.removeWhere((e) => e.id == second.id);
//     });
//   }

//   void addToGroup(
//     ItemModel item,
//     GroupModel group,
//   ) {
//     setState(() {
//       outsideItems.removeWhere((e) => e.id == item.id);

//       final alreadyExists =
//           group.items.any((e) => e.id == item.id);

//       if (!alreadyExists) {
//         group.items.add(item);
//       }
//     });
//   }

//   Widget buildItem(ItemModel item) {
//     return LongPressDraggable<ItemModel>(
//       data: item,

//       feedback: Material(
//         color: Colors.transparent,
//         child: buildBox(
//           item.title,
//           Colors.blue,
//         ),
//       ),

//       childWhenDragging: Opacity(
//         opacity: 0.2,
//         child: buildBox(
//           item.title,
//           Colors.grey,
//         ),
//       ),

//       child: DragTarget<ItemModel>(
//         onWillAccept: (incoming) {
//           return incoming != null &&
//               incoming.id != item.id;
//         },

//         onAccept: (incoming) {
//           createGroup(item, incoming);
//         },

//         builder: (
//           context,
//           candidateData,
//           rejectedData,
//         ) {
//           return buildBox(
//             item.title,
//             Colors.orange,
//           );
//         },
//       ),
//     );
//   }

//   Widget buildGroup(GroupModel group) {
//     return DragTarget<ItemModel>(
//       onWillAccept: (item) => true,

//       onAccept: (item) {
//         addToGroup(item, group);
//       },

//       builder: (
//         context,
//         candidateData,
//         rejectedData,
//       ) {
//         return GestureDetector(
//           onTap: () async {
//             final returnedItem =
//                 await Navigator.push<ItemModel>(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     GroupScreen(group: group),
//               ),
//             );

//             if (returnedItem != null) {
//               setState(() {
//                 group.items.removeWhere(
//                   (e) => e.id == returnedItem.id,
//                 );

//                 outsideItems.add(returnedItem);

//                 if (group.items.isEmpty) {
//                   groups.remove(group);
//                 }
//               });
//             }
//           },

//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius:
//                   BorderRadius.circular(16),
//             ),

//             child: Stack(
//               children: [
//                 Positioned(
//                   left: 8,
//                   top: 8,
//                   child: miniPreview(
//                     group.items,
//                   ),
//                 ),

//                 Center(
//                   child: Text(
//                     "Group\n${group.items.length} items",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget miniPreview(List<ItemModel> items) {
//     return Wrap(
//       spacing: 4,
//       runSpacing: 4,
//       children: items.take(4).map((e) {
//         return Container(
//           width: 20,
//           height: 20,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius:
//                 BorderRadius.circular(6),
//           ),
//           child: Text(
//             e.title,
//             style: const TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget buildBox(
//     String text,
//     Color color,
//   ) {
//     return Container(
//       width: 110,
//       height: 110,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius:
//             BorderRadius.circular(16),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalWidgets = [
//       ...outsideItems.map(buildItem),
//       ...groups.map(buildGroup),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Drag Group Demo"),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           itemCount: totalWidgets.length,
//           gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           ),
//           itemBuilder: (_, index) {
//             return totalWidgets[index];
//           },
//         ),
//       ),
//     );
//   }
// }

// class GroupScreen extends StatelessWidget {
//   final GroupModel group;

//   const GroupScreen({
//     super.key,
//     required this.group,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Group Items"),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           itemCount: group.items.length,
//           gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           ),
//           itemBuilder: (_, index) {
//             final item = group.items[index];

//             return GestureDetector(
//               onLongPress: () {
//                 Navigator.pop(context, item);
//               },

//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.purple,
//                   borderRadius:
//                       BorderRadius.circular(16),
//                 ),

//                 child: Column(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       item.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     const Text(
//                       "Long press to remove",
//                       style: TextStyle(
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }