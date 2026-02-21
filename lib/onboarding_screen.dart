import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Curves;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'services/cloud_service.dart';
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

  List<Map<String, dynamic>> _getOnboardingData() => [
    {
      'title': 'Kullanım Politikaları',
      'description':
          'Uygulamayı kullanmaya devam ederek Gizlilik Politikası ve Kullanım Şartlarını kabul etmiş sayılırsınız.',
      'icon': CupertinoIcons.doc_text_search,
      'type': 'policy',
    },
    {
      'title': 'Hesabınızı Bağlayın',
      'description':
          'Bilgilerinizi yedeklemek ve tüm cihazlarınızdan kesintisiz kullanmak için giriş yapın.',
      'icon': CupertinoIcons.person_crop_circle_fill_badge_checkmark,
      'type': 'login',
    },
    {
      'title': 'Hoş Geldiniz!',
      'description':
          'Tüm sosyal medya hesaplarınızı tek bir yerde toplayabilir, kendi özel QR kartlarınızı oluşturabilirsiniz.',
      'icon': CupertinoIcons.qrcode,
      'type': 'info',
    },
    {
      'title': 'Ekleme ve Düzenleme',
      'description':
          'Link eklemek için "Link Ekle"ye basın. Düzenlemek veya silmek için kartın üzerine uzun süre basın.',
      'icon': CupertinoIcons.square_pencil,
      'type': 'info',
    },
    {
      'title': 'Nasıl Eklenir?',
      'description':
          'Ayarlar sayfasına gidip "Link Ekle" butonuna basarak dilediğiniz sosyal medya uygulamasını seçin ve linkini yapıştırın.',
      'icon': CupertinoIcons.settings,
      'type': 'info',
    },
    {
      'title': 'Nasıl Okunur?',
      'description':
          'Menüden "QR Okut" sekmesini seçin ve kameranızı okutmak istediğiniz koda yaklaştırın. URL adreslerine tek tıkla gidin.',
      'icon': CupertinoIcons.camera_viewfinder,
      'type': 'info',
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
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _nextPageWithLength(int length) {
    if (_currentPage < length - 1) {
      _pageController.jumpToPage(_currentPage + 1);
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isFirstTime', false);
      });
      _goToMain();
    }
  }

  void _nextPage() => _nextPageWithLength(_getOnboardingData().length);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = _getOnboardingData();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Background Gradient Logic
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
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
                    physics: onboardingData[_currentPage]['type'] == 'login'
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    itemCount: onboardingData.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) =>
                        _buildPage(onboardingData[index]),
                  ),
                ),
                _buildBottomControls(onboardingData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              color: Color(0xFF00D2FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'QURIO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconSection(data['icon'], data['type']),
          const SizedBox(height: 48),
          Text(
            data['title'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['description'],
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey.withValues(alpha: 0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (data['type'] == 'policy') ...[
            const SizedBox(height: 24),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PoliciesScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'Politikaları Oku',
                style: const TextStyle(
                  color: Color(0xFF00D2FF),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconSection(IconData icon, String type) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: Border.all(
          color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2FF).withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: 80, color: const Color(0xFF00D2FF)),
      ),
    );
  }

  Widget _buildBottomControls(List<Map<String, dynamic>> data) {
    final currentType = data[_currentPage]['type'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      child: Column(
        children: [
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              data.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF00D2FF)
                      : CupertinoColors.systemGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: currentType == 'login'
                  ? CupertinoColors.white
                  : const Color(0xFF00D2FF),
              borderRadius: BorderRadius.circular(16),
              onPressed: _isLoading
                  ? null
                  : () {
                      if (currentType == 'login') {
                        _signInWithGoogle();
                      } else {
                        _nextPageWithLength(data.length);
                      }
                    },
              child: _isLoading
                  ? const CupertinoActivityIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentType == 'login') ...[
                          const FaIcon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          _getButtonText(currentType, data.length),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: currentType == 'login'
                                ? const Color(0xFF0F172A)
                                : CupertinoColors.white,
                          ),
                        ),
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
    return 'İleri';
  }
}
