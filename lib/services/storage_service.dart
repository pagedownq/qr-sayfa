import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/social_link.dart';
import '../models/scan_history_item.dart';
import '../utils/app_state.dart';
import 'cloud_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static const String _linksKey = 'user_links_json';
  static const String _historyKey = 'scanHistory';
  static const String _autoOpenKey = 'auto_open_url';

  static Future<void> init() async {
    // SharedPreferences doesn't need explicit init like Hive,
    // but we can use this for any future high-level setup.
  }

  static void loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Önbellekteki linkleri yükle (Hızlı açılış ve offline için)
    final String? savedLinksJson = prefs.getString(_linksKey);
    if (savedLinksJson != null) {
      final List<dynamic> decoded = jsonDecode(savedLinksJson);
      userLinksNotifier.value = decoded.map((item) {
        return SocialLink.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    // 2. Tarama geçmişini yükle
    final String? historyData = prefs.getString(_historyKey);
    if (historyData != null) {
      final List<dynamic> decoded = jsonDecode(historyData);
      scanHistoryNotifier.value = decoded
          .map((item) => ScanHistoryItem.fromJson(item))
          .toList();
    }

    // 3. Otomatik açma ayarını yükle
    autoOpenUrlNotifier.value = prefs.getBool(_autoOpenKey) ?? false;

    // 4. Değişiklikleri dinle ve Kaydet
    userLinksNotifier.addListener(() {
      final json = jsonEncode(
        userLinksNotifier.value.map((e) => e.toJson()).toList(),
      );
      prefs.setString(_linksKey, json);
    });

    autoOpenUrlNotifier.addListener(() {
      prefs.setBool(_autoOpenKey, autoOpenUrlNotifier.value);
    });

    scanHistoryNotifier.addListener(() {
      final json = jsonEncode(
        scanHistoryNotifier.value.map((e) => e.toJson()).toList(),
      );
      prefs.setString(_historyKey, json);
    });

    // 5. Bulut Senkronizasyonunu Başlat
    CloudService.initSync();

    // 6. Giriş yapılmışsa güncel verileri (linkler ve geçmiş) buluttan çek
    if (FirebaseAuth.instance.currentUser != null) {
      CloudService.fetchDataFromCloud();
    }
  }
}
