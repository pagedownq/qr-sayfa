import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart' show Colors;

import '../models/social_link.dart';
import '../utils/app_state.dart';
import '../ad_helper.dart';
import 'scan_history_screen.dart';
import 'reorder_links_screen.dart';
import 'about_screen.dart';
import 'policies_screen.dart';
import 'qr_generator_screen.dart';
import '../onboarding_screen.dart';
import '../services/review_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<Map<String, dynamic>> availablePlatforms = [
    {
      'name': 'Instagram',
      'icon': FontAwesomeIcons.instagram,
      'color': Color(0xFFE1306C),
    },
    {
      'name': 'X (Twitter)',
      'icon': FontAwesomeIcons.xTwitter,
      'color': CupertinoColors.white,
    },
    {
      'name': 'Facebook',
      'icon': FontAwesomeIcons.facebookF,
      'color': Color(0xFF1877F2),
    },
    {
      'name': 'Snapchat',
      'icon': FontAwesomeIcons.snapchat,
      'color': Color(0xFFFFFC00),
    },
    {
      'name': 'TikTok',
      'icon': FontAwesomeIcons.tiktok,
      'color': CupertinoColors.white,
    },
    {
      'name': 'LinkedIn',
      'icon': FontAwesomeIcons.linkedinIn,
      'color': Color(0xFF0A66C2),
    },
    {
      'name': 'YouTube',
      'icon': FontAwesomeIcons.youtube,
      'color': Color(0xFFFF0000),
    },
    {
      'name': 'WhatsApp',
      'icon': FontAwesomeIcons.whatsapp,
      'color': Color(0xFF25D366),
    },
    {
      'name': 'Github',
      'icon': FontAwesomeIcons.github,
      'color': CupertinoColors.systemGrey3,
    },
    {
      'name': 'WiFi',
      'icon': CupertinoIcons.wifi,
      'color': CupertinoColors.activeBlue,
    },
    {
      'name': 'Diğer',
      'icon': CupertinoIcons.link,
      'color': CupertinoColors.link,
    },
  ];

  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    if (kIsWeb) return;
    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdvancedAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF1E293B),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF00D2FF),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.brown,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Ayarlar',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0x801E293B),
        border: null,
      ),
      child: Stack(
        children: [
          // Background Gradient Decor
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A00D2FF),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Text(
                          'SOSYAL MEDYA',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _buildGlassSection([
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.plus,
                            backgroundColor: Color(0xFF00D2FF),
                          ),
                          title: const Text(
                            'Yeni Link Ekle',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Uygulama veya sitenizi profilinize ekleyin',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: _showPlatformSelectionDialog,
                        ),
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.list_bullet,
                            backgroundColor: CupertinoColors.systemYellow,
                          ),
                          title: const Text(
                            'Linkleri Sırala',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Sıralamayı tercihinize göre değiştirin',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => _pushInstant(const ReorderLinksScreen()),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: autoOpenUrlNotifier,
                          builder: (context, autoOpen, _) {
                            return CupertinoListTile(
                              leading: const _IOSSettingsIcon(
                                icon: CupertinoIcons.arrow_up_right_square_fill,
                                backgroundColor: CupertinoColors.activeGreen,
                              ),
                              title: const Text(
                                'Otomatik Bağlantı',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: const Text(
                                'URL\'leri direkt tarayıcıda açın',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: CupertinoSwitch(
                                value: autoOpen,
                                activeTrackColor: const Color(0xFF00D2FF),
                                onChanged: (val) {
                                  autoOpenUrlNotifier.value = val;
                                },
                              ),
                            );
                          },
                        ),
                      ]),
                    ],
                  ),
                ),

                RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
                        child: Text(
                          'ARAÇLAR',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _buildGlassSection([
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.qrcode_viewfinder,
                            backgroundColor: Color(0xFF00D2FF),
                          ),
                          title: Text(
                            'Hızlı QR Oluştur',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Metin veya linkten anında QR oluşturun',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => _pushInstant(const QRGeneratorScreen()),
                        ),
                      ]),
                    ],
                  ),
                ),

                RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                        child: Text(
                          'GEÇMİŞ & ANALİZ',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _buildGlassSection([
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.clock_fill,
                            backgroundColor: CupertinoColors.systemIndigo,
                          ),
                          title: Text(
                            'Tarama Geçmişi',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Tüm geçmişinizi görüntüleyin',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => _pushInstant(const ScanHistoryScreen()),
                        ),
                      ]),
                    ],
                  ),
                ),

                RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                        child: Text(
                          'UYGULAMA',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _buildGlassSection([
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.share,
                            backgroundColor: Color(0xFF00D2FF),
                          ),
                          title: Text(
                            'Uygulamayı Paylaş',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () {
                            // ignore: deprecated_member_use
                            Share.share(
                              'Qurio ile tanışın! Tüm dijital varlığınız tek bir QR kodda.',
                            );
                          },
                        ),
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.star_fill,
                            backgroundColor: CupertinoColors.systemOrange,
                          ),
                          title: Text(
                            'Uygulamayı Puanla',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => ReviewService.requestReview(),
                        ),
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.info_circle_fill,
                            backgroundColor: Color(0xFF64748B),
                          ),
                          title: Text(
                            'Uygulama Hakkında',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => _pushInstant(const AboutScreen()),
                        ),
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.doc_text_fill,
                            backgroundColor: CupertinoColors.systemPurple,
                          ),
                          title: Text(
                            'Politikalar ve Gizlilik',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => _pushInstant(const PoliciesScreen()),
                        ),
                      ]),
                    ],
                  ),
                ),

                RepaintBoundary(
                  child: _buildGlassSection([
                    CupertinoListTile(
                      leading: const _IOSSettingsIcon(
                        icon: CupertinoIcons.square_arrow_right,
                        backgroundColor: CupertinoColors.destructiveRed,
                      ),
                      title: Text(
                        'Oturumu Kapat',
                        style: const TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () async {
                        final messenger = Navigator.of(
                          context,
                          rootNavigator: true,
                        );
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();
                        userLinksNotifier.value = [];
                        if (!mounted) return;
                        messenger.pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const OnboardingScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),
                  ], marginTop: 32),
                ),

                if (_isNativeAdLoaded && _nativeAd != null)
                  RepaintBoundary(
                    child: _buildGlassSection([
                      SizedBox(height: 320, child: AdWidget(ad: _nativeAd!)),
                    ], marginTop: 32),
                  ),

                const SizedBox(height: 60),
                Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: appVersionNotifier,
                    builder: (context, version, _) {
                      return Text(
                        'Qurio v$version - MGVerse',
                        style: const TextStyle(
                          color: Color(0x8094A3B8),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection(List<Widget> children, {double marginTop = 0}) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, marginTop, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xCC1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x14FFFFFF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: children.asMap().entries.map((entry) {
            final index = entry.key;
            final widget = entry.value;
            return Column(
              children: [
                widget,
                if (index < children.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56),
                    child: Container(height: 1, color: const Color(0x0DFFFFFF)),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPlatformSelectionDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Platform Seçin', style: TextStyle(fontSize: 18)),
          message: const Text('Eklemek istediğiniz sosyal medyanızı seçin.'),
          actions: availablePlatforms.map((platform) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _showAddLinkDialog(platform);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(platform['icon'], color: platform['color'], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    platform['name'],
                    style: const TextStyle(color: CupertinoColors.activeBlue),
                  ),
                ],
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
        );
      },
    );
  }

  void _showAddLinkDialog(Map<String, dynamic> platform) {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController nameController = TextEditingController(
      text: platform['name'],
    );
    final TextEditingController wifiSsidController = TextEditingController();
    final TextEditingController wifiPasswordController =
        TextEditingController();

    final bool isOther = platform['name'] == 'Diğer';
    final bool isWifi = platform['name'] == 'WiFi';

    String currentCategory = 'personal';

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoAlertDialog(
              title: Column(
                children: [
                  Icon(platform['icon'], color: platform['color'], size: 40),
                  const SizedBox(height: 8),
                  Text(
                    isWifi
                        ? 'WiFi Bağlantısı Ekle'
                        : (isOther
                              ? 'Bağlantı Detayları'
                              : '${platform['name']} Linki Ekle'),
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: currentCategory,
                      backgroundColor: const Color(0xFF0F172A),
                      thumbColor: const Color(0xFF00D2FF),
                      children: {
                        'personal': Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Kişisel',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        'business': Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'İş',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            currentCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isWifi) ...[
                      CupertinoTextField(
                        controller: wifiSsidController,
                        placeholder: 'Ağ Adı (SSID)',
                        style: const TextStyle(color: CupertinoColors.white),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: wifiPasswordController,
                        placeholder: 'Şifre',
                        obscureText: true,
                        style: const TextStyle(color: CupertinoColors.white),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ] else ...[
                      if (isOther) ...[
                        CupertinoTextField(
                          controller: nameController,
                          placeholder: 'Başlık (Örn: Portfolyom)',
                          style: const TextStyle(color: CupertinoColors.white),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        const SizedBox(height: 12),
                      ],
                      CupertinoTextField(
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
                    ],
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text('İptal'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    // ... (rest of logic unchanged, just strings in popups)
                    // Wait, i should replace strings in popups too
                    String finalUrl = '';
                    String finalName = '';

                    if (isWifi) {
                      final ssid = wifiSsidController.text.trim();
                      final pass = wifiPasswordController.text.trim();
                      if (ssid.isNotEmpty) {
                        finalUrl = 'WIFI:S:$ssid;T:WPA;P:$pass;;';
                        finalName = ssid;
                      }
                    } else {
                      finalUrl = urlController.text.trim();
                      finalName = isOther
                          ? nameController.text.trim()
                          : platform['name'];
                    }

                    if (finalUrl.isNotEmpty && finalName.isNotEmpty) {
                      final newLink = SocialLink(
                        platform: finalName,
                        icon: platform['icon'],
                        color: platform['color'],
                        url: finalUrl,
                        category: currentCategory,
                      );

                      userLinksNotifier.value = List.from(
                        userLinksNotifier.value,
                      )..add(newLink);

                      if (!mounted) return;
                      Navigator.pop(context);

                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Başarılı'),
                          content: Text('$finalName başarıyla eklendi!'),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('Tamam'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pushInstant(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

class _IOSSettingsIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;

  const _IOSSettingsIcon({required this.icon, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, color: CupertinoColors.white, size: 18),
    );
  }
}
