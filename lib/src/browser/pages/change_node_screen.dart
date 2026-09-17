import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/appbar_position_provider.dart';
import 'package:beldex_browser/src/browser/providers/bottom_nav_bar_provider.dart';
import 'package:beldex_browser/src/browser/providers/node_provider.dart';
import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart'
    as exitNodeModel;
import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart';
import 'package:beldex_browser/src/model/exitnodeRepo.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isOpen = false;


class ChangeNodePage extends StatefulWidget {
  final List<exitNodeModel.ExitNodeDataList> exitData;
  final bool canChangeNode;
  final InAppWebViewController? webViewController;
  const ChangeNodePage({super.key, required this.exitData, required this.canChangeNode, this.webViewController});

  @override
  State<ChangeNodePage> createState() => _ChangeNodePageState();
}

class _ChangeNodePageState extends State<ChangeNodePage> //with WidgetsBindingObserver
{
  String exitNode = '';
  String exitIcon = '';
  String selectedValue =
      'exit.bdx';
  String selectedConIcon =
      "assets/images/flags/France.png";
  // List<exitNodeModel.ExitNodeDataList> exitData = [];
  OverlayEntry? overlayEntry;
  List ids = [];
  var selectedId;
 bool canShowWarning = false;

   bool isChangeNodeEnable = false;
  bool isSameNode = false;

  late Timer timers;

  AppLifecycleState states = AppLifecycleState.resumed;
  List<exitNodeModel.ExitNodeDataList> randomNodeData = [];
    List<exitNodeModel.ExitNodeDataList> exitData1 = [];
  String randomNode = '';
  String randomNodeFlag = '';
  StreamSubscription<bool>? isConnectedEventSubscription;



final List<String> tabTypes = ['Beldex Official', 'Contributor exit node'];
  String selectedType = 'Beldex Official';


late String connectednode;


int selectedTab = 0;
 late StreamSubscription<List<ConnectivityResult>> _networkSubscription;

bool isNoNetwork = false;

  @override
  void initState() {
   // WidgetsBinding.instance.addObserver(this);
   getExitnodeList();
    displayExitNode();
   // saveData();
      isConnectedEventSubscription = BelnetLib.isConnectedEventStream
        .listen((bool isConnected) { 
          if(mounted){
            setState(() {
              //print('is belnet app connected ? $isConnected');
              setVPNStatus(context, isConnected);
            });
          }
           
        }
            );
            getConnectedNode();


            _networkSubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.wifi) &&
      !results.contains(ConnectivityResult.mobile)) {

     setState(() {
       isNoNetwork = true;
     });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("You are not connected to the internet"),
        //   ),
        // );
      }else{
        setState(() {
          isNoNetwork = false;
        });
      }
    });
    // getRandomExitData();
    super.initState();
  }



getConnectedNode()async{
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    
  connectednode = prefs.getString('selectedExitNode') ?? '';
  });

}




  //List<exitNodeModel.ExitNodeDataList> exitData1 = [];
//List<exitNodeModel.ExitNodeDataList> exitData = [];




int count = 0;

  void setVPNStatus(BuildContext context, bool isConnected) async {

    bool val = await BelnetLib.isRunning;
    final vpnStatusProvider =
        Provider.of<VpnStatusProvider>(context, listen: false);
 if(mounted){
    setState(() {
      //  if (vpnStatusProvider.value == 'Connected' //&& vpnStatusProvider.isChangeNode == true 
      //  ) {
      //   Future.delayed(Duration(milliseconds: 300), () {
      //     if (isConnected == false) {
      //       //  print('belnet is disconnected');
      //       SystemNavigator.pop();
      //     }
      //  });
      // } else 
      if (vpnStatusProvider.value == 'Connecting...' && vpnStatusProvider.isChangeNode == true && vpnStatusProvider.canClose == true) {
       print('Connecting1 val $val -- $count');
        print('Connecting 222111 $val -- ${vpnStatusProvider.state}');
        if(val == false && vpnStatusProvider.state != null && (vpnStatusProvider.state == AppLifecycleState.inactive || vpnStatusProvider.state == AppLifecycleState.paused)){
          print('Connecting 11111111 $val -- ${vpnStatusProvider.state}');
           SystemNavigator.pop();
        }else if (val == true) {
          count = 1;
        }
        if (count == 1) {
          print('Connecting 2 val $val -- $count');
          if (val == false) {
            print('Connecting 3 val $val -- $count');
             exit(0);
            //SystemNavigator.pop();
          }
        }
      }
    });
  }
  }

void simulateDelayedProgress(
      LoadingtickValueProvider loadingtickValueProvider) {
    const totalDuration = Duration(seconds: 5);
    const updateInterval = const Duration(milliseconds: 100);

    int totalTicks =
        totalDuration.inMilliseconds ~/ updateInterval.inMilliseconds;

    timers = Timer.periodic(updateInterval, (timer) {
      if (loadingtickValueProvider.progressValue < 1.0) {
        setState(() {
          loadingtickValueProvider.updateProgressValue(1.0 / totalTicks);
        });
      } else {
        timer.cancel();
      }
    });
  }

// @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // TODO: implement didChangeAppLifecycleState
//      final vpnStatusProvider =
//         Provider.of<VpnStatusProvider>(context, listen: false);
//         setState(() {
//           states = state;
//         });
//     super.didChangeAppLifecycleState(state);
//     switch(state){ 
//       case AppLifecycleState.detached:
//       print('$state Connecting value ${vpnStatusProvider.value} -- changeNode ${vpnStatusProvider.isChangeNode} can close ${vpnStatusProvider.canClose}');
//         // TODO: Handle this case.
//         break;
//       case AppLifecycleState.resumed:
//         // TODO: Handle this case.
//         print('$state Connecting value ${vpnStatusProvider.value} -- changeNode ${vpnStatusProvider.isChangeNode} can close ${vpnStatusProvider.canClose}');
//         break;
//       case AppLifecycleState.inactive:
//         // TODO: Handle this case.
//         print('$state Connecting value ${vpnStatusProvider.value} -- changeNode ${vpnStatusProvider.isChangeNode} can close ${vpnStatusProvider.canClose}');
//         break;
//       case AppLifecycleState.hidden:
//         // TODO: Handle this case.
//         print('$state Connecting value ${vpnStatusProvider.value} -- changeNode ${vpnStatusProvider.isChangeNode} can close ${vpnStatusProvider.canClose}');
//         break;
//       case AppLifecycleState.paused:
//         // TODO: Handle this case.
//         print('$state Connecting value ${vpnStatusProvider.value} -- changeNode ${vpnStatusProvider.isChangeNode} can close ${vpnStatusProvider.canClose}');
//         break;

