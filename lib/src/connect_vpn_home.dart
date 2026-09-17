//import 'package:beldex_browser/src/browser/browser_home_page.dart';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/pages/bottom_nav_bar.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/settings/app_language_screen.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart'
    as exitNodeModel;
import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart';
// import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/random_node_selection.dart';
import 'package:beldex_browser/src/tunnel_health_provider.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/no_internet_screen.dart';
//import 'package:beldex_browser/src/widget/nointernet_connection.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:beldex_browser/src/browser/browser.dart';
import 'package:beldex_browser/src/model/exitnodeRepo.dart';
import 'package:beldex_browser/src/node_dropdown_list_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectVpnHome extends StatefulWidget {
  const ConnectVpnHome({Key? key}) : super(key: key);

  @override
  State<ConnectVpnHome> createState() => _ConnectVpnHomeState();
}

class _ConnectVpnHomeState extends State<ConnectVpnHome>
    with SingleTickerProviderStateMixin {
  List myExitData = [];
  List exitCountryIcon = [];
  String customExitnode =
      'iyu3gajuzumj573tdy54sjs7b94fbqpbo3o44msrba4zez1o4p3o.bdx';
  String selectedValue = 'exit.bdx';
  String selectedConIcon = "assets/images/flags/France.png";
  late AnimationController animationController;
  bool animationCompleted = false;
  List<exitNodeModel.ExitNodeDataList> exitData = [];
  List<exitNodeModel.ExitNodeDataList> exitNodeDataList = [];
  List ids = [];
  var selectedId;

  List<String> messages = [];
  Timer? messageTimer;

  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  String? exitNode = '';
  String? exitIcon = '';

  bool isOpen = false;
  late OverlayEntry? overlayEntry;

Map<String,dynamic> nearest = {};


 var _isRestored = false;



 // Latency audit fix: connection phase messages are now driven by the REAL
  // connection phases (see toggleBelnet) instead of fixed 0/6/5/7-second
  // timers that had no relationship to what the daemon was doing.
  void _setPhase(String message, LoadingtickValueProvider progressProvider,
      double targetProgress) {
    if (!mounted) return;
    setState(() {
      messages
        ..clear()
        ..add(message);
    });
    final delta = targetProgress - progressProvider.progressValue;
    if (delta > 0) progressProvider.updateProgressValue(delta);
  }

  void _resetProgress(LoadingtickValueProvider progressProvider) {
    final current = progressProvider.progressValue;
    if (current != 0) progressProvider.updateProgressValue(-current);
  }


  // void displayMessages(AppLocalizations appLoc) {
  //   showMessage(appLoc.checkingConnection, 0);
  //   showMessage(appLoc.belnetServiceStarted, 6);
  //   showMessage(appLoc.connectingBelnetdVPN, 5);
  //   showMessage(appLoc.prepareDaemonConnection, 7);
  // }

  // void showMessage(String message, int delaySeconds) {
  //   Timer(Duration(seconds: delaySeconds), () {
  //     setState(() {
  //       messages.clear();
  //       messages.add(message);
  //     });
  //   });
  // }

  @override
  void initState() {
     super.initState();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        setState(() {
          _isConnected = false;
        });
      } else {
        setState(() {
          _isConnected = true;
        });
      }
    });
    animationController = AnimationController(vsync: this);
    animationController.addListener(() {
      if (animationController.value == 1) {
        animationController.stop();
        animationCompleted = true;
        setState(() {});
      }
    });

    final basicProvider = Provider.of<BasicProvider>(context, listen: false);
    checkInternetConnection();
    //getExitNodeData();

getNodeInitialSelection(basicProvider,context);


WidgetsBinding.instance.addPostFrameCallback((_) {
   final addSearchEngineProvider = Provider.of<AddSearchEngineProvider>(context, listen: false);
    // final selectedItemProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
     final browserModel = Provider.of<BrowserModel>(context,listen: false);
     final settings = browserModel.getSettings();
   addSearchEngineProvider.clearSessionEngines(browserModel.getSettings(), browserModel,context);
  // if(settings.searchEngine.name == 'Google'){
  //   selectedItemProvider.updateIconValue('assets/images/Google 1.svg');
  // }
 });

    //WidgetsBinding.instance.addObserver(this);
    //getRandomExitData();
    // super.initState();
  //  Future.delayed(Duration(milliseconds: 300),(){
  //   if(widget.nearestId != '' && )
  //   setForAutoConnect();
  //  });
    // Delay to after the first frame
//   WidgetsBinding.instance.addPostFrameCallback((_) async{
//     final basicProvider = Provider.of<BasicProvider>(context, listen: false);
//     final vpnProvider = Provider.of<VpnStatusProvider>(context, listen: false);
//     final loadingProvider = Provider.of<LoadingtickValueProvider>(context, listen: false);
//     final isVpnPermit = await BelnetLib.isPrepared;
//     print('AUTOCONNECT VALUE ON LAUNCH --> ${basicProvider.autoConnect}');
//       print('IS VPN PERMISSION ENABLED ${isVpnPermit}');
// Future.delayed(Duration(milliseconds: 300),(){
//     if (basicProvider.autoConnect && BelnetLib.isConnected == false) {
//       print('USER BAB ONE --> ${nearest}');
//       setState(() {
        
//       });
//       if(nearest.isNotEmpty){
//               print('USER BAB TWO --> ${nearest}');

//         if(isVpnPermit)
//                       print('USER BAB Three --> ${nearest}');

//        // toggleBelnet(vpnProvider, loadingProvider);
//       }
//      // setForAutoConnect();
//      // if(isVpnPermit)
//      // toggleBelnet(vpnProvider, loadingProvider);
//     }
// });
   
//   });

  }




