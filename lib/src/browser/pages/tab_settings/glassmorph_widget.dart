import 'dart:ui';

import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;

  const GlassPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return ClipRRect(
      //borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:themeProvider.darkTheme ? const Color(0xFF222222).withOpacity(0.5) : const Color(0xffD4D4D4).withOpacity(0.7),
            // border: Border.all(
            //   color: const Color(0xFF333333),
            //   width: 0.5,
            // ),
           // borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}


class GlassDropDownPanel extends StatelessWidget {
  final Widget child;

  const GlassDropDownPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return ClipRRect(
      //borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:themeProvider.darkTheme ? const Color(0xFF111111).withOpacity(0.9) : const Color(0xffEBEBEB).withOpacity(0.7),
            // border: Border.all(
            //   color: const Color(0xFF333333),
            //   width: 0.5,
            // ),
           // borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}





class GlassAppTile extends StatelessWidget {
  final String icon;
  final String title;

  const GlassAppTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          //width: 110,
         // height: 95,
         padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.10): Color(0xffACACAC).withOpacity(0.1),
            border: Border.all(
              color:themeProvider.darkTheme ? Color(0xff1A1A1A): Color(0xffD4D4D4),//.withOpacity(0.10),
              width: 0.7,
            ),
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Colors.white.withOpacity(0.08),
            //     Colors.white.withOpacity(0.02),
            //   ],
            // ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.white.withOpacity(0.03),
            //     blurRadius: 10,
            //     spreadRadius: 1,
            //   ),
            // ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.08): Color(0xffEBEBEB).withOpacity(0.5),
                  border: Border.all(
                    color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4),
                  ),
                ),
                child: SvgPicture.asset(icon,)
                // Icon(
                //   icon,
                //   color: Colors.white70,
                //   size: 26,
                // ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:  TextStyle(
                  color:themeProvider.darkTheme ? Color(0xff949494): Color(0xff949494),
                  fontSize: 11,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900
                  //height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class GlassCommonPanel extends StatelessWidget {
  final Widget child;

  const GlassCommonPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return ClipRRect(
      //borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:themeProvider.darkTheme ? const Color(0xFF222222).withOpacity(0.5) : const Color(0xffFFFFFF).withOpacity(0.7),
            border: Border.all(
              color: themeProvider.darkTheme ? Colors.transparent : Color(0xffD4D4D4), //const Color(0xFF333333),
              width: 0.5,
            ),
           // borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassSettingPanel extends StatelessWidget {
  final Widget child;
  final Color color;
  final Border? border;
  const GlassSettingPanel({
    super.key,
    required this.child, required this.color, this.border
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      //borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: //const Color(0xFF222222)
            color,
            border: border
            // border: Border.all(
            //   color: const Color(0xFF333333),
            //   width: 0.5,
            // ),
           // borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassAppsPanel extends StatelessWidget {
  final Widget child;
  final Color color;
  final Border? border;

  const GlassAppsPanel({
    super.key,
    required this.child,
    required this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: color,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassGroupPanel extends StatelessWidget {
  final Widget child;
  final Color color;

  const GlassGroupPanel({
    super.key,
    required this.child, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      //borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: //const Color(0xFF222222)
            color.withOpacity(0.1),
            // border: Border.all(
            //   color: const Color(0xFF333333),
            //   width: 0.5,
            // ),
           // borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}


class GlassMenuPanel extends StatelessWidget {
  final Widget child;
  final Color color;

  const GlassMenuPanel({
    super.key,
    required this.child, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      //borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: //const Color(0xFF222222)
            color //.withOpacity(0.1),
            // border: Border.all(
            //   color: const Color(0xFF333333),
            //   width: 0.5,
            // ),
           // borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}