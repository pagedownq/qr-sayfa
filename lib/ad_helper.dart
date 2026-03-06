import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3777090766109762/2553456505';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3777090766109762/1223270371';
    }
    return '';
  }

  // Interstitial Ad Unit ID (Geçiş reklamı)
  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3777090766109762/6436715400';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3777090766109762/8523321685';
    }
    return '';
  }



  // Native Advanced Ad Unit ID (Yerel gelişmiş reklam)
  static String get nativeAdvancedAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3777090766109762/1160483789';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3777090766109762/7597107035';
    }
    return '';
  }
}

