import 'package:flutter/cupertino.dart';
import '../utils/app_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Hakkında',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF1E293B),
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Clean App Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  CupertinoIcons.qrcode,
                  size: 40,
                  color: Color(0xFF00D2FF),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Qurio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: appVersionNotifier,
                builder: (context, version, _) {
                  return Text(
                    'Sürüm $version',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 64),

              // Simple Flat Info Blocks
              _buildModernAboutSection(
                title: 'Vizyonumuz',
                content: 'Tüm dijital kanallarınızı tek bir noktada birleştiren en minimalist paylaşım aracı olmayı hedefliyoruz.',
              ),
              const SizedBox(height: 48),
              _buildModernAboutSection(
                title: 'Hız ve Güvenlik',
                content: 'Verileriniz bulutla senkronize edilir ve istediğiniz an tüm cihazlarınızdan erişilebilir.',
              ),
              const SizedBox(height: 48),
              _buildModernAboutSection(
                title: 'Geliştirici',
                content: 'MGVerse — Ankara, 2026',
              ),

              const SizedBox(height: 100),
              
              const Text(
                '© 2026 MGVerse',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAboutSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF00D2FF),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 15,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