//     }
//   }


void getExitnodeList()async{
  try{
    final prefs = await SharedPreferences.getInstance();
   // var res = prefs.getString('allExitnodeList');
    // var res = await DataRepo().getListData();
    String? jsonString = prefs.getString('allExitnodeList');
    if(jsonString!.isNotEmpty)
       randomNodeData.addAll(exitNodeDataListFromJson(jsonString));
       exitData1.addAll(exitNodeDataListFromJson(jsonString));
      print('Change node getExitnodeList ---- ${randomNodeData.length}');
      setState(() {
        
      });
    // getRandomExitnode();
  }catch(e){
    print('Exception getExitnodeList $e');
  }
}


void getRandomExitnode() async {
    try {
      // var res = await DataRepo().getListData();
      // randomNodeData.addAll(res);
    print('Change node getRandomeExitnode 1 $randomNode -- $exitNode');
      if (randomNodeData.isNotEmpty) {
        print('Change node getRandomeExitnode 2 $randomNode -- $exitNode');
        var randomNodeList;
        var randomNodeIndex;
        var newNode;
        do {
          print('Change node getRandomeExitnode 3 $randomNode -- $exitNode');
          var randomIndex = Random().nextInt(randomNodeData.length);
          randomNodeList = randomNodeData[randomIndex].node;
          if (randomNodeList.isNotEmpty) {
            randomNodeIndex = Random().nextInt(randomNodeList.length);
            newNode = randomNodeList[randomNodeIndex].name;
          }
        } while (randomNodeList.isEmpty || newNode == exitNode);
         print('Change node getRandomeExitnode 4 $randomNode -- $exitNode');
        setState(() {
          randomNode = newNode;
          randomNodeFlag = randomNodeList[randomNodeIndex].icon;
         // exitNode = randomNode;
         print('Change node getRandomeExitnode 5 $randomNode -- $exitNode');
        });
      }
      //setRandomNode();
    } catch (e) {
      print('Exception on random selection $e');
    }
  }

Future toggleBelnet(VpnStatusProvider vpnStatusProvider,LoadingtickValueProvider loadingtickValueProvider,WebViewModel webViewModel,AppLocalizations loc, LocaleProvider localeProvider,BottomNavigationProvider bottomNavigationProvider,AppBarPositionProvider appBarPositionProvider)async {
    //getRandomExitnode();
   // setRandomNode();
  //  if(isSameNode){
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('This node is already selected.Please select another one from the list')));

  //  }else{

  if(!isSameNode){
     final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedExitNode', '$exitNode');
      await prefs.setString('selectedCountryIcon', '$exitIcon');
    changeNode(vpnStatusProvider,loadingtickValueProvider,webViewModel,loc,localeProvider,bottomNavigationProvider,appBarPositionProvider); 
   }
    
  }



Future disconnectVpn(VpnStatusProvider vpnStatusProvider)async{
  try{
     vpnStatusProvider.updateChangeNodevalue(true);  
    await BelnetLib.disconnectFromBelnet();
    vpnStatusProvider.updateValue('Disconnected');
  }catch(e){
     print('Exception disconnectVpn $e');
  }
}

showWarning()async{
   setState(() {
    canShowWarning = true;
  Future.delayed(const Duration(seconds: 14),(){
      canShowWarning = false;
  });
  });
}


Future changeNode(VpnStatusProvider vpnStatusProvider, LoadingtickValueProvider loadingtickValueProvider,WebViewModel webViewModel,AppLocalizations loc,LocaleProvider localeProvider,BottomNavigationProvider bottomNavigationProvider,AppBarPositionProvider appBarPositionProvider)async {
    try{
      // if (BelnetLib.isConnected == false) {
      setState(() {
        isChangeNodeEnable = false;
      });
      //showWarning();
      vpnStatusProvider.updateChangeNodevalue(true);    
      vpnStatusProvider.updateValue('Connecting...');  
      simulateDelayedProgress(loadingtickValueProvider);   
     //  await BelnetLib.disconnectFromBelnet();
      //Future.delayed(Duration(seconds: 2),()async{
       // if (disconnect) {
        // final prepare = await BelnetLib.prepareConnection();
        // if (prepare) {
           final status = await BelnetLib.unmapExitNode(exitNode);
         print('Print the exception whether un map ---> $status');
          print('Change node ------> Exitnode $exitNode');
          // await BelnetLib.connectToBelnet(
          //     exitNode: exitNode, //customExitnode,
          //     upstreamDNS: "9.9.9.9");
         vpnStatusProvider.updateCanClose(true);
         Future.delayed(Duration(seconds: 5), () async{
         vpnStatusProvider.updateValue('Connected');
         vpnStatusProvider.updateChangeNodevalue(false);
         vpnStatusProvider.updateCanClose(false);
         showMessage(loc.exitNodeSwitched
                //'Exit node switched successfully'
                );
         if(widget.webViewController != null){
          print('Comes INSIDE THE Changenode ${webViewModel.url.toString()}');
          //var dds = widget.webViewController!.getUrl().toString();
            widget.webViewController!.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri(webViewModel.url.toString()),
                          headers: {
            "Accept-Language": localeProvider.fullLocaleId,
          },
                          ));

          // print('THE RELOAD URL IN HERE IS ---- $dds');
          // await widget.webViewController!.reload();
         }
         if(appBarPositionProvider.selectedPosition == AppBarPosition.bottom){
             Navigator.pop(context,true);
         }else{
           bottomNavigationProvider.changeIndex(0);
         }
         
        //
          if(BelnetLib.isConnected != true || await BelnetLib.isRunning == false){
              SystemNavigator.pop();
          }
         setState(() {
           isChangeNodeEnable = false;
         });
      });
      //  }
     //}
   // }
     // });
       
    }catch(e){
      print('Exception while changing node $e');
    }
    
  }


void setRandomNode() async {
    try{
     final prefs = await SharedPreferences.getInstance();
    setState(() {});
    if(randomNode != '')
    await prefs.setString('selectedExitNode', randomNode);
    if(randomNodeFlag != '')
    await prefs.setString('selectedCountryIcon', randomNodeFlag);
    displayExitNode();
    }catch(e){
      print('Exception setRandomnode() $e');
    }
    
  }





  saveData() async {
    if (exitData1.isNotEmpty) {
      setState(() {
        exitData1 = [];
      });
    }
    var res = await DataRepo().getListData();
    exitData1.addAll(res);
    setState(() {});
  }

  displayExitNode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
    exitNode = prefs.getString('selectedExitNode') ?? '';
    exitIcon = prefs.getString('selectedCountryIcon') ?? '';
    print('exitnode icon here $exitIcon');
  }

