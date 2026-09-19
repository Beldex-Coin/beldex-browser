import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/settings/main.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/tab_selection_screen.dart';
import 'package:beldex_browser/src/browser/providers/bottom_nav_bar_provider.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../custom_popup_menu_item.dart';
import '../tab_viewer_popup_menu_actions.dart';


class TabBottomBar extends StatefulWidget {
  const TabBottomBar({super.key});

  @override
  State<TabBottomBar> createState() => _TabBottomBarState();
}

class _TabBottomBarState extends State<TabBottomBar> {
  @override
  Widget build(BuildContext context) {
     var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    final groupProvider = Provider.of<GroupProvider>(context); // make listener false if issue comes 
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,left: false,right: false,bottom: true,
      child: Container(
      
                    height: 65,
                    decoration: BoxDecoration(
                      color: themeProvider.darkTheme ? Colors.transparent : Color(0xffEBEBEB),
                      border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3)))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         SvgPicture.asset('assets/images/ai-icons/new/add_tab.svg',color: Colors.transparent,),
                          GestureDetector(
                            onTap: (){
                              if(groupProvider.currentMode == ViewMode.groupsOnly){
                               showCreateEmptyGroupDialog(
                                 context,
                                  );
                                return;
                              }
                               addNewTab();
                               
                                },
                            child:themeProvider.darkTheme ? SvgPicture.asset('assets/images/ai-icons/new/add_tab.svg') : SvgPicture.asset('assets/images/ai-icons/new/add_tab_white.svg')),
      
      
                      groupProvider.currentMode == ViewMode.all ? 
                         PopupMenuButton<String>(
                          menuPadding: EdgeInsets.zero,
                           color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
         // color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
          constraints: BoxConstraints(
                    maxWidth: 220,
                   ),
                icon: SvgPicture.asset('assets/images/ai-icons/new/threedot.svg',color:themeProvider.darkTheme ? Colors.white : Colors.black),// Icon(Icons.more_horiz,
                    //color: themeProvider.darkTheme ? Colors.white : Colors.black),
          onSelected: _popupMenuChoiceAction,
          offset:Offset(0, -180), //Offset(0, 47),
          shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(
        color:themeProvider.darkTheme ? Color(0xff333333) :  Color(0xffD4D4D4), //.withOpacity(0.2),
        width: 1,
      ),
        ),
          // surfaceTintColor:
                 //   themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
               // elevation: 2,
          // shape:const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.only(
          //           bottomLeft: Radius.circular(15.0),
          //           bottomRight: Radius.circular(15.0),
          //           topLeft: Radius.circular(15.0),
          //           topRight: Radius.circular(15.0),
          //         ),
          //       ),
          itemBuilder: (popupMenuContext) {
            var items = <PopupMenuEntry<String>>[];
      
            items.addAll(TabViewerPopupMenuActions.choices.map((choice) {
              switch (choice) {
                case TabViewerPopupMenuActions.NEW_TAB:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 38,
                   padding: EdgeInsets.zero,//only(left: 14,right: 16),
                    child: GlassSettingPanel(
                      color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/new_tab.svg' ,color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                                                      SizedBox(width: 8,),
                              Expanded(
                                child: Text(loc.newtab, style:TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  );
                  case TabViewerPopupMenuActions.CREATE_NEW_TAB_GROUP:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                    child: GlassSettingPanel(
                      color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                             SvgPicture.asset('assets/images/ai-icons/new/New Tab Group.svg', color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:8.0),
                                child: Text(loc.newTabGroup,style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B))),
                              ),
                            ]),
                      ),
                    ),
                  );
                case TabViewerPopupMenuActions.CLOSE_ALL_TABS:
                  return CustomPopupMenuItem<String>(
                    enabled:groupProvider.totalOpenTabsCount != 0, //browserModel.webViewTabs.isNotEmpty,
                    value: choice,
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                    child: GlassSettingPanel(
                      color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                          
                            children: [
                               Container(
                                 child:Icon(Icons.close,size: 20,),
                               ),
                               SizedBox(width: 5,),
                              Expanded(
                                child: Text(loc.closeAllTabs, style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  );
                  case TabViewerPopupMenuActions.SELECT_TABS:
                  return CustomPopupMenuItem<String>(
                    enabled:groupProvider.totalOpenTabsCount != 0, //browserModel.webViewTabs.isNotEmpty,
                    value: choice,
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                    child: GlassSettingPanel(
                      color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                               Container(
                                 child:Icon(Icons.select_all,size: 20,),
                               ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:5.0),
                                child: Text(loc.selectTabs, style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B))),
                              ),
                            ]),
                      ),
                    ),
                  );
                case TabViewerPopupMenuActions.SETTINGS:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    padding: EdgeInsets.zero,//only(left: 14,right: 16),
                    child: GlassSettingPanel(
                      color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:3.0),
                                child: SvgPicture.asset('assets/images/settings.svg', color: themeProvider.darkTheme
                                                      ?const Color(0xffFFFFFF)
                                                      :const Color(0xff282836)),
                              ),
                        SizedBox(width: 8,),
                              Expanded(
                                child: Text(loc.settings,style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),overflow: TextOverflow.ellipsis,maxLines: 1,),
                              ),
                            ]),
                      ),
                    ),
                  );
                default:
                  return CustomPopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
              }
            }).toList());
      
            return items;
          },
        ): SizedBox(
          child: SvgPicture.asset('assets/images/ai-icons/new/add_tab.svg',color: Colors.transparent,),
        )
                      ],
                    ),
                  ),
    );
  }

   void _popupMenuChoiceAction(String choice) async {
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
       final groupProvider = Provider.of<GroupProvider>(context,listen: false);
       final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context,listen: false);
       final browserModel = Provider.of<BrowserModel>(context,listen: false);
    switch (choice) {
      case TabViewerPopupMenuActions.NEW_TAB:
        Future.delayed(const Duration(milliseconds: 300), () {
          vpnStatusProvider.updateCanShowHomeScreen(false);
          addNewTab();
        });
        break;
      // case TabViewerPopupMenuActions.NEW_INCOGNITO_TAB:
      //   Future.delayed(const Duration(milliseconds: 300), () {
      //     addNewIncognitoTab();
      //   });
      //   break;
      case TabViewerPopupMenuActions.CREATE_NEW_TAB_GROUP:
        Future.delayed(const Duration(milliseconds: 300), () {
           showCreateEmptyGroupDialog(
        context,
      );
          //addNewIncognitoTab();
        });
        break;
      case TabViewerPopupMenuActions.CLOSE_ALL_TABS:
        Future.delayed(const Duration(milliseconds: 300), () {
          closeAllTabs();
          clearCookie();
        });
        break;
        case TabViewerPopupMenuActions.SELECT_TABS:
        Future.delayed(const Duration(milliseconds: 300), () {
          groupProvider.enableSelectionMode();      
          //provider.enableSelectionMode();

  Navigator.push(

    context,

    MaterialPageRoute(
      builder: (_) =>
          const TabSelectionScreen(),
    ),
  );
            });
        break;
      case TabViewerPopupMenuActions.SETTINGS:
        Future.delayed(const Duration(milliseconds: 300), () {
          goToSettingsPage(bottomNavigationProvider,browserModel);
        });
        break;
    }
  }

  void addNewTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context,listen: false);
    var settings = browserModel.getSettings();

    url ??= 
    // settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
    //     ? WebUri(settings.customUrlHomePage)
    //     : 
        WebUri(settings.searchEngine.url);
    bottomNavigationProvider.changeView(HomeView.home);
    browserModel.showTabScroller = false;

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(uuid: Uuid().v4(),url: url),
    ));
  }


  void closeAllTabs() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
        final groupProvider = Provider.of<GroupProvider>(context,listen: false);
    //final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context,listen: false);
   // bottomNavigationProvider.changeView(HomeView.home);
    browserModel.showTabScroller = false;
