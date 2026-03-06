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
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get _onboardingData => [
    {
      'title': tr('onboarding_1_title'),
      'description': tr('onboarding_1_desc'),
      'icon': CupertinoIcons.qrcode,
      'type': 'policy',
      'highlight': tr('onboarding_1_highlight'),
    },
    {
      'title': tr('onboarding_2_title'),
      'description': tr('onboarding_2_desc'),
      'icon': CupertinoIcons.cloud_fill,
      'type': 'login',
      'highlight': tr('onboarding_2_highlight'),
    },
    {
      'title': tr('onboarding_3_title'),
      'description': tr('onboarding_3_desc'),
      'icon': CupertinoIcons.sparkles,
      'type': 'finish',
      'highlight': tr('onboarding_3_highlight'),
    },
  ];

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final String? clientId = !kIsWeb && Platform.isIOS
          ? DefaultFirebaseOptions.ios.iosClientId
          : null;
      final String? serverClientId = !kIsWeb && Platform.isIOS
          ? '1085894990290-f3d5svrmhon0u97ch7shkuus85s2ivba.apps.googleusercontent.com'
          : null;

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: clientId,
        serverClientId: serverClientId,
      ).signIn();
      
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        await CloudService.fetchDataFromCloud();
        await AnalyticsService.logLogin(loginMethod: 'google');

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isFirstTime', false); // Already logged in, no need for tour again
        
        if (mounted) _goToMain();
      }
    } catch (e) {
      debugPrint("Giriş Hatası: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      if (Platform.isAndroid) {
        final appleProvider = AppleAuthProvider();
        appleProvider.addScope('email');
        appleProvider.addScope('name');
        await FirebaseAuth.instance.signInWithProvider(appleProvider);
      } else {
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final OAuthCredential credential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        // Apple carries name info ONLY on the first login. 
        // We capture it here and update the Firebase profile.
        if (appleCredential.givenName != null) {
          String fullName = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim();
          await FirebaseAuth.instance.currentUser?.updateDisplayName(fullName);
        }
      }

      await CloudService.fetchDataFromCloud();
      await AnalyticsService.logLogin(loginMethod: 'apple');

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isFirstTime', false);
      
      if (mounted) _goToMain();
    } catch (e) {
      debugPrint("Apple Giriş Hatası: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.-_';
    final random = Random.secure();
    return List.generate(length, (index) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await CloudService.fetchDataFromCloud();
      await AnalyticsService.logLogin(loginMethod: 'email');

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isFirstTime', false);

      if (mounted) _goToMain();
    } catch (e) {
      debugPrint("E-posta Giriş Hatası: $e");
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(tr('login_error')),
            content: Text(tr('email_password_error')),
            actions: [
              CupertinoDialogAction(
                child: Text(tr('ok')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEmailLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(tr('login_with_email')),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              CupertinoTextField(
                controller: emailController,
                placeholder: tr('email_address'),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: CupertinoColors.white),
                placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: passwordController,
                placeholder: tr('password'),
                obscureText: true,
                style: const TextStyle(color: CupertinoColors.white),
                placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(tr('cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(tr('login')),
            onPressed: () {
              final email = emailController.text;
              final password = passwordController.text;
              Navigator.pop(context);
              _signInWithEmail(email, password);
            },
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isFirstTime', false);
      });
      _goToMain();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Static soft background glow
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2FF).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: _onboardingData[_currentPage]['type'] == 'login'
                        ? const NeverScrollableScrollPhysics() // Force login step
                        : const BouncingScrollPhysics(),
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return _buildPageContent(_onboardingData[index]);
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

  Widget _buildPageContent(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(
              data['icon'],
              size: 80,
              color: const Color(0xFF00D2FF),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            data['highlight'],
            style: const TextStyle(
              color: Color(0xFF00D2FF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey.withOpacity(0.8),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (data['type'] == 'policy') ...[
            const SizedBox(height: 40),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const PoliciesScreen()),
              ),
              child: Text(
                tr('read_terms_of_use'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
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
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF00D2FF)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          if (currentType == 'login') ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(20),
                onPressed: _isLoading ? null : _signInWithGoogle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.google, size: 20, color: Color(0xFF0F172A)),
                    const SizedBox(width: 12),
                    Text(
                      tr('continue_with_google'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (Platform.isIOS) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: _isLoading ? null : _signInWithApple,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.apple, size: 22, color: CupertinoColors.white),
                      const SizedBox(width: 10),
                      Text(
                        tr('continue_with_apple'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                onPressed: _isLoading ? null : _showEmailLoginDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.mail_solid, size: 20, color: CupertinoColors.white),
                    const SizedBox(width: 12),
                    Text(
                      tr('continue_with_email'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              height: 64,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: const Color(0xFF00D2FF),
                borderRadius: BorderRadius.circular(24),
                onPressed: _isLoading ? null : _nextPage,
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: Color(0xFF0F172A))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getButtonText(currentType),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.arrow_right, size: 18, color: CupertinoColors.white),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }

  String _getButtonText(String type) {
    if (type == 'policy') return tr('accept_and_start');
    if (type == 'login') return tr('connect_with_google');
    return tr('lets_start');
  }
}