// getRandomExitData()async{
// // SharedPreferences preferences = await SharedPreferences.getInstance();
//    if (BelnetLib.isConnected == false) {
//       print(
//           "inside getRandomExitData function the belnetlib is false ${BelnetLib.isConnected}");
//       var responses = await DataRepo().getListData();
//       exitData.addAll(responses);
//       setState(() {
//         exitData.forEach((element) {
//           element.node.forEach((elements) {
//             ids.add(elements.id);
//           });
//         });

//         final random = Random();
//         selectedId = ids[random.nextInt(ids.length)];
//       });

//       setState(() {
//         // exitData.forEach((element) {
//         //   element.node.forEach((element) {
//         //     if (selectedId == element.id) {
//         //       selectedValue = element.name;
//         //       selectedConIcon = element.icon;
//         //       print("icon id value $selectedId");
//         //       print("selected exitnode value $selectedValue");
//         //       print("icon image url : ${element.icon}");
//         //     }
//         //   });
//         // });

//     //  preferences.setString('selectedExitNode','$selectedValue');
//     //  preferences.setString('selectedCountryIcon','$selectedConIcon');
//         // if(BelnetLib.isConnected == false){
//         // preferences.setString('hintValue',selectedValue!);
//         // preferences.setString('hintContryicon',selectedConIcon!);
//         // }
//       });

//     }
// }

  @override
  void dispose() {
    overlayEntry?.remove();
      // WidgetsBinding.instance.removeObserver(this);
    isConnectedEventSubscription!.cancel();
    _networkSubscription.cancel();
    super.dispose();
  }

  Future<bool?> resetLayOut() async {
    setState(() {
      isSet = false;
    });
    overlayEntry!.remove();
    return true;
  }

//  onWillPop: () async{
//          if(isSet){
//           bool? result = await resetLayOut();
//           if(result != null && result){
//             return true;
//           }else{
//             return true;
//           }
//          }
//          return true;

  bool isSet = true;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context); 
    double mHeight = MediaQuery.of(context).size.height;
     final loc = AppLocalizations.of(context)!;
     final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);
     final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context); 
    final theme = Theme.of(context);
        //   final provider =
        // context.watch<NodeProvider>();

    // if (provider.isLoading) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }


if (exitData1.isEmpty || selectedTab >= exitData1.length) {
  return SizedBox();
  // const Center(
  //   child: CircularProgressIndicator(),
  // );
}

//List<Node> currentNodes = exitData1[selectedTab].node;


// Current Selected Type
    List<Node> currentNodes =
        exitData1[selectedTab].node;

    /// Group By Country
    Map<String, List<Node>> groupedNodes = {};

    for (var node in currentNodes) {
      groupedNodes.putIfAbsent(
        node.country,
        () => [],
      );

      groupedNodes[node.country]!.add(node);
    }






    return WillPopScope(
      onWillPop: () async {
            if (vpnStatusProvider.isChangeNode) {
      return false; // Prevent pop if isChangeNode is true
    }
        // if (isSet) {
        //   Future.delayed(Duration(milliseconds: 100), () async {
        //     bool? val = await resetLayOut();
        //     if (val != null && val == true) {
        //       return true;
        //     } else {
        //       return true;
        //     }
        //   });
        // }
        return true;
      },
      child: Stack(
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
              resizeToAvoidBottomInset: true,
          
              backgroundColor: Colors.transparent,
              appBar: _appBar(themeProvider,vpnStatusProvider,loc,bottomNavigationProvider,appBarPositionProvider),
              body: _scaffoldBody(mHeight, themeProvider,loc,groupedNodes),
               
          
          //      Column(
          //       children: [
          
          //         /// Tabs
          //         /// 
          //         /// 
          //         /// 
            
          
          //  Container(
          //               height: 50,width: double.infinity,
          //               padding: EdgeInsets.symmetric(horizontal:  10,vertical: 3),
          //               decoration: BoxDecoration(
          //                 border: Border.all(color: Color(0xff333333))
          //               ),
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children:
          //           //        [
          //           //         Expanded(
          //           //     child: 
          //           //     // _tabButton(
          //           //     //   context,
          //           //     //   "Beldex Nodes",
          //           //     //   provider.beldexNodes.length,
          //           //     //   provider.selectedTab == 0,
          //           //     //   () => provider.changeTab(0),
          //           //     // ),
          //           //   ),
          
          //           //  // const SizedBox(width: 10),
          
          //           //   Expanded(
          //           //     child: _tabButton(
          //           //       context,
          //           //       "Contributor Nodes",
          //           //       provider.contributorNodes.length,
          //           //       provider.selectedTab == 1,
          //           //       () => provider.changeTab(1),
          //           //     ),
          //           //   ),
              
          //           //       ]
          //                  List.generate(tabTypes.length * 2 - 1, (index) {
          //         if (index.isOdd) {
          //     // Insert spacing between items
          //     return SizedBox(width: 8); // or any width you want
          //         } else {
          //     final type = tabTypes[index ~/ 2];
          //     final isSelected = type == selectedType;
          //    // final count = nodeProvider.getNodeCount(type);
          //     return Expanded(
          //       child: GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             selectedType = type;
          //           });
          
          //           if(provider.selectedTab == 0){
          //             provider.changeTab(0);
          //           }else if(provider.selectedTab == 1){
          //              provider.changeTab(1);
          //           }
          //         },
          //         child: Container(
          //           padding: EdgeInsets.all(9),
          //           decoration: BoxDecoration(
          //             color: isSelected ? themeProvider.darkTheme ? Colors.black : Color(0xffffffff) : themeProvider.darkTheme ? Color(0xff444444).withOpacity(0.4) : Color(0xffD4D4D4).withOpacity(0.4),
          //          border: Border.all(color: isSelected ? themeProvider.darkTheme ? Colors.white : Colors.black : Colors.transparent,width: 0.3)
          //           ),
          //           child: Row(
          //             children: [
          //               Text(    type == "Contributor exit node" ? "Contributor nodes" : type,style: TextStyle(fontSize: 12,color:isSelected ?themeProvider.darkTheme ? Colors.white : Colors.black : themeProvider.darkTheme ?  Color(0xff8D8D8D): Colors.black,fontFamily: 'Inter'),),
          //              Text(type == "Contributor exit node" ? provider.contributorNodes.length.toString() : provider.beldexNodes.length.toString() ,style: TextStyle(fontSize: 12,color:isSelected ?themeProvider.darkTheme ? Colors.white : Colors.black : themeProvider.darkTheme ?  Color(0xff8D8D8D): Colors.black,fontFamily: 'Inter'),),
          
          //             ],
          //           ),
          //         )
            
            
          //       ),
          //     );
          //         }
          //       }
          
          //       ),
          //               ),
          //             ),
          
          
          
          
          
          
          
          
          
          
          //         // Row(
          //         //   children: [
          //         //     Expanded(
          //         //       child: _tabButton(
          //         //         context,
          //         //         "Beldex Nodes",
          //         //         provider.beldexNodes.length,
          //         //         provider.selectedTab == 0,
          //         //         () => provider.changeTab(0),
          //         //       ),
          //         //     ),
          
          //         //     const SizedBox(width: 10),
          
          //         //     Expanded(
          //         //       child: _tabButton(
          //         //         context,
          //         //         "Contributor Nodes",
          //         //         provider.contributorNodes.length,
          //         //         provider.selectedTab == 1,
          //         //         () => provider.changeTab(1),
          //         //       ),
          //         //     ),
          //         //   ],
          //         // ),
          
          //         const SizedBox(height: 12),
          
          //         // Expanded(
          //         //   child: ListView.builder(
          //         //     itemCount:
          //         //         provider.groupedNodes.length,
          //         //     itemBuilder: (context, index) {
          
          //         //       final country =
          //         //           provider.groupedNodes.keys
          //         //               .elementAt(index);
          
          //         //       final iconCountry = country.toLowerCase(); 
          
          //         //       final nodes =
          //         //           provider.groupedNodes[country]!;
          
          //         //       return Column(
          //         //         crossAxisAlignment:
          //         //             CrossAxisAlignment.start,
          //         //         children: [
          
          //         //           /// Country Header
          //         //           Padding(
          //         //             padding:
          //         //                 const EdgeInsets.symmetric(
          //         //               vertical: 10,
          //         //             ),
          //         //             child: Row(
          //         //               children: [
          //         //                  Image.asset('assets/images/flags/$iconCountry.png'),
          //         //                 // Image.network(
          //         //                 //   nodes.first["icon"],
          //         //                 //   width: 18,
          //         //                 //   height: 18,
          //         //                 //   errorBuilder:
          //         //                 //       (_, __, ___) =>
          //         //                 //           const SizedBox(),
          //         //                 // ),
          
          //         //                 const SizedBox(width: 8),
          
          //         //                 Text(
          //         //                   country,
          //         //                   style:
          //         //                       const TextStyle(
          //         //                     fontSize: 16,
          //         //                     color:
          //         //                         Color(0xff808080),
          //         //                   ),
          //         //                 ),
          //         //               ],
          //         //             ),
          //         //           ),
          
          //         //           ...nodes.map(
          //         //             (node) =>
          //         //                 _nodeTile(
          //         //                   context,
          //         //                   node,
          //         //                 ),
          //         //           ),
          //         //         ],
          //         //       );
          //         //     },
          //         //   ),
          //         // ),
          
          
          
          
          
          
          
          
          //       ],
          //     ),
              
              ),
       
       vpnStatusProvider.isChangeNode && appBarPositionProvider.selectedPosition == AppBarPosition.bottom ?  
        Positioned.fill(child: Material(
          color:themeProvider.darkTheme ? Color(0xff0B0B0B).withOpacity(0.6) : Color(0xffFFFFFF).withOpacity(0.6),
          child: Center(
            child: 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassSettingPanel(
                color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffFFFFFF).withOpacity(0.1),
                
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4))),
                  padding: EdgeInsets.symmetric(horizontal:  10, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     // Image.asset('assets/images/ai-icons/new/Loading.gif')
                     //Text('Connecting...',),
                     
                      Container(
                        height: 28,width: 28,
                        child: CircularProgressIndicator(
                          //padding: EdgeInsets.all(5),
                          color:themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),strokeWidth: 2,),
                      ),
                      SizedBox(height: 10,),
                      Text('${loc.changingNode}', overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(fontSize: 18,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) :Color(0xff737373)),)
                    ],
                  ),
                ),
              ),
            ),
          ),
        )):SizedBox()
       
        ],
      ),
    );
  }



