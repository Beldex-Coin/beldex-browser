import 'dart:async';



import 'package:beldex_browser/src/connect_vpn_home.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';


class SplashScreens extends StatefulWidget {
  const SplashScreens({Key? key}) : super(key: key);

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens>
    with WidgetsBindingObserver {
 //AnimationController? _controller;

//  late VideoPlayerController _videoController;
 Timer? timer;

  @override
  void initState() {
    super.initState();
  

    WidgetsBinding.instance.addObserver(this);
  
  timer = Timer(const Duration(seconds: 4), () {
    _goToNextScreen();
    });

  }

void _goToNextScreen()async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
   //getStatus(context);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ConnectVpnHome() //isFirstLaunch ? OnboardingScreen() : MainBottomNavbar() //BelnetHomePage()
      ),
    );
  }












@override
  void dispose() {
    timer?.cancel();
    //_controller!.dispose();
   // _videoController.dispose();
        WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<DarkThemeProvider>(context);
    return
      Scaffold(
        extendBody: true,
      backgroundColor: Colors.black,// Color(0xff1C1C26),
         body:Center(
          child:themeProvider.darkTheme ? Image.asset('assets/images/ai-icons/new/Splash_screen_dark_theme.gif',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          ): Image.asset('assets/images/ai-icons/new/Splash_white_theme.gif',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          ),
         )
       
    );
  }
}