import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../models/social_link.dart';
import '../../utils/pretty_qr_helper.dart';
import 'dart:io';

class DashboardCoverCard extends StatelessWidget {
  final List<SocialLink> links;
  final bool isPremium;
  final Function(SocialLink) onQrTap;

  const DashboardCoverCard({
    super.key,
    required this.links,
    required this.isPremium,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();
    
    final primaryLink = links.first;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryLink.color.withValues(alpha: 0.8),
            primaryLink.color.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryLink.color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ANA KART',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  primaryLink.platform,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hızlı paylaşım için okutun',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onQrTap(primaryLink),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: 70,
                height: 70,
                child: PrettyQrView.data(
                  data: primaryLink.url,
                  errorCorrectLevel: (isPremium && primaryLink.qrLogoPath != null) ? QrErrorCorrectLevel.H : QrErrorCorrectLevel.M,
                  decoration: PrettyQrHelper.getDecoration(
                    shape: isPremium ? (primaryLink.qrShape ?? 'square') : 'square',
                    eyeShape: isPremium ? (primaryLink.qrEyeShape ?? 'square') : 'square',
                    color: Colors.black,
                    image: (isPremium && primaryLink.qrLogoPath != null) ? FileImage(File(primaryLink.qrLogoPath!)) : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
