import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/social_link.dart';
import '../models/scan_history_item.dart';
import '../utils/app_state.dart';

class CloudService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının Firestore'daki döküman referansı
  static DocumentReference? get _userDoc {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  // Linkleri buluta kaydet
  static Future<void> saveLinksToCloud() async {
    final doc = _userDoc;
    if (doc == null) return;

    try {
      final List<Map<String, dynamic>> linksJson = userLinksNotifier.value
          .map((e) => e.toJson())
          .toList();

      await doc.set({
        'links': linksJson,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Linkler buluta başarıyla kaydedildi.');
    } catch (e) {
      debugPrint('Buluta kaydetme hatası: $e');
    }
  }

  // Tarama geçmişini buluta kaydet
  static Future<void> saveHistoryToCloud() async {
    final doc = _userDoc;
    if (doc == null) return;

    try {
      final List<Map<String, dynamic>> historyJson = scanHistoryNotifier.value
          .map((e) => e.toJson())
          .toList();

      await doc.set({
        'history': historyJson,
        'lastUpdatedHistory': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Geçmiş buluta başarıyla kaydedildi.');
    } catch (e) {
      debugPrint('Buluta geçmiş kaydetme hatası: $e');
    }
  }

  // Verileri buluttan çek
  static Future<void> fetchDataFromCloud() async {
    final doc = _userDoc;
    if (doc == null) return;

    try {
      final snapshot = await doc.get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;

        // 1. Linkleri çek
        final List<dynamic>? cloudLinks = data['links'];
        if (cloudLinks != null) {
          userLinksNotifier.value = cloudLinks.map((item) {
            return SocialLink.fromJson(Map<String, dynamic>.from(item));
          }).toList();
        }

        // 2. Geçmişi çek
        final List<dynamic>? cloudHistory = data['history'];
        if (cloudHistory != null) {
          scanHistoryNotifier.value = cloudHistory
              .map((item) {
                return ScanHistoryItem.fromJson(
                  Map<String, dynamic>.from(item),
                );
              })
              .toList()
              .cast<ScanHistoryItem>();
        }

        debugPrint('Veriler buluttan başarıyla çekildi.');
      }
    } catch (e) {
      debugPrint('Buluttan veri çekme hatası: $e');
    }
  }

  // Otomatik senkronizasyon dinleyicisi
  static void initSync() {
    userLinksNotifier.addListener(() {
      saveLinksToCloud();
    });

    scanHistoryNotifier.addListener(() {
      saveHistoryToCloud();
    });
  }
}