Future<bool> hasNetwork() async {
  final connectivityResult = await Connectivity().checkConnectivity();

  return !connectivityResult.contains(ConnectivityResult.none);
}

Widget _nodeTile(
  BuildContext context,
  Node node,AppLocalizations loc, WebViewModel webViewModel
) {
  // final provider =
  //     context.watch<NodeProvider>();
  final themeProvider = Provider.of<DarkThemeProvider>(context);
final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
final loadingtickValueProvider = Provider.of<LoadingtickValueProvider>(context);
//final webViewModel = Provider.of<WebViewModel>(context);
final localeProvider = Provider.of<LocaleProvider>(context);
final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context); 
final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context);
String selectedNode = connectednode;
  // final isSelected =
  //     provider.selectedNodeId ==
  //         node.id;



  return InkWell(
    onTap: ()async {
     
// bool connectedToInternet = await hasNetwork();
     
      final prefs = await SharedPreferences.getInstance();
      String connectednode = prefs.getString('selectedExitNode') ?? '';

      
       setState(() {
         isSameNode = exitNode == node.name;
         //selectedNode = node.name;
       });
        

      if(isNoNetwork){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(loc.youAreNotConnectedToInternet //"Please enable mobile data or wifi and retry"
                    )));
        return;
      }

       if(connectednode == node.name){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(loc.thisNodeAlreadySelected)));
       }else{
        showDialog(
      context: context,
      barrierColor:  themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
          
          child: GlassSettingPanel(
           color: themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.8) : Color(0xffEBEBEB) ,
            child: Container(
             // width: MediaQuery.of(context).size.width,
              //height: 185,#1A1A1ACC
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                  //color: Colors.transparent
                  // themeProvider.darkTheme
                  //     ? Color(0xff282836)
                  //     : Color(0xffFFFFFF),
                  // borderRadius: BorderRadius.circular(15)
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text( loc.switchingNode,
                     // 'Switching Node',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: 'Inter'),textAlign: TextAlign.center,
                    ),
                  ),
                  Text( loc.doYouWantToSwitch,
                    //'Do you want to switch with the selected node?',
                    style: TextStyle(fontWeight: FontWeight.w500,color: themeProvider.darkTheme ?  Color(0xffACACAC) : Color(0xff737373)),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                          child: MaterialButton(
                            elevation: 0,
                            color:themeProvider.darkTheme ? Color(0xff333333)  : Color(0xffDEDEDE),
                                  disabledColor: Color(0xff2C2C3B),
                            minWidth: double.maxFinite,
                            height: 50,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                            ),
                            child: Text( loc.cancel,// 'Cancel',
                                style: TextStyle(fontSize: 16,fontFamily: 'Inter',fontWeight: FontWeight.w900,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff444444))),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(
                            //       10.0), // Adjust the radius as needed
                            // ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: MaterialButton(
                            elevation: 0,
                             color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),
                                  disabledColor: Color(0xff2C2C3B),
                            minWidth: double.maxFinite,
                            height: 50,
                            shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  ),

                            child: Text(loc.connect, //'Connect',
                                style:
                                    TextStyle(color:themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffEBEBEB),fontWeight: FontWeight.w900, fontSize: 16,fontFamily: 'Inter')),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(
                            //       10.0), // Adjust the radius as needed
                            // ),
                            onPressed: () async {
                              // disconnectVpn(vpnStatusProvider);
                              final prefs = await SharedPreferences.getInstance();
            
               setState(() {
                  // selectedNode = connectednode;
                   exitNode = node.name;
                   exitIcon = 'assets/images/flags/${node.country}.png';
                   
               });
                       await prefs.setString('selectedExitNode', exitNode);
                      await prefs.setString('selectedCountryIcon',exitIcon );
            
            print('THE SWICH NODE IS $selectedNode ----- $connectednode  ------ ${node.name} ---- $exitNode');
                                      toggleBelnet(vpnStatusProvider,loadingtickValueProvider,webViewModel,loc,localeProvider,bottomNavigationProvider,appBarPositionProvider);
                                    // resetSettings();
                                     Navigator.pop(context);
            
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );});

       }
      // provider.selectNode(
      //   node.id,
      // );
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom:10.0),
      child: GlassSettingPanel(
        color: exitNode == node.name ? themeProvider.darkTheme ? Color(0xff00DC00).withOpacity(0.05) : Color(0xff00DC00).withOpacity(0.1) : themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.5) : Color(0xffFFFFFF).withOpacity(0.7),
        child: Container(
          // margin: const EdgeInsets.only(
          //   bottom: 10,
          // ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: exitNode == node.name
                  ? Colors.green
                  : themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4),width: 0.5
                  // const Color(
                  //     0xffD9D9D9,
                  //   ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      maxLines: 1,
                      style: TextStyle(fontFamily: 'Poppins',fontSize: 13),
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                    Text(
                    node.country,
                    maxLines: 1,
                    style: TextStyle(fontFamily: 'Poppins',fontSize: 10,color: themeProvider.darkTheme ? Color(0xffACACAC) : Color(0xff737373)),
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                  ],
                ),
              ),
              
        
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      node.isActive == "true"
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _tabButton({
  required String title,
  required int count,
  required bool selected,
  required VoidCallback onTap,
}) {
  final themeProvider = Provider.of<DarkThemeProvider>(context);
  final loc = AppLocalizations.of(context)!;
  return InkWell(
    onTap: onTap,
    child: Container(
      //height: 45,
      padding:
          const EdgeInsets.all(
        9,
      ),
      decoration: BoxDecoration(
        color: selected ?
            themeProvider.darkTheme ? Colors.black : Color(0xffffffff) : themeProvider.darkTheme ? Color(0xff444444).withOpacity(0.4) : Color(0xffD4D4D4).withOpacity(0.4),
        border: Border.all(color: selected ? themeProvider.darkTheme ? Colors.white : Colors.black : Colors.transparent,width: 0.3)
        // border: Border.all(
        //   color: const Color(0xffD9D9D9),
        // ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text( title == "Contributor exit node" ? "${loc.contributorExitNode}" : "${loc.beldexofficial}",style: TextStyle(fontSize: 12,color:selected ?themeProvider.darkTheme ? Colors.white : Colors.black : themeProvider.darkTheme ?  Color(0xff8D8D8D): Colors.black,fontFamily: 'Inter'),overflow: TextOverflow.ellipsis,maxLines: 1,)),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 12,color:selected ?themeProvider.darkTheme ? Colors.white : Colors.black : themeProvider.darkTheme ?  Color(0xff8D8D8D): Colors.black,fontFamily: 'Inter',fontWeight: selected ? FontWeight.w900 : FontWeight.w400),
          ),
        ],
      ),
    ),
  );
}





  AppBar _appBar(DarkThemeProvider themeProvider,VpnStatusProvider vpnStatusProvider,AppLocalizations loc,BottomNavigationProvider bottomNavigationProvider,AppBarPositionProvider appBarPositionProvider) {
    return AppBar(
      backgroundColor: Colors.transparent,
     // leading:vpnStatusProvider.isChangeNode ? Container() : 
      automaticallyImplyLeading: false,
      // IconButton(
      //   icon: SvgPicture.asset(
      //     'assets/images/back.svg',
      //     color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
      //     height: 25,
      //   ),
      //   onPressed: () {if(appBarPositionProvider.selectedPosition == AppBarPosition.bottom) {
      //     Navigator.pop(context);
          
      //   }else{
      //     bottomNavigationProvider.changeIndex(0);
      //   }
      //   },//  Navigator.pop(context),
      // ),
      leadingWidth:0 ,
     // automaticallyImplyLeading: false,
      title:
          Row(
            children: [
      GestureDetector(
        onTap:vpnStatusProvider.isChangeNode ? null : (){
            if(appBarPositionProvider.selectedPosition == AppBarPosition.bottom) {
          Navigator.pop(context);
          
        }else{
          bottomNavigationProvider.changeIndex(0);
        }
        },
        child: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
            height: 24,
          ),
      ),
        SizedBox(width: 5,),
      // IconButton(
      //   icon: SvgPicture.asset(
      //     'assets/images/back.svg',
      //     color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
      //     height: 25,
      //   ),
      //   onPressed: () {if(appBarPositionProvider.selectedPosition == AppBarPosition.bottom) {
      //     Navigator.pop(context);
          
      //   }else{
      //     bottomNavigationProvider.changeIndex(0);
      //   }
      //   },//  Navigator.pop(context),
      // ),
              Text(loc.changeNode, //'Change Node', 
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w900,fontFamily: 'Inter')),
            ],
          ),
    );
  }

 Widget _scaffoldBody(double mHeight, DarkThemeProvider themeProvider,AppLocalizations loc, Map<String, List<Node>> groupedNodes) {
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loadingtickValueProvider = Provider.of<LoadingtickValueProvider>(context);
     var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    final mheight = MediaQuery.of(context).size.height;
    final localeProvider = Provider.of<LocaleProvider>(context);
    //final provider = Provider.of<NodeProvider>(context);



    



    return Center(
      child: LayoutBuilder(builder: (context, constraint) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: [

            Container(
                            height: 50,width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal:  10,vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color:themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4))
              ),
              child: 
              Row(
  children: List.generate(
    exitData1.length * 2 - 1,
    (index) {
      if (index.isOdd) {
        return const SizedBox(width: 10);
      }

      final actualIndex = index ~/ 2;

      return Expanded(
        child: _tabButton(
          title: exitData1[actualIndex].type,
          count: exitData1[actualIndex].node.length,
          selected: selectedTab == actualIndex,
          onTap: () {
            setState(() {
              selectedTab = actualIndex;
            });
            //provider.changeTab(actualIndex);
          },
        ),
      );
    },
  ),
)
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: List.generate(
              //     exitData1.length * 2 - 1,
              //     (index) {
              //       if(index.isOdd){
              //        return SizedBox(height: 5,);
              //       }else{

                    
              //       return Expanded(
              //         child: 
              //         _tabButton(
              //           title: exitData1[index].type,
              //           count: exitData1[index].node.length,
              //           selected:
              //   provider.selectedTab ==
              //       index,
              //           onTap: () {
              // provider.changeTab(
              //   index,
              // );
              //           },
              //         ),
              //       );}
              //     },
              //   ),
              // ),
            ),
            // SizedBox(height: constraint.maxHeight / 12),
            // const Text(
            //   'Beldex Network is a cutting-edge decentralized blockchain at the forefront of privacy-centric blockchain technology. The Beldex browser\n is built atop the Beldex Network.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            // ),
            // SizedBox(height: constraint.maxHeight / 9.5),

            // Padding(
            //   padding:
            //       EdgeInsets.symmetric( vertical:mheight*0.15/3 ),
            //   child:Container(
            //    // color: Colors.yellow,
            //     child: SvgPicture.asset(
            //       themeProvider.darkTheme ?
            //       'assets/images/change_node_icon.svg'
            //       : 'assets/images/change_node_icon_white.svg',
            //       width: constraint.maxWidth / 2.2,
            //     ),
            //   ),
            // ),
            
            
            
             Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GlassSettingPanel(
              color:themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.4) : Color(0xffFFFFFF).withOpacity(0.4),
              child: Container(
                //margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4),width: 1)
                ),
                child: ListView(
                  children: groupedNodes.entries.map(
                    (entry) {
                
                      final country = entry.key;
                      final nodes = entry.value;
                
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                
                          /// COUNTRY HEADER
                          Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                Image.asset('assets/images/flags/$country.png',
                                width: 18,height: 18,
                                ),
                                // Image.network(
                                //   nodes.first.icon,
                                //   width: 18,
                                //   height: 18,
                                //   errorBuilder:
                                //       (_, __, ___) =>
                                //           const SizedBox(),
                                // ),
                
                                const SizedBox(width: 8),
                
                                Text(
                                  country,
                                  style:
                                       TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    color:themeProvider.darkTheme ? Colors.white : Colors.black
                                       // Color(0xff808080),
                                  ),
                                ),
                              ],
                            ),
                          ),
                
                          /// NODES
                          ...nodes.map(
                            (node) => _nodeTile(
                              context,
                              node,loc,webViewModel
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),),
            
            
            
            
            
//             Column(
//               children: [
//                 Container(
//                   height: constraint.maxHeight / 4, //170,
//                   margin:const EdgeInsets.all(15),
//                   padding:const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: themeProvider.darkTheme
//                           ?const Color(0xff282836)
//                           :const Color(0xffF3F3F3)),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return Center(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(loc.exitnode,
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 )),
//                            const SizedBox(
//                               height: 15,
//                             ),
//                             vpnStatusProvider.value == 'Connecting...'
//                                 ? 
//                                 Align(
//                                     alignment: Alignment.center,
//                                     child: Container(
//                                         height: MediaQuery.of(context).size.height *
//                                             0.19 /
//                                             3,
//                                         decoration: BoxDecoration(
//                                             color: themeProvider.darkTheme
//                                                 ?const Color(0xff39394B)
//                                                 :const Color(0xffFFFFFF),
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(5))),
//                                         child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 4.0,
//                                                 right: 6.0,
//                                                 top: 3.0,
//                                                 bottom: 5.0),
//                                             child: Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                     margin: EdgeInsets.symmetric(
//                                                            vertical: 12.0,horizontal: 15),
//                                                     // margin:EdgeInsets.only(right:mHeight*0.03/3,),
//                                                     child: exitIcon != '' ||
//                                                             exitIcon.isNotEmpty
//                                                         ? Image.asset(exitIcon,
//                                                         errorBuilder:
//                                                                   (context, error,
//                                                                       stackTrace) {
                                                                        
