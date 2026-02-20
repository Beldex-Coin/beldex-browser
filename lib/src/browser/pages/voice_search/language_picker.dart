import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/pages/voice_search/voice_search.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

Future<String?> pickLanguage(BuildContext context,DarkThemeProvider themeProvider) async {
  final speech = SpeechController();
  final langs = await speech.getAvailableLanguages();

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return VoiceSearchLanguageList(langs: langs,);

    },
  );
}

final Map<String, Map<String, String>> localizedMessages = {
  'cmn-CN': { // Chinese (Simplified, China)
    'speak': '请说出要搜索的内容',
    'tryAgain': '没有听清楚。\n请再试一次。',
  },
  'cmn-TW': { // Chinese (Traditional, Taiwan)
    'speak': '請說出要搜尋的內容',
    'tryAgain': '沒有聽清楚。\n請再試一次。',
  },
  'en-AU': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'zh-TW':{
    'speak': '請說出要搜尋的內容',
    'tryAgain': '沒有聽清楚。\n請再試一次。',
  },
  'en-CA': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'en-IN': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'en-IE': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'en-SG': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'en-GB': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'en-US': {
    'speak': 'Speak to search',
    'tryAgain': 'Couldn’t hear that.\nTry again!',
  },
  'fr-BE': {
    'speak': 'Parlez pour rechercher',
    'tryAgain': 'Je n’ai pas bien entendu.\nRéessayez!',
  },
  'fr-CA': {
    'speak': 'Parlez pour rechercher',
    'tryAgain': 'Je n’ai pas bien entendu.\nRéessayez!',
  },
  'fr-FR': {
    'speak': 'Parlez pour rechercher',
    'tryAgain': 'Je n’ai pas bien entendu.\nRéessayez!',
  },
  'fr-CH': {
    'speak': 'Parlez pour rechercher',
    'tryAgain': 'Je n’ai pas bien entendu.\nRéessayez!',
  },
  'de-AT': {
    'speak': 'Sprechen Sie, um zu suchen',
    'tryAgain': 'Ich habe das nicht verstanden.\nVersuchen Sie es erneut!',
  },
  'de-BE': {
    'speak': 'Sprechen Sie, um zu suchen',
    'tryAgain': 'Ich habe das nicht verstanden.\nVersuchen Sie es erneut!',
  },
  'de-DE': {
    'speak': 'Sprechen Sie, um zu suchen',
    'tryAgain': 'Ich habe das nicht verstanden.\nVersuchen Sie es erneut!',
  },
  'de-CH': {
    'speak': 'Sprechen Sie, um zu suchen',
    'tryAgain': 'Ich habe das nicht verstanden.\nVersuchen Sie es erneut!',
  },
  'hi-IN': {
    'speak': 'खोजने के लिए बोलें',
    'tryAgain': 'सुनाई नहीं दिया।\nफिर से कोशिश करें।!',
  },
  'id-ID': {
    'speak': 'Bicara untuk mencari',
    'tryAgain': 'Tidak terdengar.\nCoba lagi!',
  },
  'it-IT': {
    'speak': 'Parla per cercare',
    'tryAgain': 'Non ho sentito.\nRiprova!',
  },
  'it-CH': {
    'speak': 'Parla per cercare',
    'tryAgain': 'Non ho sentito.\nRiprova!',
  },
  'ja-JP': {
    'speak': '検索するために話してください',
    'tryAgain': '聞き取れませんでした。\nもう一度お試しください。',
  },
  'ko-KR': {
    'speak': '검색하려면 말하세요',
    'tryAgain': '잘 듣지 못했습니다.\n다시 시도하세요!',
  },
  'pl-PL': {
    'speak': 'Powiedz, aby wyszukać',
    'tryAgain': 'Nie usłyszałem.\nSpróbuj ponownie!',
  },
  'pt-BR': {
    'speak': 'Fale para pesquisar',
    'tryAgain': 'Não ouvi direito.\nTente novamente!',
  },
  'ru-RU': {
    'speak': 'Скажите, чтобы искать',
    'tryAgain': 'Не расслышал.\nПопробуйте ещё раз!',
  },
  'es-ES': {
    'speak': 'Habla para buscar',
    'tryAgain': 'No se oyó bien.\nInténtalo de nuevo!',
  },
  'es-US': {
    'speak': 'Habla para buscar',
    'tryAgain': 'No se oyó bien.\nInténtalo de nuevo!',
  },
  'th-TH': {
    'speak': 'พูดเพื่อค้นหา',
    'tryAgain': 'ไม่ได้ยิน\nลองอีกครั้ง',
  },
  'tr-TR': {
    'speak': 'Aramak için konuşun',
    'tryAgain': 'Duyamadım.\nTekrar deneyin!',
  },
  'vi-VN': {
    'speak': 'Nói để tìm kiếm',
    'tryAgain': 'Không nghe rõ.\nThử lại!',
  },
};

String normalizeLocale(String localeId) {
  // Replace underscores with dash, e.g., zh_CN -> zh-CN
  return localeId.replaceAll('_', '-');
}
String getLocalizedMessage(String localeId, String key) {
 final normalized = normalizeLocale(localeId);
  print('Selected Locale in here id is $localeId ----- ${localizedMessages[normalized]?[key] ?? localizedMessages['en-US']![key]!}');
  return localizedMessages[normalized]?[key] ?? localizedMessages['en-US']![key]!;
}






