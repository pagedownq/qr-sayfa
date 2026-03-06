import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart' show Colors;
import 'package:visibility_detector/visibility_detector.dart';

import '../models/scan_history_item.dart';
import '../utils/app_state.dart';
import '../utils/url_launcher_util.dart';
import '../services/analytics_service.dart';
import '../services/ad_manager.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/haptic_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  String? barcodeValue;
  bool isAlertShowing = false;
  final MobileScannerController controller = MobileScannerController();
  bool isScannerActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      HapticService.selectionClick();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      if (capture == null || capture.barcodes.isEmpty) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(tr('error')),
              content: Text(tr('no_qr_found_in_image')),
              actions: [
                CupertinoDialogAction(
                  child: Text(tr('ok')),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } else {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null) {
          _showQrResult(code);
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        if (isScannerActive) controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.stop();
        break;
    }
  }

  bool _isUrl(String code) {
    final uri = Uri.tryParse(code);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'tel' || uri.scheme == 'mailto');
  }

  void _showQrResult(String code) {
    if (isAlertShowing) return;

    AnalyticsService.logScanQrCode(
      type: _isUrl(code) ? 'url' : 'text',
    );

    // Geçmişe ekle
    final newItem = ScanHistoryItem(content: code, timestamp: DateTime.now());
    scanHistoryNotifier.value = [newItem, ...scanHistoryNotifier.value];
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
        'scanHistory',
        jsonEncode(scanHistoryNotifier.value.map((e) => e.toJson()).toList()),
      );
    });

    setState(() {
      barcodeValue = code;
      isAlertShowing = true;
    });

    if (autoOpenUrlNotifier.value && _isUrl(code)) {
      if (isPremiumNotifier.value) {
         launchURL(code);
      } else {
         AdManager().showInterstitialAd(onAdDismissed: () {
           launchURL(code);
         });
      }
      setState(() {
        isAlertShowing = false;
      });
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(tr('qr_scanned')),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            if (_isUrl(code))
              CupertinoDialogAction(
                onPressed: () {
                  if (isPremiumNotifier.value) {
                     launchURL(code);
                  } else {
                     AdManager().showInterstitialAd(onAdDismissed: () {
                       launchURL(code);
                     });
                  }
                },
                child: Text(
                  tr('go_to_link'),
                  style: const TextStyle(color: CupertinoColors.activeBlue),
                ),
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isAlertShowing = false;
                });
              },
              child: Text(
                tr('close'),
                style: const TextStyle(color: CupertinoColors.systemGrey),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          isAlertShowing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPremiumNotifier,
      builder: (context, isPremium, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              tr('qr_scanner'),
              style: const TextStyle(color: CupertinoColors.white),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _pickImageFromGallery,
              child: const Icon(CupertinoIcons.photo_fill, color: CupertinoColors.white),
            ),
            backgroundColor: const Color(0xFF1E293B),
            border: null,
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (!isPremium) const BannerAdWidget(size: AdSize.banner),
                Expanded(
                  child: VisibilityDetector(
                    key: const Key('qr-scanner-visibility'),
                    onVisibilityChanged: (visibilityInfo) {
                      final visiblePercentage = visibilityInfo.visibleFraction * 100;
                      if (visiblePercentage > 50) {
                        if (!isScannerActive) {
                          isScannerActive = true;
                          controller.start();
                        }
                      } else {
                        if (isScannerActive) {
                          isScannerActive = false;
                          controller.stop();
                        }
                      }
                    },
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: controller,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                HapticService.heavyImpact();
                                _showQrResult(barcode.rawValue!);
                                break;
                              }
                            }
                          },
                        ),
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.activeBlue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        if (barcodeValue != null)
                          Positioned(
                            bottom: 120,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tr('last_scanned_value'),
                                    style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    barcodeValue!,
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