bool _autoConnectStopped = false;












 getNodeInitialSelection(BasicProvider basicProvider,BuildContext context)async{
  final isVpnPermit = await BelnetLib.isPrepared;
    final vpnProvider = Provider.of<VpnStatusProvider>(context, listen: false);
     final loadingProvider = Provider.of<LoadingtickValueProvider>(context, listen: false);
        final appLoc = AppLocalizations.of(context)!;
   final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedExitNode', '$selectedValue');
    await prefs.setString('selectedCountryIcon', '$selectedConIcon');

    exitNode = prefs.getString('selectedExitNode');
    exitIcon = prefs.getString('selectedCountryIcon');
    setState(() {});
try{

      var resp = await DataRepo().getExitnodeInfoListData();
      exitNodeDataList.addAll(resp);
      print('${exitNodeDataList[0].node}');

      String jsonString = exitNodeDataListToJson(exitNodeDataList);
      print('JSONSTRING ____ $jsonString');
      await prefs.setString('allExitnodeList', jsonString);

      setState(() {});
      // exitNodeDataList.forEach((element) {
      //   element.node.forEach((element) {
      //     myExitData.add(element.name);
      //   });
      // });
      nearest = await findNearestNode(nodeLists: exitNodeDataList,basicProvider:basicProvider);
 await prefs.setString('selectedExitNode', '${nearest['name']}');
        await prefs.setString(
            'selectedCountryIcon', 'assets/images/flags/${nearest['country']}.png');
        // print(
        //     'second index for the data ${customIcon}  and the $customExitnode');

        exitNode = prefs.getString('selectedExitNode');
        exitIcon = prefs.getString('selectedCountryIcon');
          print('USER BAB ONE NODE SELECTED ---> $exitNode -- $exitIcon');

  if (basicProvider.autoConnect && BelnetLib.isConnected == false) {
      print('USER BAB ONE --> ${nearest}');
      setState(() {
        
      });
      if(nearest.isNotEmpty){
              print('USER BAB TWO --> ${nearest}');
        if(isVpnPermit)
          toggleBelnet(context ,vpnProvider, loadingProvider,appLoc);
                     // print('USER BAB Three --> ${nearest}');

       // toggleBelnet(vpnProvider, loadingProvider);
      }
     // setForAutoConnect();
     // if(isVpnPermit)
     // toggleBelnet(vpnProvider, loadingProvider);
    }





}catch(e){
 print('Error in the Random nearest node selection $e');
}

 }











  Future<void> checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });
    }
  }

// getRandomExitData()async{
//  SharedPreferences preferences = await SharedPreferences.getInstance();
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
//         exitData.forEach((element) {
//           element.node.forEach((element) {
//             if (selectedId == element.id) {
//               selectedValue = element.name;
//               selectedConIcon = element.icon;
//               print("icon id value $selectedId");
//               print("selected exitnode value $selectedValue");
//               print("icon image url : ${element.icon}");
//             }
//           });
//         });
//      preferences.setString('selectedExitNode','$selectedValue');
//      preferences.setString('selectedCountryIcon','$selectedConIcon');
//         // if(BelnetLib.isConnected == false){
//         // preferences.setString('hintValue',selectedValue!);
//         // preferences.setString('hintContryicon',selectedConIcon!);
//         // }
//       });

//     }
// }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.detached) {
  //     print('changeState ----> detached state');
  //     if (BelnetLib.isConnected) {
  //       print('changeState --- it is connected');
  //       Future.delayed(Duration(milliseconds: 100), () {
  //         BelnetLib.disconnectFromBelnet();
  //       });
  //     }
  //   } else if (state == AppLifecycleState.inactive) {
  //     print('changeState ------> inactive state');
  //   }
  // }

  getExitNodeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedExitNode', '$selectedValue');
    await prefs.setString('selectedCountryIcon', '$selectedConIcon');

    exitNode = prefs.getString('selectedExitNode');
    exitIcon = prefs.getString('selectedCountryIcon');
    setState(() {});
    try {
      print('inside this ');

      var resp = await DataRepo().getListData();
      exitNodeDataList.addAll(resp);
      print('${exitNodeDataList[0].node}');

      String jsonString = exitNodeDataListToJson(exitNodeDataList);
      print('JSONSTRING ____ $jsonString');
      await prefs.setString('allExitnodeList', jsonString);

      setState(() {});
      exitNodeDataList.forEach((element) {
        element.node.forEach((element) {
          myExitData.add(element.name);
        });
      });

      // setState(() {});
      //  exitNodeDataList[0].node.forEach((element) {
      //   myExitData.add(element.name);

      //  });
      setState(() {});
      if (myExitData != []) {
        customExitnode = myExitData[Random().nextInt(myExitData.length)];

        List<String> customIcon = exitNodeDataList
            .firstWhere(
              (element) => element.node
                  .any((innerElement) => innerElement.name == customExitnode),
              //orElse: () => null
            )
            .node
            .where((innerElement) => innerElement.name == customExitnode)
            .map((innerElement) => innerElement.country)
            .toList();

        await prefs.setString('selectedExitNode', '$customExitnode');
        await prefs.setString(
            'selectedCountryIcon', 'assets/images/flags/${customIcon[0]}.png');
        print(
            'second index for the data ${customIcon}  and the $customExitnode');

        exitNode = prefs.getString('selectedExitNode');
        exitIcon = prefs.getString('selectedCountryIcon');
      }
    } catch (e) {
      print(e);
    }
  }