groupProvider.closeAllTabs(context);
    //browserModel.closeAllTabs();
  }

  void goToSettingsPage(BottomNavigationProvider bottomNavigationProvider,BrowserModel browserModel) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    bottomNavigationProvider.changeView(HomeView.home);
    browserModel.showTabScroller = false;
    
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
final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
  final controller =
      TextEditingController(text: "New Group");

 final FocusNode focusNode = FocusNode();

  final colors = [
   // Color(0xffEBEBEB),
    Color(0xff4ED971),
    Color(0xff4EAFFF),
    Color(0xffBB70F9),
    Color(0xffFF8383),
    Color(0xffE3AD2F),
  ];

Color selectedColor = Color(0xff4ED971);
// colors.firstWhere(
//   (c) => c.toARGB32() == group.color.toARGB32(),
//   orElse: () => colors.first,
// );
  await showDialog(

    context: context,
 barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8) ,
    builder: (context) {
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
            // title: const Text(
            //   "Create Tab Group",
            // ),
           
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: GlassSettingPanel(
           color:themeProvider.darkTheme ? const Color(0xFF222222).withOpacity(0.5) : const Color(0xffFFFFFF).withOpacity(0.7),
            border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),

              child: Container(
                margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                       //margin: EdgeInsets.symmetric(horizontal: 15),
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
                          hintText:loc.groupName,border: InputBorder.none,
                         // border: 
                             // OutlineInputBorder(),
                        ),
                      ),
                    ),
                
                    const SizedBox(
                      height: 14,
                    ),
                     Text( loc.groupColor,style: TextStyle(color: Color(0xff8D8D8D)),),
                     const SizedBox(
                      height: 14,
                    ),
                    // TextField(
                    //   controller:
                    //       controller,
                
                    //   decoration:
                    //       const InputDecoration(
                    //     hintText:
                    //         "Group Name",
                    //     border:
                    //         OutlineInputBorder(),
                    //   ),
                    // ),
                
                    // const SizedBox(
                    //   height: 20,
                    // ),
                
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

            //     onPressed: () async {

            //       final name =
            //           controller.text
            //               .trim();

            //       if (name.isEmpty) {
            //         return;
            //       }

            //       await provider
            //           .createEmptyGroup(
            //         name: name,
            //         color:
            //             selectedColor,
            //       );

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

}

class TabViewerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TabViewerAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  State<TabViewerAppBar> createState() => _TabViewerAppBarState();

  @override
  final Size preferredSize;
}

class _TabViewerAppBarState extends State<TabViewerAppBar> {
  GlobalKey tabInkWellKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return 
    AppBar(
      backgroundColor: Colors.transparent,
      titleSpacing: 10.0,
      centerTitle: true,
      title:_buildActionsMenu() ,
     // actions: _buildActionsMenu(),
    );
  }


  Widget _buildActionsMenu() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    final groupProvider = Provider.of<GroupProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      Padding(
        padding: 
        // settings.homePageEnabled
        //     ? const EdgeInsets.only(
        //         left: 20.0, top: 15.0, right: 10.0, bottom: 15.0)
        //     : 
            const EdgeInsets.only(
                left: 10.0, top: 10.0, right: 5.0, bottom: 10.0),
        child: GestureDetector(
          onTap: (){
            groupProvider.changeViewMode(
                        ViewMode.all,
                      );
          },
          child: Container(
             width: 34,
            height: 34,
            decoration:groupProvider.currentMode == ViewMode.all ? BoxDecoration(
              color:themeProvider.darkTheme ? const Color(0xFF3A3A3A) : Color(0xffEBEBEB),
              // border: Border.all(
              //   color: Colors.white,
              //   width: 1,
              // ),
              boxShadow: [
                BoxShadow(
          color: Colors.white.withOpacity(0.15),
          blurRadius: 8,
          spreadRadius: 2,
                ),
              ],
            ):null,
            child: Container(
              width: 23,
            height: 23,
            margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                // color: themeProvider.darkTheme
                //     ?const Color(0xff282836)
                //     :const Color(0xffF3F3F3),
                  border: Border.all(width: 1.0,color :themeProvider.darkTheme ? Colors.white : Colors.black,),
                  shape: BoxShape.rectangle,
                 
                  ),
              constraints: const BoxConstraints(minWidth: 18.0),
              child: Center(
                  child: groupProvider.totalOpenTabsCount > 99 ? 
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset('assets/images/Infinity_white_theme.svg',color: themeProvider.darkTheme ? Colors.white: Colors.black,),
                ):
                   Text(
                    groupProvider.totalOpenTabsCount.toString(),
               // browserModel.webViewTabs.length.toString(),
                style: const TextStyle(
                    //color: Colors.white,
                    fontWeight: FontWeight.normal,
                    
                    fontSize: 12.0),
              )),
            ),
          ),
        ),
      ),
      SizedBox(width: 10,),
      GestureDetector(
        onTap: (){
          groupProvider.changeViewMode(ViewMode.groupsOnly);
        },
        child: Container(
           width: 34,
              height: 34,
              decoration:groupProvider.currentMode == ViewMode.groupsOnly ? BoxDecoration(
                color: themeProvider.darkTheme ? const Color(0xFF3A3A3A): Color(0xffEBEBEB),
                // border: Border.all(
                //   color: Colors.white,
                //   width: 1,
                // ),
                boxShadow: [
                  BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 2,
                  ),
                ],
              ):null,
          child: Container(
            height: 23,
            width: 23,
            margin: EdgeInsets.all(6),
            child: themeProvider.darkTheme ? SvgPicture.asset('assets/images/ai-icons/new/tab_group.svg'):SvgPicture.asset('assets/images/ai-icons/new/tab_gr_whitep.svg') ,
          ),
        ),
      )
      
    ]
    );
    
    
  }

  Widget _selectedBox(Widget child){
    return Container(
       width: 34,
  height: 34,
  decoration: BoxDecoration(
    color: const Color(0xFF3A3A3A),
    border: Border.all(
      color: Colors.white,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.15),
        blurRadius: 8,
        spreadRadius: 2,
      ),
    ],
  ),
    );
  }
}
