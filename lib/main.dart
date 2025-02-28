import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:beldex_browser/fetch_price.dart';
import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
import 'package:beldex_browser/src/browser/ai/di/locator.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/connect_vpn_home.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_styles.dart';
import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
// ignore: non_constant_identifier_names
late final String WEB_ARCHIVE_DIR;
// ignore: non_constant_identifier_names
late final double TAB_VIEWER_BOTTOM_OFFSET_1;
// ignore: non_constant_identifier_names
late final double TAB_VIEWER_BOTTOM_OFFSET_2;
// ignore: non_constant_identifier_names
late final double TAB_VIEWER_BOTTOM_OFFSET_3;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_1 = 0.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_2 = 10.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_3 = 20.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_SCALE_TOP_OFFSET = 250.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_SCALE_BOTTOM_OFFSET = 230.0;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin(); // global instance

void showProgressNotification(String id, int progress) {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'beldex_browser', // Channel ID
    'Beldex Browser',
    channelShowBadge: false,
    importance: Importance.low,
    priority: Priority.low,
    onlyAlertOnce: true,
    showProgress: true,
    maxProgress: 100,
    progress: progress,
  );

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    'Download Progress', // Title
    'Downloading file $id', // Body
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void downloadCallback(String id, int status, int progress) {
  if (kDebugMode) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  }
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);

  showProgressNotification(id, progress);
}

const String channelId = 'beldex_browser';
const String channelName = 'Beldex Browser';
const String channelDescription = 'Beldex Browser';

Future<void> setupNotificationChannel() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Define Android and iOS initialization settings
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Define Android notification channel
  var androidChannel = const AndroidNotificationChannel(
    channelId,
    channelName,
    importance: Importance.high,
  );

  // Set the channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
  await FlutterDownloader.registerCallback(downloadCallback);
  await SharedPreferences.getInstance();
  WEB_ARCHIVE_DIR = (await getApplicationSupportDirectory()).path;

  TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
  TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
  TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;

  // await FlutterDownloader.initialize(
  //   debug: kDebugMode,ignoreSsl: true
  // );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();
  setUpLocator(); // For AI
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewModel(),
        ),
        ChangeNotifierProvider(
            create: (context) => VpnStatusProvider()..loadSavedValue()),
        ChangeNotifierProvider(create: ((context) => SearchEngineProvider())),
        ChangeNotifierProvider(
            create: ((context) => LoadingtickValueProvider())),
        ChangeNotifierProvider(create: (context) => DownloadProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                SelectedItemsProvider()..initializeSelectedItems()..updateIconWhenNotSerchEngine()),
        ChangeNotifierProvider(
            create: (context) => BasicProvider()..loadFromPrefs()),
        ChangeNotifierProvider(create: (context)=> UrlSummaryProvider()),
        ChangeNotifierProvider(create: (_)=> AIModelProvider()..initializeModel()),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          update: (context, webViewModel, browserModel) {
            browserModel!.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
          create: (BuildContext context) => BrowserModel(),
        ),
         ChangeNotifierProvider(create: (context) => PriceValueProvider()..startFetching())
      ],
      child: const BeldexBrowserApp(),
    ),
  );
}

class BeldexBrowserApp extends StatefulWidget {
  const BeldexBrowserApp({super.key});

  @override
  State<BeldexBrowserApp> createState() => _BeldexBrowserAppState();
}

class _BeldexBrowserAppState extends State<BeldexBrowserApp> with WidgetsBindingObserver{
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();
  late bool isSwitched;
  StreamSubscription<bool>? _isConnectedEventSubscription;
  // late VpnStatusProvider vpnStatusProvider;

  AppUpdateInfo? updateInfo;
  bool _isUpdating = false;



