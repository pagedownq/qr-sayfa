import 'package:flutter/cupertino.dart';
import '../models/social_link.dart';
import 'app_state.dart';
import '../services/haptic_service.dart';
import '../services/analytics_service.dart';

/// Business Logic Layer for managing user social links.
/// Handles validation, normalization, and CRUD operations.
class LinkManager {
  static const int FREE_USER_LIMIT = 5;

  /// Validates and standardizes a URL based on platform.
  static String normalizeUrl(String input, String platformId) {
    String url = input.trim();
    if (url.isEmpty) return url;

    // Remove whitespace and standard prefixes if user typed them partially
    final platform = platformId.toLowerCase();

    // Specific formatting for platforms
    if (platform == 'whatsapp' || platform == 'phone') {
      // Keep only digits and + for phone/whatsapp
      url = url.replaceAll(RegExp(r'[^0-9+]'), '');
      if (platform == 'whatsapp' && !url.startsWith('https://wa.me/')) {
        String cleanPhone = url.replaceAll('+', '');
        url = 'https://wa.me/$cleanPhone';
      } else if (platform == 'phone' && !url.startsWith('tel:')) {
        url = 'tel:$url';
      }
    } else if (platform == 'email') {
       if (!url.startsWith('mailto:')) url = 'mailto:$url';
    } else if (platform == 'wifi') {
      // WiFi format is handled specifically in the modal, return as is
      return url;
    } else {
      // General URL normalization
      if (!url.contains('.') && !url.contains(':')) {
        // Assume it might be a username for common platforms if no dots
        switch (platform) {
          case 'instagram': url = 'https://instagram.com/$url'; break;
          case 'x-twitter': url = 'https://x.com/$url'; break;
          case 'tiktok': url = 'https://tiktok.com/@$url'; break;
          case 'github': url = 'https://github.com/$url'; break;
        }
      }
      
      if (!url.startsWith('http://') && !url.startsWith('https://') && 
          !url.startsWith('tel:') && !url.startsWith('mailto:') && !url.startsWith('WIFI:')) {
        url = 'https://$url';
      }
    }

    return url;
  }

  /// Checks if a link can be added based on validation and limits.
  static (bool, String) canAddLink(String rawUrl, String platformName, String platformId) {
    final bool isPremium = isPremiumNotifier.value;
    final List<SocialLink> currentLinks = userLinksNotifier.value;
    final String url = normalizeUrl(rawUrl, platformId);

    // 1. Empty Check
    if (rawUrl.trim().isEmpty) {
      HapticService.error();
      return (false, 'Lütfen bir bağlantı veya kullanıcı adı girin.');
    }

    // 2. Premium Total Limit Check
    if (!isPremium && currentLinks.length >= FREE_USER_LIMIT) {
      HapticService.error();
      return (false, 'Ücretsiz kullanım sınırına ulaştınız ($FREE_USER_LIMIT link).\nSınırsız link için Premium\'a geçin.');
    }

    // 3. Platform Specific Validation
    if (platformId == 'email' && !RegExp(r'^mailto:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(url)) {
      HapticService.error();
      return (false, 'Lütfen geçerli bir e-posta adresi girin.');
    }

    if ((platformId == 'phone' || platformId == 'whatsapp') && !RegExp(r'^[a-z]+:[0-9+]+$').hasMatch(url.split('?').first)) {
       // Simplified check for phone/wa.me
       if (url.length < 10) {
          HapticService.error();
          return (false, 'Lütfen geçerli bir telefon numarası girin.');
       }
    }

    // 4. Duplicate Check
    final bool isDuplicate = currentLinks.any(
      (link) => link.url.toLowerCase().trim() == url.toLowerCase().trim(),
    );
    if (isDuplicate) {
      HapticService.error();
      return (false, 'Bu bağlantı zaten listenizde mevcut.');
    }

    // 5. Removed Per-Platform Limit to allow more flexibility even for free users
    // as long as they stay within the 5 total links limit.

    return (true, '');
  }

  /// Securely adds a new link to the global state.
  static Future<bool> addLink(SocialLink link, String platformId) async {
    try {
      final normalizedLink = link.copyWith(url: normalizeUrl(link.url, platformId));
      
      final (canAdd, _) = canAddLink(link.url, link.platform, platformId);
      if (!canAdd) return false;

      final newList = List<SocialLink>.from(userLinksNotifier.value)..add(normalizedLink);
      userLinksNotifier.value = newList;
      
      AnalyticsService.logAddSocialLink(platform: link.platform, category: link.category);
      HapticService.success();
      return true;
    } catch (e) {
      debugPrint('LinkManager Error (Add): $e');
      return false;
    }
  }

  /// Removes a link from the state.
  static void removeLink(SocialLink link) {
    try {
      final newList = List<SocialLink>.from(userLinksNotifier.value)..remove(link);
      userLinksNotifier.value = newList;
      AnalyticsService.logRemoveSocialLink(platform: link.platform);
      HapticService.mediumImpact();
    } catch (e) {
      debugPrint('LinkManager Error (Remove): $e');
    }
  }

  /// Updates an existing link.
  static void updateLink(SocialLink oldLink, SocialLink newLink, String platformId) {
    try {
      final normalizedNew = newLink.copyWith(url: normalizeUrl(newLink.url, platformId));
      final newList = List<SocialLink>.from(userLinksNotifier.value);
      final index = newList.indexWhere((l) => l.url == oldLink.url && l.platform == oldLink.platform);
      
      if (index != -1) {
        newList[index] = normalizedNew;
        userLinksNotifier.value = newList;
        HapticService.success();
      }
    } catch (e) {
      debugPrint('LinkManager Error (Update): $e');
    }
  }

  /// Sorts links alphabetically by platform name.
  static void sortLinks() {
    final List<SocialLink> list = List.from(userLinksNotifier.value);
    list.sort((a, b) => a.platform.compareTo(b.platform));
    userLinksNotifier.value = list;
    HapticService.lightImpact();
  }

  /// Searches for links within the existing list.
  static List<SocialLink> searchLinks(String query) {
    if (query.isEmpty) return userLinksNotifier.value;
    return userLinksNotifier.value.where((link) => 
      link.platform.toLowerCase().contains(query.toLowerCase()) ||
      link.url.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
