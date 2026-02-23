import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart' show Colors, NetworkImage;

import '../models/social_link.dart';
import '../utils/app_state.dart';
import '../ad_helper.dart';
import '../services/analytics_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  String _selectedCategory = 'personal';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    if (kIsWeb) return;
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load an interstitial ad: ${error.message}');
        },
      ),
    );
  }

  void _showInterstitialAndQrDialog(BuildContext context, SocialLink link) {
    final shouldShowAd = (DateTime.now().millisecond % 8 == 0);
    if (shouldShowAd && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    }

    AnalyticsService.logViewQrPopup(platform: link.platform);
    _showQrCodeDialog(context, link);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Sosyal Linklerim',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: Color(0xFF1E293B),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: AdWidget(ad: _bannerAd!),
              ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
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
                                                image: NetworkImage(
                                                  user.photoURL!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x6600D2FF),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: user.photoURL == null
                                          ? const Icon(
                                              CupertinoIcons.person_fill,
                                              size: 50,
                                              color: CupertinoColors.systemGrey,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Merhaba ${user.displayName ?? 'Kullanıcı'}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1E293B),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x6600D2FF),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 50,
                                  color: CupertinoColors.systemGrey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _selectedCategory,
                            backgroundColor: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.5),
                            thumbColor: const Color(0xFF00D2FF),
                            children: {
                              'personal': Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final link = links[index];
                            return _buildSocialGridItem(context, link);
                          }, childCount: links.length),
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
  }

  Widget _buildSocialGridItem(BuildContext context, SocialLink link) {
    return GestureDetector(
      onTap: () {
        _showInterstitialAndQrDialog(context, link);
      },
      onLongPress: () {
        _showEditLinkDialog(context, link);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Düz renk performansı artırır
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: link.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(link.icon, size: 50, color: link.color),
            const SizedBox(height: 16),
            Text(
              link.platform,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLinkDialog(BuildContext context, SocialLink link) {
    final TextEditingController urlController = TextEditingController(
      text: link.url,
    );

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Linki Düzenle'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CupertinoTextField(
              controller: urlController,
              placeholder: 'https://...',
              autofocus: true,
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
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                final newList = List<SocialLink>.from(userLinksNotifier.value);
                newList.remove(link);
                userLinksNotifier.value = newList;
                AnalyticsService.logRemoveSocialLink(platform: link.platform);
              },
              child: Text('Sil'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                if (urlController.text.trim().isNotEmpty) {
                  final newLink = SocialLink(
                    platform: link.platform,
                    icon: link.icon,
                    color: link.color,
                    url: urlController.text.trim(),
                  );
                  final newList = List<SocialLink>.from(
                    userLinksNotifier.value,
                  );
                  final index = newList.indexOf(link);
                  if (index != -1) {
                    newList[index] = newLink;
                  }
                  userLinksNotifier.value = newList;
                  Navigator.pop(context);
                }
              },
              child: Text('Kaydet'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _showQrCodeDialog(BuildContext context, SocialLink link) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.1),
      builder: (context) {
        return Stack(
          children: [
            // Performans için bulanıklık yerine koyu yarı şeffaf katman kullanıyoruz
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: [
                        link.color.withValues(alpha: 0.7),
                        link.color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: link.color.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Platform Başlığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: link.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(link.icon, color: link.color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          link.platform,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.white,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // QR Kod Bölümü
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: QrImageView(
                          data: link.url,
                          version: QrVersions.auto,
                          backgroundColor: CupertinoColors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0F172A),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bağlantıya gitmek için QR kodu taratın',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Kapat Butonu
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(18),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Tamam',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
