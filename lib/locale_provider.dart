

import 'dart:ui';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  String _selectedLanguage = 'English';
  bool _isDefaultForVoiceSearch = true;

  bool get isDefaultForVoiceSearch =>  _isDefaultForVoiceSearch;

  setDefaultDone(bool value){
    _isDefaultForVoiceSearch = value;
    notifyListeners();
  }
  /// Whether app should follow system language
  bool _followSystemLocale = true;

  Locale get locale => _locale;
  String get selectedLanguage => _selectedLanguage;

String get localeId => _locale.languageCode; //for voice search
  final Map<String, Locale> languages = {
    'English': const Locale('en'),
    'Español': const Locale('es'),
    '日本語': const Locale('ja'),
    'Português': const Locale('pt'),
    'Deutsch': const Locale('de'),
    'Türkçe': const Locale('tr'),
    'Русский': const Locale('ru'),
    '中文': const Locale('zh'),
    '한국어': const Locale('ko'),
    'Tiếng Việt': const Locale('vi'),
    'தமிழ்': const Locale('ta'),
    'العربية': const Locale('ar'),
  };

  LocaleProvider() {
    _loadSavedLocale();

    /// Auto-detect when system language changes
    PlatformDispatcher.instance.onLocaleChanged = () {
      if (_followSystemLocale) {
        final system = PlatformDispatcher.instance.locale;

        final supported = AppLocalizations.supportedLocales.firstWhere(
          (loc) => loc.languageCode == system.languageCode,
          orElse: () => const Locale('en'),
        );

        _locale = supported;
        setSelectedLanguage();
        notifyListeners();
      }
    };
  }


String getLocalizedLanguageName(BuildContext context, String staticName) {
  final loc = AppLocalizations.of(context)!;

  switch (staticName) {
    case 'English': return loc.languageEnglish;
    case 'Español': return loc.languageSpanish;
    case '日本語': return loc.languageJapanese;
    case 'Português': return loc.languagePortuguese;
    case 'Deutsch': return loc.languageGerman;
    case 'Türkçe': return loc.languageTurkish;
    case 'Русский': return loc.languageRussian;
    case '中文': return loc.languageChinese;
    case '한국어': return loc.languageKorean;
    case 'Tiếng Việt': return loc.languageVietnamese;
    case 'தமிழ்': return loc.languageTamil;
    case 'العربية': return loc.languageArabic;
    default: return loc.languageEnglish;
  }
}


  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCode = prefs.getString('locale');
    _followSystemLocale = prefs.getBool('followSystemLocale') ?? true;

    if (_followSystemLocale) {
      /// Use system language
      final system = PlatformDispatcher.instance.locale;
      final supported = AppLocalizations.supportedLocales.firstWhere(
        (loc) => loc.languageCode == system.languageCode,
        orElse: () => const Locale('en'),
      );
      _locale = supported;
      setSelectedLanguage();
    } else if (savedCode != null) {
      /// Use user-selected language
      _locale = Locale(savedCode);
      setSelectedLanguage();
    }

    notifyListeners();
  }

  /// User manually selects language (override system language)
  Future<void> setLocale(Locale locale) async {
    _followSystemLocale = false; // user override system language

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    await prefs.setBool('followSystemLocale', false);

    _locale = locale;
    setSelectedLanguage();
    notifyListeners();
  }

  /// Maps locale → language name
  Future<void> setSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    _selectedLanguage = languages.entries
        .firstWhere(
          (entry) => entry.value.languageCode == _locale.languageCode,
          orElse: () => const MapEntry('English', Locale('en')),
        )
        .key;

    await prefs.setString('selectedLang', _selectedLanguage);
  }

  /// User wants to follow system language again
  Future<void> resetToSystemLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _followSystemLocale = true;

    await prefs.setBool('followSystemLocale', true);
    await prefs.remove('locale');

    // Apply system language immediately
    final system = PlatformDispatcher.instance.locale;

    final supported = AppLocalizations.supportedLocales.firstWhere(
      (loc) => loc.languageCode == system.languageCode,
      orElse: () => const Locale('en'),
    );

    _locale = supported;
    setSelectedLanguage();
    notifyListeners();
  }

// for voice search
  String get fullLocaleId {
  if (_locale.countryCode != null) {
    return "${_locale.languageCode}-${_locale.countryCode}";
  }
  return _locale.languageCode;
}



/// Reset app language to English (override system language)
Future<void> resetAppLocaleToEnglish() async {
  final prefs = await SharedPreferences.getInstance();

  // Disable system language following
  _followSystemLocale = false;
  await prefs.setBool('followSystemLocale', false);

  // Set locale to English
  _locale = const Locale('en');
  await prefs.setString('locale', 'en');

  // Update selected language label
  _selectedLanguage = 'English';
  await prefs.setString('selectedLang', 'English');

  notifyListeners();
}

}
