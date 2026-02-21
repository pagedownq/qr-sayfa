import 'package:flutter/cupertino.dart';
import 'dart:ui' show ImageFilter;
import '../utils/app_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Uygulama Hakkında',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: null,
      ),
      child: Stack(
        children: [
          // Background Gradient Decor (Glow Effect)
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2FF).withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // App Icon and Title Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.8),
                            border: Border.all(
                              color: const Color(
                                0xFF00D2FF,
                              ).withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00D2FF,
                                ).withValues(alpha: 0.1),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.qrcode,
                            size: 70,
                            color: Color(0xFF00D2FF),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Qurio',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: appVersionNotifier,
                          builder: (context, version, _) {
                            return Text(
                              '${'Sürüm'} $version',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Glass Content Card
                  _buildGlassInfoCard(
                    title: 'Uygulama Hakkında',
                    content:
                        'Qurio, tüm sosyal medya hesaplarınızı veya web sitenizi tek bir QR kodu içinde toplayarak paylaşmanızı sağlayan modern bir araçtır. Amacımız, dijital dünyadaki varlığınızı en hızlı ve en şık şekilde başkalarına aktarmanıza yardımcı olmaktır.',
                  ),

                  const SizedBox(height: 24),

                  // Glass Developer Card
                  _buildGlassInfoCard(
                    title: 'Geliştirici',
                    content:
                        'Mehmet G. (MGVerse)\\nModern deneyimler ve güvenli çözümler için tasarlandı.',
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Text(
                    '© 2026 MGVerse\n${'Tüm hakları saklıdır.'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00D2FF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
