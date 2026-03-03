import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/social_link.dart';
import '../models/scan_history_item.dart';
import '../utils/app_state.dart';
import 'cloud_service.dart';
import '../utils/logo_generator.dart';
import '../constants/platforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show FileImage;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class StorageService {
  static const String _linksKey = 'user_links_json';
  static const String _historyKey = 'scanHistory';
  static const String _autoOpenKey = 'auto_open_url';
  static const String _isPremiumKey = 'is_premium_status';

  static bool _listenersInitialized = false;

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
      final List<SocialLink> links = decoded.map((item) {
        return SocialLink.fromJson(Map<String, dynamic>.from(item));
      }).toList();
      
      userLinksNotifier.value = links;
      
      // Background logo regeneration for local links
      _regenerateMissingLogos(links);
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

    // 3.5. Premium durumunu yükle
    isPremiumNotifier.value = prefs.getBool(_isPremiumKey) ?? false;

    // 4. Değişiklikleri dinle ve Kaydet
    if (!_listenersInitialized) {
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

      isPremiumNotifier.addListener(() {
        prefs.setBool(_isPremiumKey, isPremiumNotifier.value);
      });

      // 5. Bulut Senkronizasyonunu Başlat
      CloudService.initSync();
      _listenersInitialized = true;
    }

    // 6. Giriş yapılmışsa güncel verileri (linkler ve geçmiş) buluttan çek
    if (FirebaseAuth.instance.currentUser != null) {
      CloudService.fetchDataFromCloud().then((_) {
        // Also regenerate logos for links fetched from cloud
        _regenerateMissingLogos(userLinksNotifier.value);
      });
    }
  }

  /// Regenerates temporary logo files for links that have a platformId
  /// but whose logo file is missing (usually after app restart/temp clear)
  static void _regenerateMissingLogos(List<SocialLink> links) async {
    bool anyChanged = false;
    final List<SocialLink> updatedLinks = List.from(links);

    for (int i = 0; i < updatedLinks.length; i++) {
      final link = updatedLinks[i];
      
      bool needsLogo = link.platformId != 'other' && 
                       link.platformId != 'wifi' && 
                       link.platformId != 'phone';
      
      if (needsLogo) {
        bool logoMissing = link.qrLogoPath == null || !File(link.qrLogoPath!).existsSync();
        
        if (logoMissing) {
          try {
            debugPrint("StorageService: Regenerating missing logo for ${link.platform}");
            final platform = AppPlatforms.availablePlatforms.firstWhere(
              (p) => p.id == link.platformId,
              orElse: () => AppPlatforms.availablePlatforms.first,
            );
            
            final newPath = await LogoGenerator.saveIconToImage(platform.icon, platform.color);
            
            // Critical: Evict the image from cache to ensure UI reloads it
            if (link.qrLogoPath != null) {
              FileImage(File(link.qrLogoPath!)).evict();
            }
            FileImage(File(newPath)).evict();
            
            updatedLinks[i] = link.copyWith(qrLogoPath: newPath);
            anyChanged = true;
          } catch (e) {
            debugPrint("StorageService: Failed to regenerate logo for ${link.platform}: $e");
          }
        }
      }
    }

    if (anyChanged) {
      debugPrint("StorageService: Updated ${updatedLinks.length} links with regenerated logos");
      userLinksNotifier.value = updatedLinks;
    }
  }
  
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
