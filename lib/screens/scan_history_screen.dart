import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show Colors;

import '../models/scan_history_item.dart';
import '../utils/app_state.dart';
import '../utils/url_launcher_util.dart';
class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0 && now.day == dt.day) {
      return '${'Bugün'} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 0 || diff.inDays == 1 && now.day != dt.day) {
      return '${'Dün'} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Tarama Geçmişi',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        trailing: ValueListenableBuilder(
          valueListenable: scanHistoryNotifier,
          builder: (context, List<ScanHistoryItem> history, child) {
            if (history.isEmpty) return const SizedBox.shrink();
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.trash,
                color: CupertinoColors.destructiveRed,
                size: 22,
              ),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('Geçmişi Temizle'),
                    content: Text(
                      'Geçmişi Temizle'Confirm,
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('İptal'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: Text('Geçmişi Temizle'),
                        onPressed: () async {
                          scanHistoryNotifier.value = [];
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('scanHistory');
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: scanHistoryNotifier,
          builder: (context, List<ScanHistoryItem> history, child) {
            if (history.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.clock,
                        size: 64,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz hiç QR kodu taratmadınız.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return CupertinoListSection.insetGrouped(
              backgroundColor: Colors.transparent,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              children: history.map((item) {
                final content = item.content.trim();
                // Basit bir URL kontrolü geliştiriyoruz
                final bool isUrl = content.startsWith('http://') || 
                                   content.startsWith('https://') ||
                                   RegExp(r'^[a-zA-Z0-9\-\.]+\.[a-z]{2,}(/\S*)?$').hasMatch(content);

                return Dismissible(
                  key: ValueKey(item.timestamp.toIso8601String() + item.content),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    final newList = List<ScanHistoryItem>.from(scanHistoryNotifier.value);
                    newList.remove(item);
                    scanHistoryNotifier.value = newList;
                    // Note: StorageService automatically listens to scanHistoryNotifier changes and saves them.
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.destructiveRed,
                    ),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: CupertinoColors.white,
                      size: 28,
                    ),
                  ),
                  child: CupertinoListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: (isUrl
                                ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGreen)
                        .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isUrl ? CupertinoIcons.link : CupertinoIcons.text_alignleft,
                        color: isUrl
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGreen,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                    subtitle: Text(
                      _formatDateTime(item.timestamp),
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isUrl
                        ? CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            child: const Icon(
                              CupertinoIcons.arrow_up_right_square_fill,
                              color: CupertinoColors.activeBlue,
                              size: 22,
                            ),
                            onPressed: () {
                              String urlToLaunch = content;
                              if (!urlToLaunch.startsWith('http')) {
                                urlToLaunch = 'https://$urlToLaunch';
                              }
                              launchURL(urlToLaunch);
                            },
                          )
                        : null,
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Tarama Detayı'),
                          content: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(item.content),
                          ),
                          actions: [
                            if (isUrl)
                              CupertinoDialogAction(
                                child: Text('Bağlantıyı Aç'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  String urlToLaunch = content;
                                  if (!urlToLaunch.startsWith('http')) {
                                    urlToLaunch = 'https://$urlToLaunch';
                                  }
                                  launchURL(urlToLaunch);
                                },
                              ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text('Kapat'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
