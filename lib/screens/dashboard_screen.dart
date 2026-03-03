import 'package:flutter/cupertino.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../utils/pretty_qr_helper.dart';
import 'package:flutter/material.dart' show Colors, NetworkImage, FileImage;

import '../models/social_link.dart';
import '../utils/app_state.dart';
import '../services/analytics_service.dart';
import '../services/ad_manager.dart';
import '../widgets/banner_ad_widget.dart';
import '../utils/link_manager.dart';
import '../services/haptic_service.dart';
import '../widgets/dashboard/qr_code_dialog.dart';
import '../widgets/dashboard/social_grid_item.dart';
import '../widgets/dashboard/dashboard_cover_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  String _selectedCategory = 'personal';

  @override
  bool get wantKeepAlive => true;

  void _showInterstitialAndQrDialog(BuildContext context, SocialLink link, bool isPremium) {
    if (!isPremium) {
      AdManager().showInterstitialAd();
    }

    AnalyticsService.logViewQrPopup(platform: link.platform);
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.1),
      builder: (context) => QrCodeDialog(link: link, isPremium: isPremium),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<bool>(
      valueListenable: isPremiumNotifier,
      builder: (context, isPremium, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text(
              'Sosyal Linklerim',
              style: TextStyle(color: CupertinoColors.white),
            ),
            backgroundColor: const Color(0xFF1E293B),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (!isPremium) const BannerAdWidget(size: AdSize.banner),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            ValueListenableBuilder<List<SocialLink>>(
                              valueListenable: userLinksNotifier,
                              builder: (context, links, _) => DashboardCoverCard(
                                links: links,
                                isPremium: isPremium,
                                onQrTap: (link) => _showInterstitialAndQrDialog(context, link, isPremium),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: StreamBuilder<User?>(
                                stream: FirebaseAuth.instance.authStateChanges(),
                                builder: (context, snapshot) {
                                  final user = snapshot.data;

                                  if (user != null) {
                                    return Column(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF1E293B),
                                            image: user.photoURL != null
                                                ? DecorationImage(
                                                    image: NetworkImage(user.photoURL!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Merhaba ${user.displayName ?? 'Kullanıcı'}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: CupertinoColors.white,
                                              ),
                                            ),
                                            if (isPremium) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFFFFD700), Color(0xFFFDB931)],
                                                  ),
                                                ),
                                                child: const Text(
                                                  'PRO',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    );
                                  }

                                  return const SizedBox.shrink(); // Hide if not logged in since Cover Card covers it
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: CupertinoSlidingSegmentedControl<String>(
                                groupValue: _selectedCategory,
                                backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
                                thumbColor: const Color(0xFF00D2FF),
                                children: {
                                  'personal': Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Kişisel',
                                      style: TextStyle(
                                        color: _selectedCategory == 'personal'
                                            ? CupertinoColors.black
                                            : CupertinoColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  'business': Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'İş',
                                      style: TextStyle(
                                        color: _selectedCategory == 'business'
                                            ? CupertinoColors.black
                                            : CupertinoColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                },
                                onValueChanged: (value) {
                                  if (value != null) {
                                    HapticService.selectionClick();
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<List<SocialLink>>(
                        valueListenable: userLinksNotifier,
                        builder: (context, allLinks, child) {
                          final links = allLinks
                              .where((link) => link.category == _selectedCategory)
                              .toList();

                          if (links.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: Text(
                                    'Henüz hiç link eklemediniz.\nLink eklemek için Ayarlar sayfasına gidin.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final link = links[index];
                                  return SocialGridItem(
                                    link: link,
                                    isPremium: isPremium,
                                    onTap: () => _showInterstitialAndQrDialog(context, link, isPremium),
                                    onLongPress: () => _showEditLinkDialog(context, link),
                                  );
                                },
                                childCount: links.length,
                              ),
                            ),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showEditLinkDialog(BuildContext context, SocialLink link) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('${link.platform}', style: const TextStyle(fontWeight: FontWeight.bold)),
        message: Text(link.url),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showActualEditDialog(context, link);
            },
            child: const Text('Düzenle'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              LinkManager.removeLink(link);
              HapticService.heavyImpact();
            },
            child: const Text('Sil'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
      ),
    );
  }

  void _showActualEditDialog(BuildContext context, SocialLink link) {
    final TextEditingController urlController = TextEditingController(text: link.url);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Linki Düzenle'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: urlController,
            placeholder: 'https://...',
            style: const TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                final newLink = link.copyWith(url: urlController.text.trim());
                LinkManager.updateLink(link, newLink, link.platformId);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

}
