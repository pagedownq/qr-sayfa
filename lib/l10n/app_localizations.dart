import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';

/// Supported locales
const List<Locale> supportedLocales = [
  Locale('en'), // English (default)
  Locale('tr'), // Turkish
  Locale('de'), // German
  Locale('ru'), // Russian
];

/// Global locale notifier
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

/// Initialize locale from saved preference or device language
Future<void> initLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('app_language');
  
  if (saved != null && supportedLocales.any((l) => l.languageCode == saved)) {
    localeNotifier.value = Locale(saved);
  } else {
    // Auto-detect device language
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceLang = deviceLocale.languageCode;
    
    if (supportedLocales.any((l) => l.languageCode == deviceLang)) {
      localeNotifier.value = Locale(deviceLang);
    } else {
      localeNotifier.value = const Locale('en'); // Default English
    }
  }
}

/// Save locale preference
Future<void> setLocale(Locale locale) async {
  localeNotifier.value = locale;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_language', locale.languageCode);
}

/// Get translated string by key
String tr(String key) {
  final lang = localeNotifier.value.languageCode;
  final map = translations[lang] ?? translations['en']!;
  return map[key] ?? translations['en']?[key] ?? key;
}

/// Get language display name
String getLanguageName(String code) {
  switch (code) {
    case 'tr': return 'Türkçe';
    case 'en': return 'English';
    case 'de': return 'Deutsch';
    case 'ru': return 'Русский';
    default: return code;
  }
}

/// Get language flag emoji
String getLanguageFlag(String code) {
  switch (code) {
    case 'tr': return '🇹🇷';
    case 'en': return '🇬🇧';
    case 'de': return '🇩🇪';
    case 'ru': return '🇷🇺';
    default: return '🌍';
  }
}