//                                                                 return Icon(Icons
//                                                                     .broken_image);
//                                                               },
//                                                         )
//                                                         : Icon(
//                                                             Icons.more_horiz,
//                                                             color: Colors.grey,
//                                                           )),
//                                                 Expanded(
//                                                     child: Text("$exitNode",
//                                                         overflow:
//                                                             TextOverflow.ellipsis,
//                                                         maxLines: 1,
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Color(0xff00DC00)))),
//                                               // BelnetLib.isConnected == false ? 
//                                               //  Icon(
//                                               //     Icons.arrow_drop_down,
//                                               //     color: Colors.grey,
//                                               //   )//: Container()
//                                               ],
//                                             ))),
//                                   )
//                                 : 
//                                 Align(
//                                     alignment: Alignment.center,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         try {
//                                           setState(() {
//                                             isOpen = isOpen ? false : true;
//                                           });
//                                           if (isOpen &&
//                                               (exitData1.isEmpty ||
//                                                   exitData1 == [])) {
//                                             //exitData.clear();
//                                             print(
//                                                 'cleared the data ${exitData1.length}');
//                                             //saveData();
//                                             //saveCustomForUse();   //hide for version 1.2.0
//                                           } else {
//                                             // saveData();
//                                             OverlayState? overlayState =
//                                                 Overlay.of(context);
//                                             overlayEntry = OverlayEntry(
//                                               builder: (context) {
//                                                 return _buildExitnodeListView(
//                                                     mHeight, themeProvider,vpnStatusProvider,loc);
//                                               },
//                                             );
//                                             overlayState.insert(overlayEntry!);
//                                           }
//                                         } catch (e) {
//                                           print('Exception $e');
//                                         }
//                                       },
//                                       child: Container(
//                                           height:
//                                               MediaQuery.of(context).size.height *
//                                                   0.19 /
//                                                   3,
//                                           decoration: BoxDecoration(
//                                               color: themeProvider.darkTheme
//                                                   ?const Color(0xff39394B)
//                                                   :const Color(0xffFFFFFF),
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(5))),
//                                           child: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0,
//                                                   right: 6.0,
//                                                   top: 3.0,
//                                                   bottom: 5.0),
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Container(
//                                                       margin: EdgeInsets.symmetric(
//                                                            vertical: 12.0,horizontal: 10),
//                                                       // margin:EdgeInsets.only(right:mHeight*0.03/3,),
//                                                       child: exitIcon != ''||
//                                                               exitIcon.isNotEmpty
//                                                           ? Image.asset(
//                                                               exitIcon,
//                                                               errorBuilder:
//                                                                   (context, error,
//                                                                       stackTrace) {
//                                                                 return Icon(Icons
//                                                                     .broken_image);
//                                                               },
//                                                             )
//                                                           :const Icon(
//                                                               Icons.more_horiz,
//                                                               color: Colors.grey,
//                                                             )),
//                                                   Expanded(
//                                                       child: Text("$exitNode",
//                                                           overflow:
//                                                               TextOverflow.ellipsis,
//                                                           maxLines: 1,
//                                                           style: TextStyle(
//                                                             fontSize: 12,
//                                                               color:
//                                                                  const Color(0xff00DC00)))),
//                                                 // BelnetLib.isConnected == false ? 
//                                                // isOpen ? Icon(Icons.arrow_drop_up) : 
//                                                 Icon(
//                                                   Icons.arrow_drop_down,
//                                                 )
//                                                 //: Container()
//                                                 ],
//                                               ))),
//                                     ),
//                                   ),
//                            const SizedBox(
//                               height: 15,
//                             ),
//                             Align(
//                                 alignment: Alignment.center,
//                                 child: const VpnConnectStatus())
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),



