import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/l10n/generated/app_localizations_af.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/folder_tab_system.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/bottom_nav_bar_provider.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SearchTabsScreen
    extends StatefulWidget {

  const SearchTabsScreen({
    super.key,
  });

  @override
  State<SearchTabsScreen>
      createState() =>
          _SearchTabsScreenState();
}

class _SearchTabsScreenState
    extends State<SearchTabsScreen> {

  final controller =
      TextEditingController();

  List<TabSearchResult>
      results = [];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final provider =
        Provider.of<GroupProvider>(
      context,
      listen: false,
    );
   final browserModel = Provider.of<BrowserModel>(context,listen: false);
   final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);
   final themeProvider = Provider.of<DarkThemeProvider>(context);
    return Stack(
      children: [
         Positioned.fill(
        child: themeProvider.darkTheme ? Image.asset(
          'assets/images/ai-icons/new/background_map.gif',
          fit: BoxFit.cover,
        ):Image.asset(
          'assets/images/ai-icons/new/BG_wht_theme.gif',
          fit: BoxFit.cover,
        ),
      ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
        AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth:0 ,
      title:
          Row(
            children: [
      GestureDetector(
        onTap:(){
          Navigator.pop(context);
        },
        child: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
            height: 24,
          ),
      ),
        SizedBox(width: 5,),
            ],
          ),
    ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
Container(
                  height: 50,decoration: BoxDecoration(
                    border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),
                    color:themeProvider.darkTheme ? Colors.black26 : Colors.transparent //(0xffFFFFFF)
                    ),
                child: Container(
  height: 40,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SvgPicture.asset(
        'assets/images/ai-icons/new/search_tab_white.svg',
        width: 18,
        height: 18,
      ),

      const SizedBox(width: 8),

      Expanded(child: 
        TextField(
                      controller: controller,
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
   // fontFamily: 'Roboto',
    fontSize: 14,
   // color: Color(0xff444444),
  ),
            decoration: InputDecoration(
              
              hintText: loc.searchYourTabs,
              hintStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xff444444),
              ),
              
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear();
                        setState(() {
                          results = provider.searchTabs('');
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                results = provider.searchTabs(value);
              });
            },

        )
      ),
    ],
  ),
),),
                  
      //           Container(
      //              padding: EdgeInsets.symmetric(horizontal: 15),
      //             height: 50,decoration: BoxDecoration(
      //               border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4)),
      //               color:themeProvider.darkTheme ? Colors.black26 : Colors.transparent //(0xffFFFFFF)
      //               ),
      //             child: TextField(
                      
      //             controller: controller,
                      
      //             autofocus: true,
                      
      //             decoration:
      //                  InputDecoration(
      //                   icon: SvgPicture.asset('assets/images/ai-icons/new/search_tab_white.svg'),
      //               hintText:loc.searchYourTabs,
      //                   // "Search tabs or groups",
      //                   hintStyle: TextStyle(fontFamily: 'Roboto',fontSize: 14,color: Color(0xff444444)),
      //               border:
      //                   InputBorder.none,
      //                   // Clear button
      // suffixIcon: controller.text.isNotEmpty
      //     ? IconButton(
      //         icon: const Icon(
      //           Icons.close,
      //           size: 20,
      //         ),
      //         onPressed: () {
      //           controller.clear();

      //           setState(() {
      //             results = provider.searchTabs('');
      //           });
      //         },
      //       )
      //     : null,
      //             ),
                      
      //             onChanged: (value) {
                      
      //               setState(() {
                      
      //                 results =
      //                     provider.searchTabs(
      //                   value,
      //                 );
      //               });
      //             },
      //                           ),
      //           ),
                Expanded(
                  child: ListView.builder(
                          
                    itemCount:
                        results.length,
                          
                    itemBuilder:
                        (context, index) {
                          
                      final result =
                          results[index];
                          
                      /// GROUP
                      if (result.isGroup) {
                          
                        final group =
                            result.group!;
                          
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: (){
                                  Navigator.pop(
                                context,
                              );
                            
                              showGroupDialog(
                                context,
                                group,
                              );
                            },
                            child: GlassGroupPanel(
                              color: group.color,
                              child: Container(
                                height: 55,
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: group.color)
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SvgPicture.asset('assets/images/ai-icons/new/tab_group.svg', ),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(height: 8,width: 8,decoration: BoxDecoration(shape: BoxShape.circle,color: group.color),),
                                            SizedBox(width: 6,),
                                            Text(group.name,style: TextStyle( fontSize: 12,fontFamily: 'Inter'),),
                                            
                                          ],
                                        ),
                                        Text(group.tabs.length == 1 ? '1 ${loc.tab}': '${group.tabs.length} ${loc.tabs}',style: TextStyle(fontSize: 10, fontFamily: 'Inter',color: Color(0xffACACAC)),)
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                        // ListTile(
                          
                        //   leading:
                        //       CircleAvatar(
                        //     backgroundColor:
                        //         group.color,
                        //     child: const Icon(
                        //       Icons.folder,
                        //       color:
                        //           Colors.white,
                        //     ),
                        //   ),
                          
                        //   title: Text(
                        //     group.name,
                        //   ),
                          
                        //   subtitle: Text(
                        //     "${group.tabs.length} tabs",
                        //   ),
                          
                        //   onTap: () {
                          
                        //     Navigator.pop(
                        //       context,
                        //     );
                          
                        //     showGroupDialog(
                        //       context,
                        //       group,
                        //     );
                        //   },
                        // );
                      }
                          
                      /// TAB
                      final tab =
                          result.tab!;
                          
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                            onTap: (){
                                    bottomNavigationProvider.changeView(HomeView.home);
                             browserModel.showTabScroller = false;
                            provider.openTab(
                              context,//result.group,
                              tab,
                            );
                            },
                            child: GlassPanel(
                             
                              child: Container(
                                height: 55,
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: group.color)
                                // ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SvgPicture.asset('assets/images/ai-icons/new/Default_Image.svg',height: 30,width: 30,color: themeProvider.darkTheme ? Colors.white : Colors.black,),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          
                                          Expanded(child: Text(tab.title ?? '${loc.newtab}',style: TextStyle( fontSize: 12,fontFamily: 'Inter',overflow: TextOverflow.ellipsis,),maxLines: 1,)),
                                          Text( tab.url
                                      ?.toString() ?? "",overflow: TextOverflow.ellipsis,maxLines: 1, style: TextStyle(fontSize: 10, fontFamily: 'Inter',color: Color(0xffACACAC),),)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      );
                      // ListTile(
                          
                      //   leading:
                      //       tab.screenshot !=
                      //               null
                      //           ? ClipRRect(
                          
                      //               borderRadius:
                      //                   BorderRadius.circular(
                      //                 6,
                      //               ),
                          
                      //               child:
                      //                   Image.memory(
                          
                      //                 tab.screenshot!,
                          
                      //                 width: 50,
                      //                 height: 50,
                          
                      //                 fit: BoxFit
                      //                     .cover,
                      //               ),
                      //             )
                      //           : const Icon(
                      //               Icons.language,
                      //             ),
                          
                      //   title: Text(
                      //     tab.title ??
                      //         "New Tab",
                      //   ),
                          
                      //   subtitle: Text(
                      //     tab.url
                      //             ?.toString() ??
                      //         "",
                      //     maxLines: 1,
                      //     overflow:
                      //         TextOverflow
                      //             .ellipsis,
                      //   ),
                          
                      //   onTap: () {
                      //     //print('clicking on The Tabs after searched');
                      //     // Navigator.pop(
                      //     //   context,
                      //     // );
                      //     bottomNavigationProvider.changeView(HomeView.home);
                      //      browserModel.showTabScroller = false;
                      //     provider.openTab(
                      //       context,//result.group,
                      //       tab,
                      //     );
                      //   },
                      // );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void showGroupDialog(
  BuildContext context,
  GroupModel group,
) {

  showGeneralDialog(

    context: context,

    barrierDismissible: true,

    barrierLabel: "Group",

    pageBuilder:
        (_, __, ___) {

      return Center(

        child: Material(

          child: Container(

            width:
                MediaQuery.of(
                      context,
                    )
                        .size
                        .width *
                    0.9,

            height:
                MediaQuery.of(
                      context,
                    )
                        .size
                        .height *
                    0.75,

            child: GroupScreen(
              group: group,
            ),
          ),
        ),
      );
    },
  );
}