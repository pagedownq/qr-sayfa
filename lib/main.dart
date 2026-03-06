import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'firebase_options.dart';
import 'onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';
import 'services/analytics_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/app_state.dart';
import 'services/iap_service.dart';
import 'services/haptic_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Ads (Mobile Ads SDK)
  await MobileAds.instance.initialize();

  // 1. Initialize Local Storage & Services First (to get cached status)
  await StorageService.init();
  StorageService.loadData();
  HapticService.init(isHapticEnabledNotifier);

  // 2. Initialize In-App Purchases & Sync Premium State (takes time/network)
  await IAPService().initialize();

  // Fetch App Version
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appVersionNotifier.value = packageInfo.version;

  await initLocale();

  // Check login and onboarding status
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  // If first time OR NOT logged in, show onboarding/login
  final bool showOnboarding = isFirstTime || !isLoggedIn;

  runApp(MyApp(showOnboarding: showOnboarding));
}

class KeyboardDismisserObserver extends NavigatorObserver {
  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return CupertinoApp(
          title: 'Qurio',
          theme: const CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFF00D2FF),
            scaffoldBackgroundColor: Color(0xFF0F172A),
            barBackgroundColor: Color(0xFF1E293B),
          ),
          locale: locale,
          supportedLocales: const [
            Locale('en', ''),
            Locale('tr', ''),
            Locale('de', ''),
            Locale('ru', ''),
          ],
          home: showOnboarding ? const OnboardingScreen() : const MainScreen(),
          navigatorObservers: [
            AnalyticsService.observer,
            KeyboardDismisserObserver(),
          ],
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
