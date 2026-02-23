import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Sayfa/Ekran görüntülendiğinde çalışır
  static Future<void> logScreenView(String screenName, {String? screenClass}) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      if (kDebugMode) {
        debugPrint('Analytics: Screen View -> $screenName');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Screen View): $e');
    }
  }

  /// Kullanıcı giriş yaptığında (Onboarding / Login)
  static Future<void> logLogin({required String loginMethod}) async {
    try {
      await _analytics.logEvent(
        name: 'giris_yap',
        parameters: {
          'giris_yontemi': loginMethod,
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: Login -> $loginMethod');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Login): $e');
    }
  }

  /// Yeni bir link eklendiğinde (Ayarlar veya Modal)
  static Future<void> logAddSocialLink({
    required String platform,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'yeni_link_ekle',
        parameters: {
          'platform_adi': platform,
          'kategori': category,
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: Add Social Link -> $platform ($category)');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Add Link): $e');
    }
  }

  /// Sosyal link silindiğinde
  static Future<void> logRemoveSocialLink({
    required String platform,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'link_sil',
        parameters: {
          'platform_adi': platform,
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: Remove Social Link -> $platform');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Remove Link): $e');
    }
  }

  /// QR Kod tıklandığında/görüntülendiğinde (Dashboard üzerinden)
  static Future<void> logViewQrPopup({
    required String platform,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'qr_popup_ac',
        parameters: {
          'platform_adi': platform,
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: View QR Popup -> $platform');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (View QR): $e');
    }
  }

  /// Kamera ile gerçek zamanlı QR kodu okutulduğunda
  static Future<void> logScanQrCode({
    required String type, // Örn: 'url', 'text' vs.
  }) async {
    try {
      await _analytics.logEvent(
        name: 'qr_kod_okut',
        parameters: {
          'okutma_tipi': type,
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: Scan QR Code -> $type');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Scan QR): $e');
    }
  }

  /// Galeriden QR okutulduğunda
  static Future<void> logScanQrFromGallery() async {
    try {
      await _analytics.logEvent(
        name: 'galeriden_qr_okut',
      );
      if (kDebugMode) {
        debugPrint('Analytics: Scan QR From Gallery');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Gallery Scan): $e');
    }
  }

  /// Kendi QR kodunu (Create QR) başarılı bir şekilde kaydettiğinde
  static Future<void> logCreateQrCode({
    required String dataType, // Örn: 'url', 'email', 'wifi'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'qr_kod_olustur',
        parameters: {
          'veri_tipi': dataType,
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: Create QR -> $dataType');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Create QR): $e');
    }
  }

  /// Uygulamayı paylaş butonuna (Settings) basıldığında
  static Future<void> logShareApp() async {
    try {
      await _analytics.logEvent(
        name: 'uygulama_paylas',
        parameters: {
          'paylasim_turu': 'uygulama',
          'yontem': 'share_plus',
        },
      );
      if (kDebugMode) {
        debugPrint('Analytics: App Shared');
      }
    } catch (e) {
      debugPrint('Analytics Hatası (Share App): $e');
    }
  }
}
