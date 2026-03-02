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
import '../services/storage_service.dart';
import '../services/cloud_service.dart';
import '../models/scan_history_item.dart';
import '../firebase_options.dart';
import 'dart:io' show Platform, File;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../widgets/native_ad_widget.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/add_link_modal.dart';
import '../services/analytics_service.dart';
import 'scan_history_screen.dart';
import 'reorder_links_screen.dart';
import 'about_screen.dart';
import 'policies_screen.dart';
import 'faq_screen.dart';
import 'qr_generator_screen.dart';
import '../onboarding_screen.dart';
import '../services/review_service.dart';
import '../services/haptic_service.dart';
import 'premium_screen.dart';
import '../utils/link_manager.dart';

import 'platform_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isPremium = isPremiumNotifier.value;
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
                ValueListenableBuilder<bool>(
                  valueListenable: isPremiumNotifier,
                  builder: (context, isPremium, child) {
                    if (isPremium) return const SizedBox.shrink();
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: BannerAdWidget(size: AdSize.banner),
                    );
                  }
                ),
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
                        ValueListenableBuilder<bool>(
                          valueListenable: isHapticEnabledNotifier,
                          builder: (context, isHaptic, _) {
                            return CupertinoListTile(
                              leading: const _IOSSettingsIcon(
                                icon: CupertinoIcons.waveform_path,
                                backgroundColor: CupertinoColors.systemPink,
                              ),
                              title: const Text(
                                'Titreşim Geri Bildirimi',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: const Text(
                                'Dokunma tepkilerini yönetin',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: CupertinoSwitch(
                                value: isHaptic,
                                activeTrackColor: const Color(0xFF00D2FF),
                                onChanged: (val) {
                                  isHapticEnabledNotifier.value = val;
                                  if (val) HapticService.mediumImpact();
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
                        ValueListenableBuilder<bool>(
                          valueListenable: isPremiumNotifier,
                          builder: (context, isPremium, child) {
                            if (isPremium) return const SizedBox.shrink(); // Premium ise gösterme
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 56),
                                  child: Container(height: 1, color: const Color(0x0DFFFFFF)),
                                ),
                                CupertinoListTile(
                                  leading: const _IOSSettingsIcon(
                                    icon: CupertinoIcons.star_circle_fill,
                                    backgroundColor: CupertinoColors.systemYellow,
                                  ),
                                  title: Text(
                                    "Premium'a Geç",
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Tüm ayrıcalıklardan faydalan',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: const CupertinoListTileChevron(),
                                  onTap: () => _pushInstant(const PremiumScreen()),
                                ),
                              ],
                            );
                          }
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
                            AnalyticsService.logShareApp();
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
                            icon: CupertinoIcons.question_circle_fill,
                            backgroundColor: CupertinoColors.systemIndigo,
                          ),
                          title: const Text(
                            'Sıkça Sorulan Sorular',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () => _pushInstant(const FAQScreen()),
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
                        
                        HapticService.heavyImpact();
                        
                        await FirebaseAuth.instance.signOut();
                        final String? clientId = !kIsWeb && Platform.isIOS
                            ? DefaultFirebaseOptions.ios.iosClientId
                            : null;
                        await GoogleSignIn(clientId: clientId).signOut();
                        
                        // Clear global state
                        userLinksNotifier.value = [];
                        scanHistoryNotifier.value = [];
                        isPremiumNotifier.value = false;
                        
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

                ValueListenableBuilder<bool>(
                  valueListenable: isPremiumNotifier,
                  builder: (context, isPremium, child) {
                    if (isPremium) {
                      return RepaintBoundary(
                        child: _buildGlassSection([
                          CupertinoListTile(
                            leading: const _IOSSettingsIcon(
                              icon: CupertinoIcons.star_fill,
                              backgroundColor: Color(0xFFFFD700), // Altın Rengi
                            ),
                            title: const Text(
                              'Premium Aktif',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: const Text(
                              'Tüm sınırsız özellikleri kullanıyorsunuz',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ], marginTop: 32),
                      );
                    }
                    return RepaintBoundary(
                      child: _buildGlassSection([
                        const NativeAdWidget(),
                      ], marginTop: 32),
                    );
                  }
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

  Future<void> _showPlatformSelectionDialog() async {
    final selectedPlatform = await Navigator.of(context).push<Map<String, dynamic>>(
      CupertinoPageRoute(
        builder: (context) => const PlatformSelectionScreen(),
      ),
    );

    if (selectedPlatform != null && mounted) {
      showAddLinkModal(context, selectedPlatform);
    }
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
