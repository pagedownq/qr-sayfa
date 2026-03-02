import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/iap_service.dart';
import '../services/haptic_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with SingleTickerProviderStateMixin {
  final IAPService _iapService = IAPService();
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _iapService.addListener(_updateUI);
    if (_iapService.products.isEmpty) {
      _iapService.initialize();
    }

    _glowController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iapService.removeListener(_updateUI);
    _glowController.dispose();
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      if (_iapService.isPremium) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x00000000), // Transparent
        border: null,
        middle: const Text(
          'Qurio Premium',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            'Geri Yükle',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => _iapService.restorePurchases(),
        ),
      ),
      child: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            top: -50,
            right: -100,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _glowAnimation.value,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x26FFD700), // Golden Glow
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2FF).withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Premium Crown Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFDB931)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.star_fill,
                            color: Color(0xFF0F172A),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Title
                        const Text(
                          'Premium\'a Geçin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tüm özelliklerin kilidini açın ve reklamsız\ndeneyimin tadını çıkarın.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Features List
                        _buildFeatureRow(CupertinoIcons.nosign, 'Reklamsız Deneyim', 'Kesintisiz kullanımın keyfini çıkarın'),
                        const SizedBox(height: 24),
                        _buildFeatureRow(CupertinoIcons.color_filter, 'Sınırsız Özelleştirme', 'QR kodlarınızı dilediğiniz gibi tasarlayın'),
                        const SizedBox(height: 24),
                        _buildFeatureRow(CupertinoIcons.cloud_download_fill, 'Yüksek Kalite İndirme', 'En net ve kaliteli formatta kaydedin'),
                        
                        const Spacer(),
                        const SizedBox(height: 32),

                        // Products Wrapper
                        _buildProductsSection(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A00), // Koyu sarımsı arka plan
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFFD700), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    if (!_iapService.isAvailable) {
      return const Center(
        child: Text('Mağaza bağlantısı sağlanamadı.', style: TextStyle(color: CupertinoColors.destructiveRed)),
      );
    }
    if (_iapService.products.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    // Seçili ürünü ayarla (varsayılan: yıllık veya ilk ürün)
    if (_selectedProductId == null) {
      try {
        _selectedProductId = _iapService.products.firstWhere((p) => p.id.contains('yearly')).id;
      } catch (_) {
        _selectedProductId = _iapService.products.first.id;
      }
    }

    return Column(
      children: [
        ..._iapService.products.map((product) {
          final bool isYearly = product.id.contains('yearly');
          final bool isSelected = product.id == _selectedProductId;
          
          return GestureDetector(
            onTap: () {
              HapticService.selectionClick();
              setState(() => _selectedProductId = product.id);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: isSelected && isYearly ? null : const Color(0xFF1E293B).withOpacity(0.5),
                      gradient: isSelected && isYearly ? const LinearGradient(
                        colors: [Color(0xFF2A2A00), Color(0xFF1A1A00)],
                      ) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFD700) : const Color(0x33FFFFFF),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isYearly ? 'Yıllık' : 'Aylık',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                if (isYearly) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B3300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '%20 Tasarruf',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isYearly ? '2 Ay Bedava fırsatıyla' : 'Her ay faturalandırılır',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              product.price,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isYearly ? '/yıllık' : '/aylık',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isYearly)
                    Positioned(
                      top: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'EN POPÜLER',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Abone Ol Butonu
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticService.heavyImpact();
            if (_selectedProductId != null) {
              try {
                 final product = _iapService.products.firstWhere((p) => p.id == _selectedProductId);
                 _iapService.buyProduct(product);
              } catch (_) {}
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Abone Ol',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        const Text(
          'Ödeme Apple/Google Play hesabınızdan tahsil edilecektir.\nİstediğiniz zaman iptal edin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.4,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 32),
        
        // Özel Teklif Banner
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1C00), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0x33FFD700)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(
                    CupertinoIcons.sparkles,
                    size: 150,
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Özel Teklif',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arkadaşlarını davet et, 1 ay ücretsiz kazan.',
                        style: TextStyle(
                          color: CupertinoColors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
