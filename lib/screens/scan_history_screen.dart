import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show Colors;

import '../models/scan_history_item.dart';
import '../utils/app_state.dart';
import '../utils/url_launcher_util.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'premium_screen.dart';
import '../services/haptic_service.dart';
import '../l10n/app_localizations.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0 && now.day == dt.day) {
      return '${tr('today_str')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 0 || diff.inDays == 1 && now.day != dt.day) {
      return '${tr('yesterday_str')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
          tr('scan_history'),
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
                    title: Text(tr('clear_history')),
                    content: Text(
                      tr('clear_history_confirm'),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(tr('cancel')),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: Text(tr('clear_history')),
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
                        tr('no_scans_yet'),
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

            return ValueListenableBuilder<bool>(
              valueListenable: isPremiumNotifier,
              builder: (context, isPremium, child) {
                return CupertinoListSection.insetGrouped(
                  backgroundColor: Colors.transparent,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: List.generate(history.length, (index) {
                    final item = history[index];
                    final content = item.content.trim();
                    final bool isUrl =
                        content.startsWith('http://') ||
                        content.startsWith('https://') ||
                        RegExp(
                          r'^[a-zA-Z0-9\-\.]+\.[a-z]{2,}(/\S*)?$',
                        ).hasMatch(content);
                    
                    final bool isLocked = !isPremium && index >= 3;

                    Widget tile = Dismissible(
                      key: ValueKey(
                        item.timestamp.toIso8601String() + item.content,
                      ),
                      direction: isLocked ? DismissDirection.none : DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        final newList = List<ScanHistoryItem>.from(
                          scanHistoryNotifier.value,
                        );
                        newList.remove(item);
                        scanHistoryNotifier.value = newList;
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
                            color:
                                (isUrl
                                        ? CupertinoColors.activeBlue
                                        : CupertinoColors.systemGreen)
                                    .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isUrl
                                ? CupertinoIcons.link
                                : CupertinoIcons.text_alignleft,
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
                        trailing: isUrl && !isLocked
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
                          if (isLocked) {
                            HapticService.selectionClick();
                            Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (context) => const PremiumScreen()),
                            );
                            return;
                          }
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text(tr('scan_details')),
                              content: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(item.content),
                              ),
                              actions: [
                                if (isUrl)
                                  CupertinoDialogAction(
                                    child: Text(tr('open_link')),
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
                                  child: Text(tr('close')),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );

                    if (isLocked) {
                      return Stack(
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                            child: Opacity(
                              opacity: 0.5,
                              child: IgnorePointer(child: tile),
                            ),
                          ),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                HapticService.selectionClick();
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const PremiumScreen()),
                                );
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(CupertinoIcons.lock_fill, color: CupertinoColors.systemYellow, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          tr('unlock_with_premium'),
                                          style: const TextStyle(
                                            color: CupertinoColors.systemYellow,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    
                    return tile;
                  }),
                );
              }
            );
          },
        ),
      ),
    );
  }
}