//  widget.canChangeNode  ? GestureDetector(
//               onTap: vpnStatusProvider.value == 'Connecting...' || !isChangeNodeEnable ? null : () {
//             showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor:
//               themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
//           insetPadding: EdgeInsets.all(20),
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             //height: 185,
//             padding: EdgeInsets.all(15),
//             decoration: BoxDecoration(
//                 color: themeProvider.darkTheme
//                     ? Color(0xff282836)
//                     : Color(0xffFFFFFF),
//                 borderRadius: BorderRadius.circular(15)),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Text( loc.switchingNode,
//                    // 'Switching Node',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Text( loc.doYouWantToSwitch,
//                   //'Do you want to switch with the selected node?',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 10.0,
//                         ),
//                         child: MaterialButton(
//                           elevation: 0,
//                           color:themeProvider.darkTheme ? Color(0xff42425F)  : Color(0xffF3F3F3),
//                                 disabledColor: Color(0xff2C2C3B),
//                           minWidth: double.maxFinite,
//                           height: 50,
//                           child: Text( loc.cancel,// 'Cancel',
//                               style: TextStyle(fontSize: 18)),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 10.0), // Adjust the radius as needed
//                           ),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0),
//                         child: MaterialButton(
//                           elevation: 0,
//                            color: Color(0xff00B134),
//                                 disabledColor: Color(0xff2C2C3B),
//                           minWidth: double.maxFinite,
//                           height: 50,
//                           child: Text(loc.connect, //'Connect',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 18)),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 10.0), // Adjust the radius as needed
//                           ),
//                           onPressed: () async {
//                             // disconnectVpn(vpnStatusProvider);
//                                     toggleBelnet(vpnStatusProvider,loadingtickValueProvider,webViewModel,loc,localeProvider);
//                                   // resetSettings();
//                                    Navigator.pop(context);

