import 'package:flutter/cupertino.dart';
import 'dashboard_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'qr_generator_screen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:in_app_update/in_app_update.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/haptic_service.dart';
import '../widgets/floating_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final PageController _pageController = PageController();
  final QuickActions _quickActions = const QuickActions();

  Future<void> _checkForUpdate() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        try {
          // Güncelleme varsa her zaman Immediate (Zorunlu) güncellemeyi başlatmayı dene
          await InAppUpdate.performImmediateUpdate();
        } catch (e) {
          debugPrint("Zorunlu güncelleme başlatılamadı: $e");
          // Eğer Google Play politikası vs. yüzünden zorunlu ekran açılamazsa, esnek güncellemeyi (arka planda) başlat
          if (updateInfo.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
          }
        }
      }
    } catch (e) {
      debugPrint("Güncelleme Kontrol Hatası: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _quickActions.initialize((String type) {
      if (type == 'scan') {
        _currentIndexNotifier.value = 1;
        _pageController.jumpToPage(1);
      } else if (type == 'generate') {
        _pushInstant(const QRGeneratorScreen());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndexNotifier.dispose();
    super.dispose();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(type: 'scan', localizedTitle: 'QR Okut', icon: 'icon_scan'),
      ShortcutItem(
        type: 'generate',
        localizedTitle: 'Hızlı QR Oluştur',
        icon: 'icon_generate',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      resizeToAvoidBottomInset: false,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentIndexNotifier,
        builder: (context, currentIndex, child) {
          return Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  _currentIndexNotifier.value = index;
                },
                children: [
                  const DashboardScreen(),
                  currentIndex == 1
                      ? const QrScannerScreen()
                      : const SizedBox.shrink(),
                  const SettingsScreen(),
                ],
              ),

              FloatingNavbar(
                currentIndex: currentIndex,
                onIndexChanged: (index) {
                  _currentIndexNotifier.value = index;
                  _pageController.animateToPage(
                    index, 
                    duration: const Duration(milliseconds: 250), 
                    curve: Curves.easeOutQuad
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
