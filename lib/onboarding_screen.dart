import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Curves;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'services/cloud_service.dart';
import 'services/analytics_service.dart';
import 'screens/policies_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Kullanım Politikaları',
      'description':
          'Uygulamayı kullanmaya devam ederek Gizlilik Politikası ve Kullanım Şartlarını kabul etmiş sayılırsınız.',
      'icon': CupertinoIcons.shield_lefthalf_fill,
      'type': 'policy',
      'highlight': 'Güvenliğiniz',
    },
    {
      'title': 'Hesabınızı Bağlayın',
      'description':
          'Bilgilerinizi bulut üzerinde yedeklemek ve tüm cihazlarınızdan kesintisiz bir deneyim yaşamak için hemen giriş yapın.',
      'icon': CupertinoIcons.cloud_upload_fill,
      'type': 'login',
      'highlight': 'Sınırsız Senkronizasyon',
    },
    {
      'title': 'Qurio\'ya Hoş Geldiniz',
      'description':
          'Tüm sosyal medya adreslerinizi ve linklerinizi tek bir noktada toplayın, sadece size özel QR kartınızı oluşturun.',
      'icon': CupertinoIcons.qrcode,
      'type': 'info',
      'highlight': 'Dijital Kimliğiniz',
    },
    {
      'title': 'Ekleme ve Düzenleme',
      'description':
          'Yepyeni bir bağlantı oluşturmak için "Link Ekle"ye dokunun. Seçenekleri düzenlemek ya da silmek için kartın üstüne basılı tutun.',
      'icon': CupertinoIcons.slider_horizontal_3,
      'type': 'info',
      'highlight': 'Tam Kontrol',
    },
    {
      'title': 'Nasıl Eklenir?',
      'description':
          'Ayarlar > "Link Ekle" rotasını takip ederek dilediğiniz sosyal medya uygulamasını seçin ve linkini yapıştırarak hızlıca entegre edin.',
      'icon': CupertinoIcons.settings_solid,
      'type': 'info',
      'highlight': 'Kolay Kurulum',
    },
    {
      'title': 'Nasıl Okutulur?',
      'description':
          'Aşağıdaki menüden "QR Okut" sekmesini seçin, kamerayı koda yaklaştırın ve gitmek istediğiniz adrese şimşek hızında erişin.',
      'icon': CupertinoIcons.viewfinder,
      'type': 'info',
      'highlight': 'Anında Erişim',
    },
  ];

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        await CloudService.fetchDataFromCloud();
        
        // Log event
        await AnalyticsService.logLogin(loginMethod: 'google');

        final prefs = await SharedPreferences.getInstance();
        final isFirstTime = prefs.getBool('isFirstTime') ?? true;

        if (isFirstTime) {
          _nextPage();
        } else {
          if (mounted) _goToMain();
        }
      }
    } catch (e) {
      debugPrint("Giriş Hatası: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _nextPageWithLength(int length) {
    if (_currentPage < length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isFirstTime', false);
      });
      _goToMain();
    }
  }

  void _nextPage() => _nextPageWithLength(_onboardingData.length);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Dynamic Background Glows
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            top: _currentPage.isEven ? -100 : 100,
            left: _currentPage.isEven ? -100 : 200,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2FF).withValues(alpha: 0.15),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            bottom: _currentPage.isOdd ? -50 : -200,
            right: _currentPage.isOdd ? -100 : 100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: _onboardingData[_currentPage]['type'] == 'login'
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final isCurrentPage = index == _currentPage;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isCurrentPage ? 1.0 : 0.4,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.only(top: isCurrentPage ? 10 : 40),
                          child: _buildPageContent(_onboardingData[index]),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.qrcode,
              color: CupertinoColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'QURIO',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glassmorphic Icon Container
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.05),
                  blurRadius: 50,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Icon(
                  data['icon'],
                  size: 90,
                  color: CupertinoColors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          
          // Glowing Highlight Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              data['highlight']?.toString().toUpperCase() ?? '',
              style: const TextStyle(
                color: Color(0xFF00D2FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            data['title'],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            data['description'],
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey.withValues(alpha: 0.8),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          // Policy Button Hook (if applicable)
          if (data['type'] == 'policy') ...[
            const SizedBox(height: 32),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PoliciesScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutQuart));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.doc_text, color: CupertinoColors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Şartları ve Gizliliği Oku',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final currentType = _onboardingData[_currentPage]['type'];
    final totalPages = _onboardingData.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.0),
            const Color(0xFF0F172A),
          ],
          stops: const [0.0, 0.4],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == index ? 28 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF00D2FF)
                      : CupertinoColors.systemGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D2FF).withValues(alpha: 0.5),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Primary Action Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: currentType == 'login'
                  ? CupertinoColors.white
                  : const Color(0xFF00D2FF),
              borderRadius: BorderRadius.circular(20),
              onPressed: _isLoading
                  ? null
                  : () {
                      if (currentType == 'login') {
                        _signInWithGoogle();
                      } else {
                        _nextPageWithLength(totalPages);
                      }
                    },
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: Color(0xFF0F172A))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentType == 'login') ...[
                          const FaIcon(
                            FontAwesomeIcons.google,
                            size: 22,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          _getButtonText(currentType, totalPages),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: currentType == 'login'
                                ? const Color(0xFF0F172A)
                                : CupertinoColors.white,
                          ),
                        ),
                        if (currentType != 'login') ...[
                          const SizedBox(width: 8),
                          const Icon(
                            CupertinoIcons.arrow_right,
                            size: 20,
                            color: CupertinoColors.white,
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

  String _getButtonText(String type, int total) {
    if (type == 'policy') return 'Kabul Et ve Başla';
    if (type == 'login') return 'Google ile Giriş Yap';
    if (_currentPage == total - 1) return 'Hadi İlk QR Oluşturalım';
    return 'Devam Et';
  }
}
