import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  /// Kullanıcıya uygulama içinde puanlama penceresi açar.
  /// Not: Apple ve Google'ın kendi kotaları vardır, her zaman pencere açılmayabilir.
  static Future<void> requestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      debugPrint('Puanlama sistemi uygun mu: $isAvailable');

      if (isAvailable) {
        await _inAppReview.requestReview();
      } else {
        // Eğer uygulama içi puanlama uygun değilse (Simülatör vb.)
        // Doğrudan mağaza sayfasını açmayı deneyebiliriz.
        debugPrint(
          'Uygulama içi puanlama uygun değil, mağaza sayfası denenecek.',
        );
        await openStoreListing();
      }
    } catch (e) {
      debugPrint('Puanlama istenirken kritik hata: $e');
    }
  }

  /// Kullanıcıyı doğrudan mağaza sayfasındaki yorum yapma alanına gönderir.
  static Future<void> openStoreListing() async {
    try {
      // appStoreId kısmına iOS uygulama ID'sini markete çıkışta eklemek gerekecek.
      await _inAppReview.openStoreListing(
        appStoreId:
            'com.mgverse.Qurio', // Geçici bundle ID, markette sayısal ID olacak
      );
    } catch (e) {
      debugPrint('Mağaza sayfası açılırken hata oluştu: $e');
    }
  }
}