class VoiceSearchLanguageList extends StatefulWidget {
final List<stt.LocaleName> langs;

  const VoiceSearchLanguageList({super.key, required this.langs});

  @override
  State<VoiceSearchLanguageList> createState() => _VoiceSearchLanguageListState();
}

class _VoiceSearchLanguageListState extends State<VoiceSearchLanguageList> {
SpeechController speech = SpeechController();
String? _selectedLocaleId = 'en-US';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
        final loc = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
         initialChildSize: 0.95,
                    minChildSize: 0.3,
                    maxChildSize: 0.95,
  //expand: false,
  builder: (context, scrollController) {
    return LayoutBuilder(
      builder: (context,constraint) {
        return Container(   //  wrap in Container
         decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.vertical(top: Radius.circular(20)),
                                    border: Border(top: BorderSide(color:themeProvider.darkTheme ? Color(0xff42425F): Color(0xffDADADA),width: 0.5)),
                                color: themeProvider.darkTheme ? Color(0xff171720) : Color(0xffFFFFFF)
                                ),
          child: Column(
            children: [
             // SizedBox(height: 10),
              // Container(
              //   height: 4,
              //   width: 40,
              //   decoration: BoxDecoration(
              //     color: Colors.grey[400],
              //     borderRadius: BorderRadius.circular(2),
              //   ),
              // ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: ()=> Navigator.pop(context),
                      child: SvgPicture.asset('assets/images/back.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black,)),
                    // Icon(Icons.arrow_back),
                    SizedBox(width: 15,),
                    Text(loc.chooseLanguage,
                     // "Choose Language",
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Divider(
                     color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
                     ),
             Expanded(
  child: ListView.builder(
    controller: scrollController,
    itemCount: languageIdList.length,
    itemBuilder: (c, i) {
      final name = languageIdList.keys.elementAt(i);
      final localeId = languageIdList.values.elementAt(i);
    print('THE CURRENT SELECTED LOCALE ${speech.currentLocale}');
      return InkWell(
        onTap: () {
          setState(() {});
          speech.setCurrentLocale(normalizeLocale(localeId));
          Navigator.pop(context, speech.currentLocale);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: speech.currentLocale == normalizeLocale(localeId) &&
                    !themeProvider.darkTheme
                ? const Color(0xffF3F3F3)
                : Colors.transparent,
            border: Border.all(
              color: speech.currentLocale == normalizeLocale(localeId) &&
                      themeProvider.darkTheme
                  ? const Color(0xff39394B)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    Text(getLocalizedVoiceSearchLanguageName(context,name),style: TextStyle(fontSize:10,color: themeProvider.darkTheme ? Color(0xffB9B9BE) : Color(0xff78787D)),)
                  ],
                ),
              ),
              Visibility(
                visible: speech.currentLocale == normalizeLocale(localeId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SvgPicture.asset('assets/images/tick.svg',height: 20,),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
)
              // Expanded(
              //   child: ListView.builder(
              //     controller: scrollController,
              //     itemCount: widget.langs.length,
              //     itemBuilder: (c, i) {
              //       final lang = widget.langs[i];
              //       print('LANGUAGE ${speech.currentLocale} ------ ${lang.localeId}');
              //       return 
                    
              //       InkWell(
              //         onTap: (){
              //           setState(() {
              //             //_selectedLocaleId = lang.localeId;
                          
              //           });
                        
              //           speech.setCurrentLocale(normalizeLocale(lang.localeId));
              //            Navigator.pop(context, speech.currentLocale); 
              //         },
              //         child: Container(
              //           margin: EdgeInsets.symmetric( horizontal: 8),
              //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
              //           color: speech.currentLocale == normalizeLocale(lang.localeId) && !themeProvider.darkTheme ? Color(0xffF3F3F3) : Colors.transparent,
              //           border: Border.all(color:speech.currentLocale == normalizeLocale(lang.localeId) && themeProvider.darkTheme ? Color(0xff39394B) : Colors.transparent )
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //            children:[
              //                 Padding(
              //                   padding: const EdgeInsets.all(15.0),
              //                   child: Text(lang.name,style: TextStyle(fontFamily: 'Poppins',)),
              //                 ),
              //              Visibility(
              //               visible: speech.currentLocale == normalizeLocale(lang.localeId),
              //                child: Padding(
              //                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
              //                  child: SvgPicture.asset('assets/images/tick.svg'),
              //                ),
              //              ),
              //             // Checkbox(
              //             //   value: _selectedLocaleId == lang.localeId, onChanged: (checked){
              //             //    setState(() {
              //             //         _selectedLocaleId =
              //             //             checked == true ? lang.localeId : null;
              //             //       });
              //             //       Navigator.pop(context, _selectedLocaleId); // return selection
              //             // })
              //            ]
              //           ),
              //         ),
              //       );
              //       // ListTile(
              //       //   title: Text(lang.name,style: TextStyle(fontFamily: 'Poppins',),),
              //       //   //subtitle: Text(lang.localeId,style: TextStyle(color: Colors.black),),
              //       //   onTap: () {
              //       //     Navigator.pop(context, lang.localeId);
              //       //   },
              //       // );
              //     },
              //   ),
              // ),
            ],
          ),
        );
      }
    );
  },
);
  }
}
