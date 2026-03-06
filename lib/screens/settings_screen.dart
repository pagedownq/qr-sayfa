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

import '../utils/link_manager.dart';
import '../l10n/app_localizations.dart';

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
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          tr('settings'),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B), // Opaque for better performance
        border: null,
      ),
      child: Stack(
        children: [
          // Background Gradient Decor
          // Background Gradient Decor - Wrapped in RepaintBoundary for performance
          Positioned(
            top: -100,
            right: -100,
            child: RepaintBoundary(
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1A00D2FF),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              addRepaintBoundaries: false, // Manual management for better control
              cacheExtent: 800,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isPremiumNotifier,
                  builder: (context, isPremium, child) {
                    if (isPremium) return const SizedBox.shrink();
                    return const RepaintBoundary(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: BannerAdWidget(size: AdSize.banner),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),
                RepaintBoundary(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Text(
                          tr('social_media'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _GlassSection(children: [
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.plus,
                            backgroundColor: Color(0xFF00D2FF),
                          ),
                          title: Text(
                            tr('add_new_link'),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            tr('add_link_subtitle'),
                            style: const TextStyle(
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
                          title: Text(
                            tr('reorder_links'),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            tr('reorder_subtitle'),
                            style: const TextStyle(
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
                              title: Text(
                                tr('auto_link'),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                tr('auto_link_subtitle'),
                                style: const TextStyle(
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
                              title: Text(
                                tr('haptic_feedback'),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                tr('haptic_subtitle'),
                                style: const TextStyle(
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
                        ValueListenableBuilder<Locale>(
                          valueListenable: localeNotifier,
                          builder: (context, locale, _) {
                            final languageNames = {
                              'en': 'English',
                              'tr': 'Türkçe',
                              'de': 'Deutsch',
                              'ru': 'Русский',
                            };
                            return CupertinoListTile(
                              leading: const _IOSSettingsIcon(
                                icon: CupertinoIcons.globe,
                                backgroundColor: CupertinoColors.systemTeal,
                              ),
                              title: Text(
                                tr('language'),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    languageNames[locale.languageCode] ?? 'English',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const CupertinoListTileChevron(),
                                ],
                              ),
                              onTap: _showLanguagePicker,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                        child: Text(
                          tr('tools'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _GlassSection(children: [
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.qrcode_viewfinder,
                            backgroundColor: Color(0xFF00D2FF),
                          ),
                          title: Text(
                            tr('quick_qr'),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            tr('qr_create_subtitle'),
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
                                    tr('go_premium_title'),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    tr('premium_subtitle'),
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
                          tr('history_analysis'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _GlassSection(children: [
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.clock_fill,
                            backgroundColor: CupertinoColors.systemIndigo,
                          ),
                          title: Text(
                            tr('scan_history'),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            tr('scan_history_subtitle'),
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
                          tr('app_section'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _GlassSection(children: [
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.share,
                            backgroundColor: Color(0xFF00D2FF),
                          ),
                          title: Text(
                            tr('share_app'),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () {
                            // ignore: deprecated_member_use
                            Share.share(tr('share_text'));
                            AnalyticsService.logShareApp();
                          },
                        ),
                        CupertinoListTile(
                          leading: const _IOSSettingsIcon(
                            icon: CupertinoIcons.star_fill,
                            backgroundColor: CupertinoColors.systemOrange,
                          ),
                          title: Text(
                            tr('rate_app'),
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
                            tr('about_app'),
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
                          title: Text(
                            tr('faq'),
                            style: const TextStyle(
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
                            tr('policies'),
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
                  child: _GlassSection(
                    marginTop: 32,
                    children: [
                      CupertinoListTile(
                        leading: const _IOSSettingsIcon(
                          icon: CupertinoIcons.square_arrow_right,
                          backgroundColor: CupertinoColors.destructiveRed,
                        ),
                        title: Text(
                          tr('sign_out'),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Container(height: 1, color: const Color(0x0DFFFFFF)),
                    ),
                      CupertinoListTile(
                        leading: const _IOSSettingsIcon(
                          icon: CupertinoIcons.delete,
                          backgroundColor: Color(0xFF64748B),
                        ),
                        title: Text(
                          tr('delete_account'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          tr('delete_account_desc'),
                          style: const TextStyle(
                            color: Color(0x8094A3B8),
                            fontSize: 12,
                          ),
                        ),
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ]),
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: isPremiumNotifier,
                  builder: (context, isPremium, child) {
                    if (isPremium) {
                      return RepaintBoundary(
                        child: _GlassSection(
                          marginTop: 32,
                          children: [
                          CupertinoListTile(
                            leading: const _IOSSettingsIcon(
                              icon: CupertinoIcons.star_fill,
                              backgroundColor: Color(0xFFFFD700), // Altın Rengi
                            ),
                              title: Text(
                                tr('premium_active'),
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                tr('premium_active_desc'),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                          ),
                        ]),
                      );
                    }
                    return RepaintBoundary(
                      child: _GlassSection(
                        marginTop: 32,
                        children: [
                        const NativeAdWidget(),
                      ]),
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

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      HapticService.heavyImpact();
      
      // 1. Delete user from Firebase
      await user.delete();

      // 2. Clear global state & storage
      userLinksNotifier.value = [];
      scanHistoryNotifier.value = [];
      isPremiumNotifier.value = false;
      await StorageService.clearAll();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showErrorDialog(tr('requires_recent_login'));
      } else {
        _showErrorDialog('${tr('error_occurred')} ${e.message}');
      }
    } catch (e) {
      _showErrorDialog('${tr('error_occurred')} $e');
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(tr('delete_account')),
        content: Text(tr('delete_account_confirm')),
        actions: [
          CupertinoDialogAction(
            child: Text(tr('cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: Text(tr('yes_delete')),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(tr('error')),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(tr('ok')),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(tr('select_language')),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setLocale(const Locale('en', ''));
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setLocale(const Locale('tr', ''));
              Navigator.pop(context);
            },
            child: const Text('Türkçe'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setLocale(const Locale('de', ''));
              Navigator.pop(context);
            },
            child: const Text('Deutsch'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setLocale(const Locale('ru', ''));
              Navigator.pop(context);
            },
            child: const Text('Русский'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(tr('cancel')),
        ),
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

class _GlassSection extends StatelessWidget {
  final List<Widget> children;
  final double marginTop;

  const _GlassSection({required this.children, this.marginTop = 0});

  @override
  Widget build(BuildContext context) {
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
}
