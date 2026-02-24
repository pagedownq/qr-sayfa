import 'package:flutter/cupertino.dart';
import 'dashboard_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'qr_generator_screen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final QuickActions _quickActions = const QuickActions();

  Future<void> _checkForUpdate() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
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
        setState(() => _currentIndex = 1);
      } else if (type == 'generate') {
        _pushInstant(const QRGeneratorScreen());
      }
    });
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
      child: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const DashboardScreen(),
              _currentIndex == 1
                  ? const QrScannerScreen()
                  : const SizedBox.shrink(),
              const SettingsScreen(),
            ],
          ),

          // iOS 26 Style Premium Floating Navbar
          Positioned(
            left: 24,
            right: 24,
            bottom: 34,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xF21E293B), // alpha: 0.95
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0x1EFFFFFF), // alpha: 0.12
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000), // alpha: 0.4
                    blurRadius: 30,
                    offset: Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, CupertinoIcons.house_fill),
                  _buildNavItem(1, CupertinoIcons.qrcode_viewfinder),
                  _buildNavItem(2, CupertinoIcons.settings_solid),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00D2FF)
                  : const Color(0x99999999), // approx grey alpha 0.6
              size: 28,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 6),
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D2FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xCC00D2FF), // alpha: 0.8
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
