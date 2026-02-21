import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' show ImageFilter;
class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _qrData = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveQR() async {
    if (_qrData.isEmpty) {
      _showToast('Lütfen önce bir metin veya link girin.');
      return;
    }

    // Request permissions
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      _showToast('QR kodu kaydetmek için galeri izni gereklidir.');
      return;
    }

    try {
      final Uint8List? image = await _screenshotController.captureFromWidget(
        Container(
          padding: const EdgeInsets.all(20),
          color: CupertinoColors.white,
          child: QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: 300.0,
            gapless: false,
          ),
        ),
      );

      if (image != null) {
        await Gal.putImageBytes(image, name: "QR_Code_${DateTime.now().millisecondsSinceEpoch}");
        _showToast('QR Kod başarıyla galeriye kaydedildi!');
      }
    } catch (e) {
      _showToast('${'Hata oluştu: '}$e');
    }
  }

  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('Tamam'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Hızlı QR Oluştur',
          style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0x801E293B),
        border: null,
      ),
      child: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Input Section
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: CupertinoColors.white.withValues(alpha: 0.08), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İÇERİK',
                                style: const TextStyle(
                                  color: Color(0xFF00D2FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              CupertinoTextField(
                                controller: _controller,
                                placeholder: 'Metin veya link girin...',
                                placeholderStyle: TextStyle(color: const Color(0xFF64748B).withValues(alpha: 0.5)),
                                style: const TextStyle(color: CupertinoColors.white),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(16),
                                maxLines: 3,
                                onChanged: (val) {
                                  setState(() {
                                    _qrData = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // QR Preview Section
                  if (_qrData.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      color: const Color(0xFF00D2FF),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: _saveQR,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.cloud_download, color: CupertinoColors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Kaydet'ToGallery,
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 60),
                    Icon(
                      CupertinoIcons.qrcode_viewfinder,
                      size: 100,
                      color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'QR kodunuz burada görünecek',
                      style: TextStyle(color: const Color(0xFF64748B).withValues(alpha: 0.7)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