//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );});

//               },
//               child: Container(
//                 height: 55, //40,
//                 width: MediaQuery.of(context).size.width / 1.9,
//                 margin: EdgeInsets.symmetric(vertical: 20),
//                 decoration: BoxDecoration(
//                   color: isChangeNodeEnable ? const Color(0xff00B134) :themeProvider.darkTheme? const Color(0xff39394B): Color(0xffF3F3F3),
//                    // border: Border.all(color:isChangeNodeEnable ? const Color(0xff00B134):Color(0xff6D6D81)),
//                     borderRadius: BorderRadius.circular(10)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SvgPicture.asset(
//                       'assets/images/change_node.svg',
//                       height: 15,
//                       color:isChangeNodeEnable ? Colors.white : themeProvider.darkTheme? Color(0xff6D6D81) : Color(0xffC5C5C5),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text( loc.switchNode,
//                          // 'Switch Node',
//                           style: TextStyle(fontSize: 18 ,fontWeight: FontWeight.w600,color: !isChangeNodeEnable ? themeProvider.darkTheme? Color(0xff6D6D81) : Color(0xffC5C5C5) :  Colors.white //: Colors.black
//                            ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ):SizedBox.shrink(),
          


//       //  Visibility(
//       //   visible: canShowWarning,
//       //    child: Container(
//       //     margin: EdgeInsets.all(15),
//       //     padding: EdgeInsets.all(10),
//       //     decoration: BoxDecoration(
//       //       border: Border.all(color:Colors.grey,width: 0.1),
//       //       borderRadius: BorderRadius.circular(8),
//       //       color: themeProvider.darkTheme ? Colors.white : Color(0xffF3F3F3)
//       //     ),
//       //       child: Text('Please remain on this page until the operation has been completed.',textAlign: TextAlign.center, style: TextStyle(fontWeight:FontWeight.w500,color: Colors.black ),),
//       //    ),
//       //  )












