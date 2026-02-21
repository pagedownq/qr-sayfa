import 'package:flutter/foundation.dart';
import '../models/social_link.dart';
import '../models/scan_history_item.dart';

// Global olarak kullanıcı linklerini tuttuğumuz değişken
final ValueNotifier<List<SocialLink>> userLinksNotifier = ValueNotifier([]);

// Global scan history
final ValueNotifier<List<ScanHistoryItem>> scanHistoryNotifier = ValueNotifier(
  [],
);

// QR okutunca otomatik gitme ayarı
final ValueNotifier<bool> autoOpenUrlNotifier = ValueNotifier(false);

// Uygulama versiyonu
final ValueNotifier<String> appVersionNotifier = ValueNotifier('1.0.0');
