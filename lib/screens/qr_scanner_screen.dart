import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart' show Colors;
import 'package:visibility_detector/visibility_detector.dart';

import '../models/scan_history_item.dart';
import '../utils/app_state.dart';
import '../utils/url_launcher_util.dart';

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
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _showQrResult(String code) {
    if (isAlertShowing) return;

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
      launchURL(code);
      setState(() {
        isAlertShowing = false;
      });
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('QR Okundu!'),
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
                  launchURL(code);
                },
                child: Text(
                  'Bağlantıya Git',
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
                'Kapat',
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'QR Okuyucu',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      child: SafeArea(
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
                      color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Son Okunan Değer:',
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
    );
  }
}