//               ],
//             )
          ],
        );
      }),
    );
  }









  Widget _buildExitnodeListView(
      double mHeight, DarkThemeProvider themeProvider,VpnStatusProvider vpnStatusProvider,AppLocalizations loc) {
    // print('${exitData1.length}');
    try {
      return Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (overlayEntry != null) {
              overlayEntry?.remove();
            }

            //print('${exitData1[1].type}');
          },
          child: Container(
            height: 200.0,
            margin: EdgeInsets.only(
                top: mHeight * 1.76 / 3, //2.010
                bottom: MediaQuery.of(context).size.height * 0.50 / 3,
                left: mHeight * 0.12 / 3,
                right: mHeight * 0.12 / 3),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.70 / 3,
              width: MediaQuery.of(context).size.width * 2.7 / 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9.0),
                  color: themeProvider.darkTheme
                      ?const Color(0xff39394B)
                      :const Color(0xffFFFFFF),
                  border: Border.all(
                      color: themeProvider.darkTheme
                          ?const Color(0xff282836)
                          :const Color(0xffF3F3F3))),
              child: exitData1.length == 0
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff00DC00),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: exitData1.length,
                      itemBuilder: (BuildContext context, int index) {
                        // print("data inside listview ${exitData[index]}");
                        return Container(
                          margin: EdgeInsets.all(0),
                          //padding: const EdgeInsets.only(top:0.0,bottom:0.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              
                              dividerColor: Colors.transparent,
                              listTileTheme: ListTileTheme.of(context)
                        .copyWith(dense: true, minVerticalPadding: 2,
                        visualDensity: VisualDensity(vertical: 0)
                        ),
                              ),
                            child: ExpansionTile(
                              // backgroundColor: Colors.yellow,
                              //initiallyExpanded: true,
                              tilePadding: EdgeInsets.only(
                                  left: mHeight * 0.08 / 3,
                                  right: mHeight * 0.04 / 3),
                              title: Text(
                                exitData1[index].type == 'Beldex Official' ? loc.beldexofficial : loc.contributorExitNode,
                                style: TextStyle(
                                    color: index == 0
                                        ? Color(0xff1CBE20)
                                        : Color(0xff1994FC),
                                    fontSize: MediaQuery.of(context).size.height *
                                        0.048 /
                                        3,
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: index == 0
                                  ? Color(0xff1CBE20)
                                  : Color(0xff1994FC),
                              collapsedIconColor: index == 0
                                  ? Color(0xff1CBE20)
                                  : Color(0xff1994FC),
                              subtitle: Text(
                                // exitData[index].type == "Custom Exit Node" &&
                                //         customExitAdd.isNotEmpty
                                //     ? "${customExitAdd.length} Nodes":
                                "${exitData1[index].node.length} ${loc.nodes}",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: MediaQuery.of(context).size.height *
                                        0.033 /
                                        3),
                              ),
                              children: <Widget>[
                                Column(
                                  children: _buildExpandableContent(
                                      exitData1[index].node,
                                      exitData1[index].type,
                                      themeProvider,
                                      mHeight,
                                      vpnStatusProvider,
                                      loc
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      // _buildList(exitData[index]),
                      ),
            ),
            // ),
          ),
        ),
      );
    } catch (e) {
      print('$e');
      return Container();
    }
  }

  _buildExpandableContent(List<exitNodeModel.Node> vnode, String type,
      DarkThemeProvider themeProvider, double mHeight,VpnStatusProvider vpnStatusProvider,AppLocalizations loc) {
    List<Widget> columnContent = [];
    for (int i = 0; i < vnode.length; i++) {
      columnContent.add(GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
           String connectednode = prefs.getString('selectedExitNode') ?? '';
          if (overlayEntry != null //&& exitNode != vnode[i].name
            ) {
              overlayEntry?.remove();
            }
             isSameNode = exitNode == vnode[i].name;

           if(!widget.canChangeNode){
            setState(() {
              //valueS = vnode[i].name;
              exitNode = vnode[i].name;
              exitIcon ='assets/images/flags/${vnode[i].country}.png'; //vnode[i].icon;
              isChangeNodeEnable = false;
            });
            await prefs.setString('selectedExitNode', '$exitNode');
            await prefs.setString('selectedCountryIcon', '$exitIcon');
           }else{
            setState(() {
              exitNode = vnode[i].name;
              exitIcon = 'assets/images/flags/${vnode[i].country}.png';
              //isChangeNodeEnable = true;
              if(connectednode == vnode[i].name){
                isChangeNodeEnable = false;
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(loc.thisNodeAlreadySelected)));

              }else{
                isChangeNodeEnable = true;
              }
            });
           }
        },
        child: Container(
          padding: EdgeInsets.only(
              left: mHeight * 0.06 / 3,
              right: mHeight * 0.06 / 3,
              top: mHeight * 0.02 / 3,
              bottom: mHeight * 0.02 / 3),
              margin: EdgeInsets.symmetric(horizontal: 5),
          height: mHeight * 0.15 / 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color:exitNode == vnode[i].name ? Colors.blue : Colors.transparent,
              border: Border(
                  bottom: BorderSide(
                      width: 0.5, color: Color(0xff56566F).withOpacity(0.2)))),
          child: Row(
            children: [
              Container(
                //color:Colors.yellow,
                height: MediaQuery.of(context).size.height * 0.050 / 3,
                width: MediaQuery.of(context).size.height * 0.060 / 3,
                child: vnode[i].icon.isNotEmpty
                    ? Image.asset(
                      'assets/images/flags/${vnode[i].country}.png',
                      errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                            size: 0.4,
                          );
                        },
                      fit: BoxFit.fill,
                    )
                    // Image.network(
                    //     vnode[i].icon,
                    //     errorBuilder: (context, error, stackTrace) {
                    //       print('ERROR WHILE LOADING FLAG ICON $error');
                    //       return Icon(
                    //         Icons.more_horiz,
                    //         color: Colors.grey,
                    //         size: 0.4,
                    //       );
                    //     },
                    //     // height: MediaQuery.of(context).size.height * 0.10 / 3,
                    //     // width: MediaQuery.of(context).size.height * 0.15 / 3,
                    //     fit: BoxFit.fill,
                    //   )
                    :const Icon(Icons.info_outline_rounded),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.05 / 3,
                      right: MediaQuery.of(context).size.height * 0.05 / 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vnode[i].name,
                          style: TextStyle(
                              color:exitNode == vnode[i].name ? Colors.white : themeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                                  fontWeight: exitNode == vnode[i].name ? FontWeight.w600: FontWeight.normal,
                              fontSize: MediaQuery.of(context).size.height *
                                  0.035 /
                                  3),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        vnode[i].country,
                        style: TextStyle(
                            color:exitNode == vnode[i].name ? Colors.white : Colors.grey,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.031 / 3),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 5.0,
                width: 5.0,
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.height * 0.05 / 3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vnode[i].isActive == "true"
                        ? Colors.green
                        : Colors.red),
              ),
            ],
          ),
        ),
      ));
    }
    return columnContent;
  }
}


String getStringsForStatus(String status,AppLocalizations loc){
  switch(status){
    case 'Connected': return loc.connected;
    case 'Connecting...' : return loc.connecting;
    case 'Disconnected': return loc.disconnected;
    default: return loc.connected;
  }
}

class VpnConnectStatus extends StatelessWidget {
  const VpnConnectStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final loadingtickValueProvider =
        Provider.of<LoadingtickValueProvider>(context);
      final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8),
                child: Text(
                 getStringsForStatus(vpnStatusProvider.value,loc) ,
                  style: TextStyle(),
                ),
              ),
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: vpnStatusProvider.value == 'Connected'
                      ? Color(0xff20D125)
                      : vpnStatusProvider.value == 'Connecting...'
                          ? Color(0xffffdf00)
                          : Colors.red,
                ),
              )
            ],
          ),
          vpnStatusProvider.value == 'Connecting...'
              ? SizedBox(
                  width: 110,
                  child: LinearProgressIndicator(
                    value: loadingtickValueProvider.progressValue,
                    color: Color(0xff20D125),
                    minHeight: 1.5,
                  ))
              : SvgPicture.asset(
                  'assets/images/line_white_theme.svg',
                  color: vpnStatusProvider.value == 'Disconnected'
                      ? Colors.grey
                      : Color(0xff20D125),
                )
        ],
      ),
    );
  }
}