/// working code

  // bool isLoading = false;
  // int count = 1;
  // Future toggleBelnet(VpnStatusProvider vpnStatusProvider,
  //     LoadingtickValueProvider loadingtickValueProvider,AppLocalizations appLoc) async {
  //   const totalDuration = Duration(seconds: 20);
  //   if (count == 1) {
  //     try {
  //       count++;
  //       final prefs = await SharedPreferences.getInstance();
  //       if (_isConnected) {
  //         if (mounted) setState(() {});

  //         if (BelnetLib.isConnected) {
  //           var disConnectValue = await BelnetLib.disconnectFromBelnet();
  //           vpnStatusProvider.updateValue('Disconnected');
  //         } else {
  //           setState(() {
  //             isLoading = true;
  //           });
  //           String exitnodeName = prefs.getString('selectedExitNode') ?? '';
  //           final result = await BelnetLib.prepareConnection();
  //           if (!result) {
  //             setState(() {
  //               isLoading = false;
  //               count = 1;
  //             });
  //           }
  //           if (result) {
  //             vpnStatusProvider.updateValue('Connecting...');
  //             print('The Exitnode connecting to is ---> $customExitnode');
  //             final con = await BelnetLib.connectToBelnet(
  //                 exitNode: customExitnode, //exitnodeName, //customExitnode,
  //                 upstreamDNS: "9.9.9.9");
  //             displayMessages(appLoc);
  //             // vpnStatusProvider.updateValue('Connecting...');
  //             simulateDelayedProgress(loadingtickValueProvider);
  //             Future.delayed(totalDuration, () {
  //               if (mounted)
  //                 setState(() {
  //                   isLoading = false;
  //                 });
  //               vpnStatusProvider.updateValue('Connected');
  //               Navigator.pushReplacement(context,
  //                   MaterialPageRoute(builder: ((context) => MainScreen() //Browser()
  //                   )));
  //             });
  //             print("connection data value for display ${myExitData[1]}");
  //           }

  //           setState(() {});
  //         }
  //       } else {
  //         if (BelnetLib.isConnected) {
  //           BelnetLib.disconnectFromBelnet();
  //         }
  //       }
  //     } catch (e) {
  //       print('Exception while checking $e');
  //     }
  //   }
  //   // print('connected exitnode is ---> $exitnodeName');
  // }



