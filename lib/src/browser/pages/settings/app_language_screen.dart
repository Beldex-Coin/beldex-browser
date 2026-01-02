import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/browser/pages/voice_search/voice_search.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key});

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {

  TextEditingController _searchController = TextEditingController();

late List<String> _filteredLanguages;

@override
void initState() {
  super.initState();
  _filteredLanguages =
      context.read<LocaleProvider>().languages.keys.toList();
}

void _filterLanguages(String query) {
  final localeProvider = context.read<LocaleProvider>();

  if (query.isEmpty) {
    setState(() {
      _filteredLanguages = localeProvider.languages.keys.toList();
    });
    return;
  }

  final q = query.toLowerCase();

  setState(() {
    _filteredLanguages = localeProvider.languages.keys.where((language) {
      final staticName = language.toLowerCase();
      final localizedName =
          localeProvider.getLocalizedLanguageName(context, language).toLowerCase();

      return staticName.contains(q) || localizedName.contains(q);
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<DarkThemeProvider>(context);
     final theme = Theme.of(context);
     final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
        appBar:normalAppBar(context,loc.chooseLanguage,themeProvider),
        body: Container(
          child: Column(
            children: [
              Container(
                 height: 50,
            width: double.infinity,
            margin:
                const EdgeInsets.only(top:10, left: 10, right: 10, bottom: 8),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ? const Color(0xff282836)
                    : const Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(7)),
                child: TextField(
                                                    onSubmitted: (value) {
                                                    
                                                    },
                                                    keyboardType:
                                                        TextInputType.url,
                                                    decoration: InputDecoration(
                                                       contentPadding: const EdgeInsets.only(left:10,
                            top: 10.0, right: 10.0, bottom: 10.0),
                        border: InputBorder.none,
                        hintText:loc.searchOrEnterAddress,
                        prefixIcon: Padding(
                          padding:EdgeInsets.only(top: 13,bottom: 13,left: 13), //EdgeInsetsDirectional.only(start: 20.0),
                          child: SvgPicture.asset('assets/images/ai-icons/Search_suggestion.svg',height: 10,),
                        ),
                        
                       // prefix: 
                        hintStyle: TextStyle(
                            color: const Color(0xff6D6D81),
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal),
                            ),
                    style: theme.textTheme.bodyMedium,
                                                     
                                                    
                                                    controller:
                                                        _searchController,
                                                        magnifierConfiguration:TextMagnifierConfiguration.disabled,
                                                 onChanged: _filterLanguages,
                                                    
                                                  ),
              ),
              Expanded(
  child: ListView.builder(
    itemCount: _filteredLanguages.length,
itemBuilder: (c, i) {
  final language = _filteredLanguages[i];
    // itemCount: localeProvider.languages.length,
    // itemBuilder: (c, i) {
    //     final language =
    //               localeProvider.languages.keys.elementAt(i);
   
      return InkWell(
        onTap: () {
          //setState(() {});
          localeProvider.setLocale(localeProvider.languages[language]!);
          //speech.setCurrentLocale(normalizeLocale(localeId));
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(10),
            color:// speech.currentLocale == normalizeLocale(localeId) &&
                    !themeProvider.darkTheme
                ? const Color(0xffF3F3F3)
                : Colors.transparent,
            border: Border(bottom: BorderSide(color:i != localeProvider.languages.length ?  themeProvider.darkTheme
                  ? const Color(0xff39394B)
                  : Color(0xffDADADA): Colors.transparent ) )
            
            //  Border. all(
            //   color: //speech.currentLocale == normalizeLocale(localeId) &&
            //           themeProvider.darkTheme
            //       ? const Color(0xff39394B)
            //       : Colors.transparent,
            // ),
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
                      language,
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    Text(localeProvider.getLocalizedLanguageName(context,language),style: TextStyle(fontFamily: 'Poppins', fontSize:10,color: themeProvider.darkTheme ? Color(0xffB9B9BE) : Color(0xff78787D)),)
                  ],
                ),
              ),
              Visibility(
                visible:language== localeProvider.selectedLanguage,   // speech.currentLocale == normalizeLocale(localeId),
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
            ],
          ),
        ),
    );
  }
} 