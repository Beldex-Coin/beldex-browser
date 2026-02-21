import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
//import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatelessWidget {
   ChatMessage({super.key, required this.text, required this.sender, required this.ai, this.aiResponse='loading'});

  final String text;
  final String sender;
  final String ai;
   String aiResponse;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        themeProvider.darkTheme 
                                        ? 'assets/images/ai-icons/MaleUser1.svg'
                                        : 'assets/images/ai-icons/Male User 1.svg'),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(loc.you,style: TextStyle(color: Color(0xff9595B5))),
                                      ),
                                      Spacer(),
                                      SvgPicture.asset(IconConstants.copyIconDark),
                                      
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Text(text) //Text('How much is BDX coin in 2030? How much is BDX coin in 2030?How much is BDX coin in 2030? How much is BDX coin in 2030?'),
                                ),
                                Divider(
                                  color: Color(0xff42425F),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(IconConstants.beldexAILogoSvg,height: 20,width: 20,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(StringConstants.beldexAI,style: TextStyle(color: Color(0xff9595B5)),),),
                                      Spacer(),
                                       SvgPicture.asset(IconConstants.copyIconDark),
                                       
                                    ],
                                  ),
                                ),
                                   Padding(
          padding: const EdgeInsets.all(13.0),
          child: Consumer<VpnStatusProvider>(
            builder: (context, provider, _) {
              return provider.aiResponse == 'loading'
                  ? Lottie.asset(IconConstants.bubbleLoaderDark)
                  : Text(provider.aiResponse);
            },
          ),
        ),

      ],
    );
    
       }
}