bool isLoading = false;

  /// Re-entrancy guard for the connect flow. Replaces the old `count`
  /// int, which left the Connect button permanently dead after a failed
  /// prepare (it was only reset on one failure path).
  bool _connecting = false;

  /// Consecutive verified-connect failures; after 2 in a row the local
  /// bootstrap file is discarded so a stale/corrupt bootstrap self-heals.
  int _consecutiveConnectFailures = 0;

  // Latency audit fix (sections 3.1/3.2/3.4): the old implementation
  // declared "Connected" from a fixed 20-second Future.delayed — without
  // checking the result of connectToBelnet, without consulting the daemon
  // status, and while passing the possibly-stale `customExitnode` field
  // instead of the node the user actually selected. On fast networks users
  // always waited the full 20s; on slow/failed connects the browser opened
  // with a fully black-holed tunnel ("connected but no internet").
  //
  // The flow is now: prepare -> connect (checked) -> waitForTunnelReady()
  // (daemon status + end-to-end probe) -> only then Connected + navigate.
  Future toggleBelnet(BuildContext context, VpnStatusProvider vpnStatusProvider,
      LoadingtickValueProvider loadingtickValueProvider,
      AppLocalizations appLoc) async {
    if (_connecting) return;
    _connecting = true;
    setState(() {
      
    });
        _autoConnectStopped = false;
    try {
      if (!_isConnected) {
        // Device itself is offline: make sure the tunnel is down.
        if (BelnetLib.isConnected) {
          await BelnetLib.disconnectFromBelnet();
        }
        return;
      }

      if (BelnetLib.isConnected) {
        // Ported from belnet-app commit df16d27: stop end-to-end health
        // monitoring and any in-flight status polling together with the
        // tunnel.
        _tunnelHealth()?.stop();
        vpnStatusProvider.cancelPolling();
        await BelnetLib.disconnectFromBelnet();
        vpnStatusProvider.updateValue('Disconnected');
        if (mounted) setState(() {});
        return;
      }

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      _resetProgress(loadingtickValueProvider);

      // Audit fix 3.4: always connect to the node that was actually
      // selected (prefs are the source of truth written by every selection
      // path), not the `customExitnode` field that was only refreshed by an
      // un-awaited async call from build().
      final prefs = await SharedPreferences.getInstance();
      final exitnodeName = prefs.getString('selectedExitNode') ?? '';
      final nodeToUse =
          exitnodeName.isNotEmpty ? exitnodeName : customExitnode;
      customExitnode = nodeToUse;
      debugPrint('Connecting to exit node: $nodeToUse');

      _setPhase(appLoc.checkingConnection, loadingtickValueProvider, 0.10);

      bool prepared;
      try {
        prepared = await BelnetLib.prepareConnection();
      } on BootstrapException catch (e) {
        debugPrint('Bootstrap failed: $e');
        _failConnect(vpnStatusProvider, loadingtickValueProvider,
           appLoc.couldnotDownloadBootstrap);
        return;
      }
      if (!prepared) {
        // VPN permission denied or preparation failed.
        _failConnect(vpnStatusProvider, loadingtickValueProvider, null);
        return;
      }

      vpnStatusProvider.updateValue('Connecting...');
      _setPhase(appLoc.belnetServiceStarted, loadingtickValueProvider, 0.25);

      final started = await BelnetLib.connectToBelnet(
          exitNode: nodeToUse, upstreamDNS: "9.9.9.9");
      if (!started) {
        _failConnect(vpnStatusProvider, loadingtickValueProvider,
           appLoc.theBelnetServiceNotStarted);
        return;
      }

      _setPhase(appLoc.connectingBelnetdVPN, loadingtickValueProvider, 0.50);

      // Belnet-app df16d27 (audit F1) status polling, now DIAGNOSTIC ONLY.
      //
      // FIX for "disconnects after 30 s": the previous version hard-gated
      // the connect on this poller. When the daemon's status JSON doesn't
      // match the expected schema (this daemon build's DumpStatus differs
      // from belnet-app's GetStatus shape), the poller can never report
      // ready, so every connect timed out at 30 s and disconnected - even
      // though the tunnel was actually up. That is the exact failure mode
      // browser commit 6fc6d53 fixed before, so we restore its rule: the
      // END-TO-END PROBE is the only authoritative gate. The poller now
      // runs alongside purely for fast feedback and diagnostics; when it
      // reports ready early (typically 4-8 s) we bump the progress bar,
      // and when it can't parse readiness we only log the daemon state.
      bool daemonReportedReady = false;
      vpnStatusProvider.startStatusPolling(
        getStatus: () async {
          final s = await BelnetLib.getSpeedStatus;
          return s;
        },
        onConnected: () {
          daemonReportedReady = true;
          print('Daemon reports exit ready (status polling)');
          // Nice-to-have progress bump; never gates the flow.
          _setPhase(appLoc.connectingBelnetdVPN, loadingtickValueProvider, 0.75);
        },
        onFailed: (reason) {
          // NOT fatal - diagnostic only.
          print('Daemon status polling inconclusive: $reason');
        },
        timeout: const Duration(seconds: 30),
      );

      // AUTHORITATIVE gate: real packets through the tunnel. 90 s cap: a
      // FIRST connect on a fresh install has to bootstrap and build paths
      // from an empty network DB, which can take well over 40 s. Verified
      // connects on warm installs typically finish in a few seconds.
      final ready = await BelnetLib.waitForTunnelReady(
          timeout: const Duration(seconds: 60),
           shouldCancel: () {
    return !_isConnected; //|| _autoConnectStopped;
  },
          );
      vpnStatusProvider.cancelPolling();
      print(
          'Connect result: probe=$ready, daemonReportedReady=$daemonReportedReady');

      print(
  'AFTER waitForTunnelReady: '
  '_isConnected=$_isConnected '
  '_autoConnectStopped=$_autoConnectStopped',
);

// Internet was disabled while auto-connect was running.
// if (!_isConnected || _autoConnectStopped) {
//   print('AUTO CONNECT STOPPED BECAUSE INTERNET WAS LOST');

//   vpnStatusProvider.updateValue('Disconnected');

//   if (mounted) {
//     setState(() {
//       isLoading = false;
//     });
//   }

//   return;
// }

      if (!ready) {
        _consecutiveConnectFailures++;
        await BelnetLib.disconnectFromBelnet();
        if (_consecutiveConnectFailures >= 2) {
          // Self-heal a stale/corrupt bootstrap (audit fix 2).
          await BelnetLib.resetBootstrap();
          _consecutiveConnectFailures = 0;
        }
        // Exact belnet-app df16d27 failure message; shown only on a GENUINE
        // failure (no packets through the tunnel within 90 s).
        _failConnect(vpnStatusProvider, loadingtickValueProvider,appLoc.couldNotEstablishConnection);
        return;
      }

      _consecutiveConnectFailures = 0;
      _setPhase(appLoc.prepareDaemonConnection, loadingtickValueProvider, 1.0);
      vpnStatusProvider.updateValue('Connected');

      // Ported from belnet-app commit df16d27 (audit F2): start end-to-end
      // health monitoring. If the tunnel silently blackholes mid-session
      // (exit dies, handover breaks paths), try one remap of the current
      // exit and otherwise disconnect with a clear message instead of
      // leaving a green UI over a dead tunnel.
      _tunnelHealth()?.start(onBroken: () {
        _recoverBrokenTunnel(vpnStatusProvider,context);
      });

      if (mounted) {
        setState(() {
          isLoading = false;
        });

  //        if (!_isConnected || _autoConnectStopped) {
  //   print(
  //     'NOT NAVIGATING - INTERNET WAS LOST DURING AUTO CONNECT',
  //   );

  //   return;
  // }
 
  if(_isConnected && ready)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((context) => MainScreen())));
      }
    } catch (e) {
      debugPrint('Exception while connecting: $e');
      _failConnect(vpnStatusProvider, loadingtickValueProvider, null);
    } finally {
      _connecting = false;
    }
  }

  void _failConnect(VpnStatusProvider vpnStatusProvider,
      LoadingtickValueProvider loadingtickValueProvider, String? message) {
    vpnStatusProvider.updateValue('Disconnected');
    _resetProgress(loadingtickValueProvider);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      messages.clear();
    });
    if (message != null) {
      // TODO(l10n): move these connection-failure messages into the arb files.
      showMessage(message);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Safe lookup of the [TunnelHealthProvider]: returns null when the widget
  /// tree is gone (e.g. we already navigated away) instead of throwing.
  TunnelHealthProvider? _tunnelHealth() {
    if (!mounted) return null;
    try {
      return Provider.of<TunnelHealthProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  /// Ported from belnet-app commit df16d27 (audit F2): recovery for a tunnel
  /// that reports connected but cannot reach the internet (health probe
  /// failed twice). Strategy: re-map the current exit once and re-probe; if
  /// that doesn't restore traffic, disconnect cleanly so the user sees the
  /// true state instead of "Connected" with no internet.
  bool _recoveryInProgress = false;

  Future<void> _recoverBrokenTunnel(VpnStatusProvider vpnStatusProvider,BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    if (_recoveryInProgress) return;
    _recoveryInProgress = true;
    final health = _tunnelHealth();
    try {
      final prefs = await SharedPreferences.getInstance();
      final exitNode = prefs.getString('selectedExitNode') ?? customExitnode;
      debugPrint('Exit node unreachable - attempting recovery via $exitNode');
      showMessage('Exit node unreachable, reconnecting...');

      // Attempt 1: remap the current exit and verify with the real
      // end-to-end probe (browser adaptation: waitForTunnelReady instead of
      // a single delayed probe).
      await BelnetLib.unmapExitNode(exitNode);
      final recovered = await BelnetLib.waitForTunnelReady(
          timeout: const Duration(seconds: 30));
      if (recovered) {
        debugPrint('Recovery successful: exit remapped');
        await health?.probeNow();
        return;
      }

      // Recovery failed: disconnect so the UI reflects reality.
      health?.stop();
     // await BelnetLib.disconnectFromBelnet();
     // vpnStatusProvider.updateValue('Disconnected');
      if (mounted) setState(() {});
     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ConnectVpnHome()));
      showMessage(loc.unprecidentedTrafficExitNodeError
         // 'Connection to the exit node was lost. Please reconnect or choose another node.'
          );
      
    } catch (e) {
      debugPrint('Tunnel recovery failed: $e');
    } finally {
      _recoveryInProgress = false;
    }
  }








 






  // Future toggleBelnet(VpnStatusProvider vpnStatusProvider,
  //     LoadingtickValueProvider loadingtickValueProvider) async {
  //   const totalDuration = Duration(seconds: 20);
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (_isConnected) {
  //     if (mounted) setState(() {});

  //     if (BelnetLib.isConnected) {
  //       var disConnectValue = await BelnetLib.disconnectFromBelnet();
  //       vpnStatusProvider.updateValue('Disconnected');
  //     } else {
  //       String exitnodeName = prefs.getString('selectedExitNode') ?? '';
  //       final result = await BelnetLib.prepareConnection();
  //       if (result) {
  //         final con = await BelnetLib.connectToBelnet(
  //             exitNode: customExitnode, //exitnodeName, //customExitnode,
  //             upstreamDNS: "9.9.9.9");
  //         displayMessages();
  //         vpnStatusProvider.updateValue('Connecting...');
  //         simulateDelayedProgress(loadingtickValueProvider);
  //         Future.delayed(totalDuration, () {
  //           vpnStatusProvider.updateValue('Connected');
  //           Navigator.pushReplacement(
  //               context, MaterialPageRoute(builder: ((context) => Browser())));
  //         });
  //         print("connection data value for display ${myExitData[1]}");
  //       }

  //       setState(() {});
  //     }
  //   } else {
  //     if (BelnetLib.isConnected) {
  //       BelnetLib.disconnectFromBelnet();
  //     }
  //   }
  //   // print('connected exitnode is ---> $exitnodeName');
  // }
  //late Timer timers;
  // void simulateDelayedProgress(
  //     LoadingtickValueProvider loadingtickValueProvider) {
  //   const totalDuration = Duration(seconds: 20);
  //   const updateInterval = const Duration(milliseconds: 100);

  //   int totalTicks =
  //       totalDuration.inMilliseconds ~/ updateInterval.inMilliseconds;

  //   timers = Timer.periodic(updateInterval, (timer) {
  //     if (loadingtickValueProvider.progressValue < 1.0) {
  //       setState(() {
  //         loadingtickValueProvider.updateProgressValue(1.0 / totalTicks);
  //       });
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  @override
  void dispose() {
    animationController.dispose();
    _connectivitySubscription.cancel();
   // timers.cancel();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

restore() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    browserModel.restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      restore();
    }
    precacheImage(const AssetImage("assets/icon/icon.png"), context);
  }






  updateExitNodeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var timer = Timer.periodic(Duration(milliseconds: 100), (timer){
    setState(() {});
    customExitnode = prefs.getString('selectedExitNode') ?? '';
    //});
  }

  Future<bool?> checkForCloseApp() async {
    setState(() {
      isSet = false;
    });
    bool value = BelnetLib.isConnected == true ? true : false;
    //overlayEntry!.remove();
    print('pop comes 5 $value');
    return value;
  }

  bool isSet = true;
  bool popValue = true;

  @override
  Widget build(BuildContext context) {
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final loadingtickValueProvider =
        Provider.of<LoadingtickValueProvider>(context);
     final loc = AppLocalizations.of(context)!;
    final mHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    if (BelnetLib.isConnected) {
      print('is connected true ${BelnetLib.isConnected}');
    }
    updateExitNodeValue();
    return !_isConnected
        ? NoInternetConnection()
        : WillPopScope(
            onWillPop: () async {
              if (BelnetLib.isConnected == false) {
                print('comes inside the condition');
                return true;
              } else
                return false;
            },
            child: Stack(
              children: [
                Positioned.fill(child: themeProvider.darkTheme ? Image.asset('assets/images/ai-icons/new/Splash_dark.png',fit: BoxFit.cover,)
                       : Image.asset('assets/images/ai-icons/new/Splash_white.png',fit: BoxFit.cover,),),
                        Positioned.fill(
                          child:themeProvider.darkTheme ? SvgPicture.asset('assets/images/ai-icons/new/Beldex_browser_white.svg',fit: BoxFit.cover,) : SvgPicture.asset('assets/images/ai-icons/new/Beldex_browser_Black.svg',fit: BoxFit.cover,)
                        ),
                SafeArea(
                  child: Scaffold(
                      backgroundColor:Colors.transparent,// Color(0xff171720),
                      resizeToAvoidBottomInset: true,
                      body: Stack(
                        children: [
                          
                          // Padding(
                          //   padding: EdgeInsets.symmetric(
                          //       vertical: MediaQuery.of(context).size.width * 0.5),
                          //   child: Align(
                          //     alignment: Alignment.topRight,
                          //     child: Transform.translate(
                          //       offset: Offset(0,
                          //           -100), // Adjust this offset to position the first image
                          //       child: SvgPicture.asset(
                          //         'assets/images/box_element.svg', // Replace with your first image asset path
                          //         fit: BoxFit.contain,
                          //         width: MediaQuery.of(context).size.width *
                          //             0.15, // Adjust width if necessary
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: EdgeInsets.only(
                          //       bottom: MediaQuery.of(context).size.width * 0.14,
                          //       left: MediaQuery.of(context).size.width * 0.10),
                          //   child: Align(
                          //     alignment: Alignment.bottomLeft,
                          //     child: Transform.translate(
                          //       offset: Offset(0,
                          //           100), // Adjust this offset to position the second image
                          //       child: SvgPicture.asset(
                          //         'assets/images/shield.svg', // Replace with your second image asset path
                          //         fit: BoxFit.contain,
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5, // Adjust width if necessary
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Positioned.fill(
                            top: MediaQuery.of(context).size.height*1/3,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // AnimatedContainer(
                                  //     //color: Colors.yellow,
                                  //     margin: EdgeInsets.symmetric(horizontal: 20),
                                  //     //  padding: EdgeInsets.symmetric(horizontal: 10),
                                  //     // width: constraints.maxWidth / 1,
                                  //     // height: constraints.maxHeight / 1.60,
                                  //     duration: Duration(seconds: 1),
                                  //     child: themeProvider.darkTheme
                                  //         ? Lottie.asset(
                                  //            'assets/images/dark.json', //'assets/images/dark_welcome_scrn.json',
                                  //             fit: BoxFit.fitWidth)
                                  //         : LottieBuilder.asset(
                                  //             'assets/images/white.json',
                                  //             fit: BoxFit.fitWidth)),
                                      Text(loc.beldexBrowserForAndroid,textAlign: TextAlign.center,style: TextStyle(fontFamily: 'Inter'),),
                                      SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 9),
                                          child: Text(loc.exitnode,
                                            //'Exit Node',
                                            style:
                                                TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Inter'),
                                          ),
                                        ),
                                        BelnetLib.isConnected ||
                                                vpnStatusProvider.value ==
                                                    'Connecting...'
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                                                  child: GlassCommonPanel(
                                                    child: Container(
                                                        height: MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.19 /
                                                            3,
                                                        // margin: EdgeInsets.symmetric(
                                                        //     horizontal: 13),
                                                        decoration: BoxDecoration(
                                                            color: Colors.transparent,
                                                            border: Border.all(color: themeProvider.darkTheme ? Color(0xff333333): Color(0xffC0C0C0))
                                                            // themeProvider.darkTheme
                                                            //     ? const Color(0xff242436)
                                                            //     : const Color(0xffF3F3F3),
                                                            // borderRadius: BorderRadius.all(
                                                            //     Radius.circular(5)
                                                            //     )
                                                                ),
                                                        child: Padding(
                                                            padding: const EdgeInsets.only(
                                                                left: 4.0,
                                                                right: 6.0,
                                                                top: 3.0,
                                                                bottom: 5.0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.symmetric(
                                                                       vertical: 12.0,horizontal: 15),
                                                                    // margin:EdgeInsets.only(right:mHeight*0.03/3,),
                                                                    child: exitIcon != '' ||
                                                                            exitIcon!
                                                                                .isNotEmpty
                                                                        ? Image.asset(
                                                                            exitIcon!,
                                                                            errorBuilder:
                                                                                (context,
                                                                                    error,
                                                                                    stackTrace) {
                                                                              print(
                                                                                  'EXINODE ICON $exitIcon');
                                                                              return Icon(Icons
                                                                                  .broken_image);
                                                                            },
                                                                          )
                                                                        : const Icon(
                                                                            Icons
                                                                                .more_horiz,
                                                                            color:
                                                                                Colors.grey,
                                                                          )),
                                                                Expanded(
                                                                    child: Text("$exitNode",
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        maxLines: 1,
                                                                        style: TextStyle(
                                                                            fontSize: 12,
                                                                            color: themeProvider.darkTheme ? Colors.white : Colors.black,fontFamily: 'Inter'
                                                                            // const Color(
                                                                            //     0xff00DC00)
                                                                                ))),
                                                                BelnetLib.isConnected ==
                                                                        false
                                                                    ? const Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: Colors.grey,
                                                                      )
                                                                    : Container()
                                                              ],
                                                            ))),
                                                  ),
                                                ),
                                              )
                                            : Align(
                                                alignment: Alignment.center,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    try {
                                                      setState(() {
                                                        isOpen = isOpen ? false : true;
                                                      });
                                                      if (isOpen &&
                                                          (exitNodeDataList.isEmpty ||
                                                              exitNodeDataList == [])) {
                                                        //exitData.clear();
                                                        print(
                                                            'cleared the data ${exitNodeDataList.length}');
                                                        // saveData();
                                                        //saveCustomForUse();   //hide for version 1.2.0
                                                      } else {
                                                        //saveData();
                                                        OverlayState? overlayState =
                                                            Overlay.of(context);
                                                        overlayEntry = OverlayEntry(
                                                          builder: (context) {
                                                            return _buildExitnodeListView(
                                                                mHeight,
                                                                themeProvider,
                                                                vpnStatusProvider,
                                                                loc
                                                                );
                                                          },
                                                        );
                                                        overlayState
                                                            .insert(overlayEntry!);
                                                      }
                                                    } catch (e) {
                                                      print('Exception $e');
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(
                                                            horizontal: 13),
                                                    child: GlassCommonPanel(
                                                      child: Container(
                                                          height: MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.19 /
                                                              3,
                                                          // 48,
                                                          // MediaQuery.of(context).size.height *
                                                          //     0.16 /
                                                          //     3,
                                                          // margin: EdgeInsets.symmetric(
                                                          //     horizontal: 13),
                                                          decoration: BoxDecoration(
                                                              color: Colors.transparent,
                                                              border: Border.all(color: themeProvider.darkTheme ? Color(0xff333333): Color(0xffC0C0C0))
                                                              // themeProvider.darkTheme
                                                              //     ? const Color(0xff242436)
                                                              //     : const Color(0xffF3F3F3),
                                                              // borderRadius:
                                                              //     BorderRadius.all(
                                                              //         Radius.circular(5))
                                                                      ),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                      left: 4.0,
                                                                      right: 6.0,
                                                                      top: 3.0,
                                                                      bottom: 5.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                      margin:
                                                                           EdgeInsets.symmetric(
                                                                       vertical: 12.0,horizontal: 15),
                                                                      // margin:EdgeInsets.only(right:mHeight*0.03/3,),
                                                                      child: exitIcon !=
                                                                                  '' ||
                                                                              exitIcon!
                                                                                  .isNotEmpty
                                                                          ? Image.asset(
                                                                              exitIcon!,
                                                                              errorBuilder:
                                                                                  (context,
                                                                                      error,
                                                                                      stackTrace) {
                                                                                return Icon(
                                                                                    Icons
                                                                                        .broken_image);
                                                                              },
                                                                            )
                                                                          : const Icon(
                                                                              Icons
                                                                                  .more_horiz,
                                                                              color: Colors
                                                                                  .grey,
                                                                            )),
                                                                  Expanded(
                                                                      child: Text(
                                                                          "$exitNode",
                                                                          overflow:
                                                                              TextOverflow
                                                                                  .ellipsis,
                                                                          maxLines: 1,
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: themeProvider.darkTheme ? Colors.white : Colors.black,fontFamily: 'Inter'
                                                                              //  const Color(
                                                                              //     0xff00DC00)
                                                                                  
                                                                                  ))),
                                                                  // BelnetLib.isConnected == false
                                                                  //     ?
                                                                  //     Container(
                                                                  //         child:
                                                                  const Icon(
                                                                    Icons.arrow_drop_down,
                                                                  )
                                                                  //   )
                                                                  // : Container()
                                                                ],
                                                              ))),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                            
                                  LayoutBuilder(builder: (context, constraint) {
                                    return GestureDetector(
                                      onTap: vpnStatusProvider.value ==
                                              'Disconnected' //isLoading
                                          ? () => toggleBelnet(context, vpnStatusProvider,
                                              loadingtickValueProvider,loc)
                                          // : vpnStatusProvider.value == 'Connected'
                                          // ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Browser()))
                                          : null,
                                      child: 
                                      IntrinsicWidth(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraint.maxWidth / 1.6, // same width as Connect
                                  maxWidth: constraint.maxWidth * 0.70, // 0.95 allow expansion limit
                                ),
                                child: Container(
                                  height: 55,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: vpnStatusProvider.value == 'Disconnected'
                                        ? themeProvider.darkTheme ? Color(0xffEBEBEB) : const Color(0xffEBEBEB)
                                        : themeProvider.darkTheme
                                            ? const Color(0xff222222)
                                            : const Color(0xffEBEBEB),
                                    border: Border.all(color: themeProvider.darkTheme ?  Colors.transparent : Color(0xff8D8D8D))
                                   // borderRadius: BorderRadius.circular(10),
                                  ),
                            
                                  child: vpnStatusProvider.value == 'Disconnected'
                                      ? Center(
                                          child: Text(
                                            loc.connect,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter',
                                              color:  Colors.black,
                                            ),
                                          ),
                                        )
                            
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/ai-icons/new/Loading.gif',
                                              height: 28,
                                              width: 28,
                                            ),
                                            const SizedBox(width: 8),
                            
                                            Flexible(
                                              child: Text(
                            loc.connecting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: themeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                            ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            )
                            
                                      // Container(
                                      //   width: constraint.maxWidth / 1.6,
                                      //   height: 55,
                                      //   decoration: BoxDecoration(
                                      //       color: vpnStatusProvider.value ==
                                      //               'Disconnected'
                                      //           ? Color(0xff00B134)
                                      //           : themeProvider.darkTheme
                                      //               ? Color(0xff282836)
                                      //               : Color(0xffF3F3F3),
                                      //       borderRadius: BorderRadius.circular(10)),
                                      //   child: vpnStatusProvider.value == 'Disconnected'
                                      //       ? Center(
                                      //           child: Text(
                                      //            loc.connect,
                                      //             // vpnStatusProvider.value == 'Disconnected'
                                      //             //     ? 'Connect'
                                      //             //     : vpnStatusProvider.value == 'Connected'
                                      //             //         ? 'Connecting..'
                                      //             //         : vpnStatusProvider.value,
                                                  
                                      //             style: TextStyle(
                                      //                 fontSize:isLengthyLanguageInList(localeProvider.selectedLanguage) ? 13 : 20,
                                      //                 fontWeight: FontWeight.w600,
                                      //                 color: Colors.white),
                                      //             textAlign: TextAlign.center,
                                      //           ),
                                      //         )
                                      //       : 
                                      //       Row(
                                      //           mainAxisSize: MainAxisSize.min,
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.center,
                                      //           children: [
                                      //             Image.asset(
                                      //               themeProvider.darkTheme
                                      //                   ? 'assets/images/Load.gif'
                                      //                   : 'assets/images/Load_white_theme.gif',
                                      //               height: 30,
                                      //               width: 40,
                                      //             ),
                                      //             Text(
                                      //              loc.connecting,
                                      //               // vpnStatusProvider.value == 'Disconnected'
                                      //               //     ? 'Connect'
                                      //               //     : vpnStatusProvider.value == 'Connected'
                                      //               //         ? 'Connecting..'
                                      //               //         : vpnStatusProvider.value,
                                      //               overflow: TextOverflow.ellipsis,
                                      //               maxLines: 2,
                                      //               style: TextStyle(
                                      //                 fontWeight: FontWeight.w600,
                                      //                 fontSize:isLengthyLanguageInList(localeProvider.selectedLanguage) ? 13 : 20,
                                      //               ),
                                      //             ),
                                      //           ],
                                      //         ),
                                      // ),
                                    );
                                  }),
                                  SizedBox(height: 10,),
                                  vpnStatusProvider.value != 'Disconnected'
                                      ? Container(
                                          height: mHeight / 40,
                                          //margin: EdgeInsets.symmetric(vertical: 20),
                                          child: Center(
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                //crossAxisAlignment: CrossAxisAlignment.center,
                                                children: messages
                                                    .map((log) => Text(
                                                          log,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!.copyWith(fontFamily: 'Inter'),
                                                        ))
                                                    .toList()),
                                          ),
                                        )
                                      : Container(
                                          height: mHeight / 40,
                                        ),
                          
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          );
  }

  Widget _buildExitnodeListView(double mHeight, DarkThemeProvider themeProvider,
      VpnStatusProvider vpnStatusProvider,AppLocalizations loc) {
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
            height: 60.0,
            margin: EdgeInsets.only(
                //  top: 300,
                //  bottom: 100,
                top: mHeight * 2.11 / 3, //1.85 / 3, //2.010
                bottom: MediaQuery.of(context).size.height * 0.10 / 3,
                left: mHeight * 0.10 / 3,
                right: mHeight * 0.10 / 3),
            child: GlassDropDownPanel(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.70 / 3,
                width: MediaQuery.of(context).size.width * 2.7 / 3, // 2.7
                // padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                   // borderRadius: BorderRadius.circular(9.0),
                    color: Colors.transparent,
                    // themeProvider.darkTheme
                    //     ? const Color(0xff242436)
                    //     : const Color(0xffF3F3F3),
                    border: Border.all(
                        color: themeProvider.darkTheme
                            ? const Color(0xff333333 //282836
                            )
                            : const Color(0xffF3F3F3))),
                child: exitNodeDataList.length == 0
                    ? Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xff00DC00),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: exitNodeDataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          // print("data inside listview ${exitData[index]}");
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              listTileTheme: ListTileTheme.of(context).copyWith(
                                  dense: true,
                                  minVerticalPadding: 2,
                                  visualDensity: VisualDensity(vertical: 0)),
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.only(
                                  left: mHeight * 0.05 / 3,
                                  right: mHeight * 0.03 / 3),
                              title: Text(
                                exitNodeDataList[index].type == 'Beldex Official' ? loc.beldexofficial : loc.contributorExitNode,
                                style: TextStyle(
                                    color: index == 0
                                        ? const Color(0xff1CBE20)
                                        : const Color(0xff1994FC),
                                    fontSize: MediaQuery.of(context).size.height *
                                        0.048 /
                                        3,
                                        fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold),
                              ),
                              iconColor: index == 0
                                  ? const Color(0xff1CBE20)
                                  : const Color(0xff1994FC),
                              collapsedIconColor: index == 0
                                  ? const Color(0xff1CBE20)
                                  : const Color(0xff1994FC),
                              subtitle: Text(
                                // exitData[index].type == "Custom Exit Node" &&
                                //         customExitAdd.isNotEmpty
                                //     ? "${customExitAdd.length} Nodes":
                                "${exitNodeDataList[index].node.length} ${loc.nodes}",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize: MediaQuery.of(context).size.height *
                                        0.033 /
                                        3),
                              ),
                              children: <Widget>[
                                Column(
                                  children: _buildExpandableContent(
                                      exitNodeDataList[index].node,
                                      exitNodeDataList[index].type,
                                      themeProvider,
                                      mHeight,
                                      vpnStatusProvider),
                                ),
                              ],
                            ),
                          );
                        }
                        // _buildList(exitData[index]),
                        ),
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

  _buildExpandableContent(
      List<exitNodeModel.Node> vnode,
      String type,
      DarkThemeProvider themeProvider,
      double mHeight,
      VpnStatusProvider vpnStatusProvider) {
    List<Widget> columnContent = [];
    for (int i = 0; i < vnode.length; i++) {
      columnContent.add(GestureDetector(
        onTap: () async {
          if (overlayEntry != null //&& exitNode != vnode[i].name
              ) {
            overlayEntry?.remove();
          }
          setState(() {
            //valueS = vnode[i].name;

            exitNode = vnode[i].name;
            exitIcon =
                'assets/images/flags/${vnode[i].country}.png'; //vnode[i].icon;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selectedExitNode', '$exitNode');
          await prefs.setString('selectedCountryIcon', '$exitIcon');

          // print("$i th index value $valueS ");
        },
        child: Container(
          padding: EdgeInsets.only(
              left: mHeight * 0.06 / 3,
              right: mHeight * 0.06 / 3,
              top: mHeight * 0.02 / 3,
              bottom: mHeight * 0.02 / 3),
          height: mHeight * 0.15 / 3,
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
             // borderRadius: BorderRadius.circular(5),
              color:
                  exitNode == vnode[i].name ? themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF) : Colors.transparent,
              border: exitNode == vnode[i].name ? Border.all(color: Color(0xff1CBE20)) :
               Border(
                  bottom: BorderSide(
                      width: 0.5,
                      color: const Color(0xff56566F).withOpacity(0.2)))),
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
                          print('Not taking picture $e -- ${vnode[i].country}');
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
                    //       return const Icon(
                    //         Icons.more_horiz,
                    //         color: Colors.grey,
                    //         size: 0.4,
                    //       );
                    //     },
                    //     loadingBuilder: (context, child, loadingProgress) {
                    //       return const Icon(
                    //         Icons.more_horiz,
                    //         color: Colors.grey,
                    //         size: 0.4,
                    //       );
                    //     },

                    //     // height: MediaQuery.of(context).size.height * 0.10 / 3,
                    //     // width: MediaQuery.of(context).size.height * 0.15 / 3,
                    //     fit: BoxFit.fill,
                    //   )
                    : const Icon(Icons.info_outline_rounded),
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
                            fontFamily: 'Inter',
                              color: 
                              // exitNode == vnode[i].name
                              //     ? 
                                  // Colors.white
                                  // : 
                                  themeProvider.darkTheme
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: exitNode == vnode[i].name
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
                            color: 
                            // exitNode == vnode[i].name
                            //     ? Colors.white
                            //     :
                                 Colors.grey,
                                fontFamily: 'Inter',
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
                    right: MediaQuery.of(context).size.height * 0.030 / 3),
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
