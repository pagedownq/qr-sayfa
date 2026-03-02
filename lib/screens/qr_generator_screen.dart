import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, FileImage, Material;
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../utils/pretty_qr_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' show ImageFilter;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/analytics_service.dart';
import '../services/ad_manager.dart';
import '../services/qr_service.dart';
import '../services/haptic_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/premium_locked_widget.dart';
import '../controllers/qr_screen_controller.dart';
import '../utils/app_state.dart';
import 'premium_screen.dart';

import '../models/platform_model.dart';
import '../constants/platforms.dart';
import '../widgets/qr_generator/qr_generator_components.dart';
import '../widgets/qr_generator/qr_customizer_sheet.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> with SingleTickerProviderStateMixin {
  late final QRScreenController _qrController;
  final GlobalKey _qrBoundaryKey = GlobalKey();
  
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Track rendering state
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _qrController = QRScreenController();
    
    _shimmerController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3)
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveGallery() async {
    if (_qrController.qrDataNotifier.value.isEmpty) {
      _showErrorDialog('Lütfen önce bir metin veya link girin.');
      return;
    }

    setState(() => _isCapturing = true);
    HapticService.lightImpact();

    try {
      final captureResult = await QRService.captureFromBoundary(_qrBoundaryKey);
      if (!captureResult.success || captureResult.data == null) {
        _showErrorDialog(captureResult.message ?? 'QR Kod yakalanamadı.');
        return;
      }

      final saveResult = await QRService.saveToGallery(captureResult.data!);
      if (saveResult.success) {
        AnalyticsService.logCreateQrCode(dataType: 'custom_text');
        _showSuccessDialog('QR Kod başarıyla galeriye kaydedildi!');
        
        if (!isPremiumNotifier.value) {
          AdManager().showInterstitialAd();
        }
      } else {
        _showErrorDialog(saveResult.message ?? 'Galeriye kaydedilemedi.');
      }
    } catch (e) {
      _showErrorDialog('Hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _handleSavePDF() async {
    if (_qrController.qrDataNotifier.value.isEmpty) {
      _showErrorDialog('Lütfen önce bir metin veya link girin.');
      return;
    }

    setState(() => _isCapturing = true);
    HapticService.heavyImpact();

    try {
      final ratio = QRService.getIdealPdfPixelRatio(context);
      final captureResult = await QRService.captureFromBoundary(_qrBoundaryKey, pixelRatio: ratio);
      
      if (!captureResult.success || captureResult.data == null) {
        _showErrorDialog(captureResult.message ?? 'QR Kod yakalanamadı.');
        return;
      }

      final pdfResult = await QRService.saveAndSharePDF(
        captureResult.data!, 
        text: 'Qurio Uygulaması ile Oluşturulmuştur'
      );

      if (pdfResult.success) {
        AnalyticsService.logCreateQrCode(dataType: 'custom_text_pdf');
      } else {
        _showErrorDialog(pdfResult.message ?? 'PDF paylaşılamadı.');
      }
    } catch (e) {
      _showErrorDialog('PDF oluşturulurken hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Başarılı'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Harika'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPermissionErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İzin Gerekli'),
        content: const Text('QR kodun galeriye kaydedilmesi için fotoğraf erişim izni gereklidir. Lütfen ayarlardan izin verin.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ayarlara Git'),
            onPressed: () {
              Navigator.pop(context);
              // In real apps, use openAppSettings()
            },
          ),
        ],
      ),
    );
  }

  void _showCustomizerModal(BuildContext context, bool isPremium) {
    HapticService.selectionClick();
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.6),
      builder: (context) => CustomizerBottomSheet(
        controller: _qrController, 
        isPremium: isPremium
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPremiumNotifier,
      builder: (context, isPremium, child) {
        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFF0F172A),
          navigationBar: const CupertinoNavigationBar(
            middle: Text(
              'Hızlı QR Oluştur',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            backgroundColor: Color(0x900F172A),
            border: null,
          ),
          child: Stack(
            children: [
              _buildBackgroundBlobs(),

              SafeArea(
                child: Column(
                  children: [
                    if (!isPremium) const BannerAdWidget(size: AdSize.largeBanner),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            RepaintBoundary(child: _buildPlatformSelector(isPremium)),
                            const SizedBox(height: 32),
                            RepaintBoundary(child: _buildInputSection()),
                            const SizedBox(height: 48),
                            _buildQRPreview(isPremium),
                            const SizedBox(height: 54),
                            RepaintBoundary(child: _buildActionButtons(isPremium)),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              ListenableBuilder(
                listenable: _qrController,
                builder: (context, _) => _qrController.isLogoLoading || _isCapturing
                  ? Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CupertinoActivityIndicator(radius: 20, color: Colors.white),
                      ),
                    )
                  : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlatformSelector(bool isPremium) {
    // Only show top popular platforms
    final popular = AppPlatforms.availablePlatforms.where((p) => 
      ['instagram', 'x-twitter', 'tiktok', 'youtube', 'whatsapp', 'facebook', 'linkedin', 'telegram', 'discord', 'github', 'spotify'].contains(p.id)
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(icon: CupertinoIcons.sparkles, text: 'HIZLI SEÇİM'),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: popular.map((p) => GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                if (isPremium) {
                  _qrController.applyPlatformLogo(p);
                  if (_qrController.inputController.text.isEmpty) {
                    _qrController.inputController.text = p.inputHint;
                  }
                } else {
                  _showPremiumSuggestion();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.color.withOpacity(0.3)),
                ),
                child: Icon(p.icon, color: p.color, size: 24),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _showPremiumSuggestion() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Premium Gerekli'),
        content: const Text('Platform logolarını QR kodun ortasına eklemek premium bir özelliktir.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Kapat'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Premium\'a Geç'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, CupertinoPageRoute(builder: (context) => const PremiumScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return const RepaintBoundary(
      child: Stack(
        children: [
          Positioned(
            top: -100, left: -100,
            child: StaticBlob(color: Color(0xFF00D2FF), opacity: 0.15, size: 350),
          ),
          Positioned(
            bottom: 100, right: -150,
            child: StaticBlob(color: Color(0xFF3B82F6), opacity: 0.1, size: 450),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: StaticBlob(color: Color(0xFF6366F1), opacity: 0.1, size: 300),
          ),
        ],
      ),
    );
  }


  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.35),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: CupertinoColors.white.withOpacity(0.1), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: _buildTextInput(),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(icon: CupertinoIcons.text_quote, text: 'İÇERİK'),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _qrController.inputController,
          placeholder: 'Link veya metin yapıştırın...',
          placeholderStyle: TextStyle(
            color: const Color(0xFF94A3B8).withOpacity(0.4),
            fontSize: 15,
          ),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: const Color(0xFF00D2FF),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x20FFFFFF)),
          ),
          padding: const EdgeInsets.all(16),
          maxLines: 4,
        ),
      ],
    );
  }


  Widget _buildQRPreview(bool isPremium) {
    return ValueListenableBuilder<String>(
      valueListenable: _qrController.qrDataNotifier,
      builder: (context, data, _) {
        if (data.isEmpty) return const QrEmptyState();

        return Column(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showCustomizerModal(context, isPremium),
              child: CustomizerButton(isPremium: isPremium),
            ),
            const SizedBox(height: 48),
            ListenableBuilder(
              listenable: _qrController,
              builder: (context, _) {
                return RepaintBoundary(
                  key: _qrBoundaryKey,
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, _) {
                      return GlassPreviewCard(
                        bgColor: isPremium ? _qrController.bgColorValue : CupertinoColors.white,
                        shimmerValue: isPremium ? _shimmerAnimation.value : 0,
                        child: PremiumQrView(
                          data: data,
                          isPremium: isPremium,
                          useLogo: _qrController.useLogoValue,
                          logoPath: _qrController.logoPathValue,
                          shape: _qrController.qrShapeValue,
                          eyeShape: _qrController.qrEyeShapeValue,
                          color: _qrController.qrColorValue,
                          useGradient: _qrController.useGradientValue,
                          gradientColors: _qrController.gradientColorsValue,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildActionButtons(bool isPremium) {
    return Column(
      children: [
        MainActionButton(
          text: 'Galeriye Kaydet (PNG)',
          icon: CupertinoIcons.arrow_down_to_line_alt,
          onPressed: _handleSaveGallery,
          gradient: const [Color(0xFF00D2FF), Color(0xFF3B82F6)],
        ),
        const SizedBox(height: 16),
        if (isPremium)
          SecondaryActionButton(
            text: 'Profesyonel Baskı (PDF)',
            icon: CupertinoIcons.doc_text_fill,
            onPressed: _handleSavePDF,
          ),
      ],
    );
  }
}

