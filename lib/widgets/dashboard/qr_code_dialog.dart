import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, FileImage;
import 'dart:io' show File;
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:gradient_borders/gradient_borders.dart';
import '../../models/social_link.dart';
import '../../utils/pretty_qr_helper.dart';
import '../../services/haptic_service.dart';

class QrCodeDialog extends StatelessWidget {
  final SocialLink link;
  final bool isPremium;

  const QrCodeDialog({
    super.key,
    required this.link,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final Color currentQrColor = isPremium ? (link.qrColor ?? const Color(0xFF0F172A)) : Colors.black;
    final Color currentQrBgColor = isPremium ? (link.qrBgColor ?? CupertinoColors.white) : CupertinoColors.white;
    final String currentShape = isPremium
        ? (link.qrShape == 'circle' ? 'circle' : (link.qrShape ?? 'square'))
        : 'square';
    
    final String currentEyeShape = isPremium
        ? (link.qrEyeShape == 'circle' ? 'circle' : (link.qrEyeShape ?? 'square'))
        : 'square';

    final bool currentUseLogo = isPremium && 
        link.qrLogoPath != null && 
        File(link.qrLogoPath!).existsSync();

    return Stack(
      children: [
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
                    Flexible(
                      child: Text(
                        link.platform,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: CupertinoColors.white,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentQrBgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    key: ValueKey(link.qrLogoPath),
                    aspectRatio: 1,
                    child: PrettyQrView.data(
                      data: link.url,
                      errorCorrectLevel: currentUseLogo ? QrErrorCorrectLevel.H : QrErrorCorrectLevel.M,
                      decoration: PrettyQrHelper.getDecoration(
                        shape: currentShape,
                        eyeShape: currentEyeShape,
                        color: currentQrColor,
                        image: currentUseLogo ? FileImage(File(link.qrLogoPath!)) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
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
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () {
                      HapticService.selectionClick();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kapat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  }
}