  @override
  void initState() {
    super.initState();
    clearCookie();
    WidgetsBinding.instance.addObserver(this);
    _isConnectedEventSubscription = BelnetLib.isConnectedEventStream
        .listen((bool isConnected) => setState(() {
              print('is belnet app connected ? $isConnected');
              setVPNStatus(context, isConnected);
            }));
    getCurrentAppTheme();
    Provider.of<BasicProvider>(context, listen: false).loadFromPrefs();
     loadSwitchState(context);
   // checkAppUpdate(context);
   
  }

 
Future<void> checkAppUpdate(context) async {
    print('this function is calling for update');
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        updateInfo = info;
      });
      updateFunction();
    }).catchError((e) {
       showMessage(e.toString());
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text(e.toString())));
    });
  }

  updateFunction() {
    if (updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      print('update is available');
      InAppUpdate.performImmediateUpdate().catchError((e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        return AppUpdateResult.inAppUpdateFailed;
      });
    }
  }






    int count = 0;
  void setVPNStatus(BuildContext context, bool isConnected) async {
         bool running = await BelnetLib.isRunning; 
    print('this function is called because vpn diconnected');
    final vpnStatusProvider =
        Provider.of<VpnStatusProvider>(context, listen: false);
    setState(() {
      if (vpnStatusProvider.value =='Connected') {
        Future.delayed(Duration(milliseconds: 300), () {
          if (isConnected == false) {
            print('belnet vpn is disconnected');
             SystemNavigator.pop();
          }
        });
      }else if(vpnStatusProvider.value == 'Connecting...'&& vpnStatusProvider.isChangeNode == false){
        print('belnet is running $running');
              // Future.delayed(Duration(milliseconds: 600), () {
          if (running == true) {
            print('belnet is disconnected111');
             count = 1;
          }
          if(count == 1){
            if(running == false){
              SystemNavigator.pop();
            }
          }
        //});
      }
    });
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  loadSwitchState(BuildContext context) {
    Future.delayed(Duration(milliseconds: 200), () {
      checkIsScreenSecure();
    });
  }

  checkIsScreenSecure() async {
    final basicProvider = Provider.of<BasicProvider>(context, listen: false);
    final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false );
   // final webViewModel = Provider.of<WebViewModel>(context,listen: false);
    //print('screen security 3---->${basicProvider.scrnSecurity}');
    if (basicProvider.scrnSecurity) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    selectedItemsProvider.updateFontSize(8.0);
    //print('The WEBView fontSize ---> fontSize ${selectedItemsProvider.fontSize} ${webViewModel.settings?.minimumFontSize}');
  }

 @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    vpnStatusProvider.updateAppState(state);
    super.didChangeAppLifecycleState(state);
    print('App lifecycle state changed: $state');
    switch(state){
      case AppLifecycleState.detached:
          exit(0);
      case AppLifecycleState.resumed:
      //print("App life cycle state ----->>> $state");
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isConnectedEventSubscription!.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) {
      return themeChangeProvider;
    }, child: Consumer<DarkThemeProvider>(
      builder: (context, value, child) {
        return GetMaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'Beldex Browser',
          debugShowCheckedModeBanner: false,
          theme: Styles.themeData(themeChangeProvider.darkTheme, context),
          initialRoute: '/',
          routes: {
            '/': (context) => const ConnectVpnHome() //Browser(),
          },
        );
      },
    )
        // Consumer<DarkThemeProvider>(
        //   builder: (BuildContext context, value, Widget child) {
        //     // return MaterialApp(
        //     //     title: 'Beldex Browser',
        //     //     debugShowCheckedModeBanner: false,
        //     //     // theme: ThemeData(
        //     //     //   primarySwatch: Colors.blue,
        //     //     //   visualDensity: VisualDensity.adaptivePlatformDensity,
        //     //     // ),
        //     //     initialRoute: '/',
        //     //     routes: {
        //     //       '/': (context) => const ConnectVpnHome() //Browser(),
        //     //     },
        //     //         );
        //   }
        // )

        );
  }
}
