import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: themeProvider.darkTheme
              ? [
                  const Color(0xFF242430),
                 const Color(0xFF1C1C26),
                ]
              : [
                 const Color(0xFFF9F9F9),
                 const Color(0xFFEBEBEB),
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.40 / 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 1 / 3,
                    width: MediaQuery.of(context).size.width * 1.3 / 3,
                    child: SvgPicture.asset(
                        'assets/images/nointernet.svg',
                        color: themeProvider.darkTheme
                            ? Color(0xff4D4D64)
                            : Color(0xffC7C7C7),
                        height: MediaQuery.of(context).size.height * 0.20 / 3)),
                Container(
                  padding:const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: Center(
                    child: TextWidget(
                      text:loc.noInternetConnection,// 'No internet connection.',
                      style: TextStyle(
                          color: themeProvider.darkTheme
                              ?const Color(0xffA1A1C1)
                              : const Color(0xff56566F),
                          fontWeight: FontWeight.w900,
                          fontSize:
                              MediaQuery.of(context).size.height * 0.08 / 3,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                Container(
                    //color: Colors.green,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.height * 0.14 / 3,
                        right: MediaQuery.of(context).size.height * 0.14 / 3,
                        top: 5.0),
                    child: Center(
                        child: TextWidget(
                           text:loc.youAreNotConnectedToInternet,// 'You are not connected to the internet. Make sure WiFi/Mobile data is on.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: themeProvider.darkTheme
                                    ?const Color(0xffA1A1C1)
                                    :const Color(0xff56566F),
                                fontFamily: 'Poppins')))),
               const Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.35 / 3),
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.20 / 3,
                      width: MediaQuery.of(context).size.height * 0.70 / 3,
                      decoration: BoxDecoration(
                          color:const Color(0xff00DC00),
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          border:
                              Border.all(color: Color(0xff00DC00), width: 2)),
                      child: TextButton(
                        child: TextWidget(
                         text:loc.retry,// 'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize:
                                MediaQuery.of(context).size.height * 0.07 / 3,
                            // fontWeight: FontWeight.w900
                          ),
                        ),
                        onPressed: () {},
                      )),
                )
              ],
            )),
      ),
    );
  }
}
