import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/platform_model.dart';
import '../constants/platforms.dart';
import '../services/haptic_service.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() => _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PlatformModel> _filteredPlatforms = AppPlatforms.availablePlatforms;

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlatforms = AppPlatforms.availablePlatforms;
      } else {
        _filteredPlatforms = AppPlatforms.availablePlatforms
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      
      if (_filteredPlatforms.isEmpty) {
        HapticService.error();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x801E293B),
        border: null,
        middle: const Text(
          'Platform Seçin',
          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search Bar Area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  placeholder: 'Platform ara...',
                  style: const TextStyle(color: CupertinoColors.white),
                  placeholderStyle: TextStyle(color: CupertinoColors.white.withOpacity(0.3)),
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.6),
                ),
              ),
            ),

            // Help Text or Empty State
            if (_filteredPlatforms.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 64,
                      color: const Color(0xFF94A3B8).withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sonuç bulunamadı',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8).withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return PlatformCard(
                        platform: _filteredPlatforms[index],
                        index: index,
                        onTap: () {
                          HapticService.selectionClick();
                          Navigator.of(context).pop({
                            'id': _filteredPlatforms[index].id,
                            'name': _filteredPlatforms[index].name,
                            'icon': _filteredPlatforms[index].icon,
                            'color': _filteredPlatforms[index].color,
                            'inputHint': _filteredPlatforms[index].inputHint,
                          });
                        },
                      );
                    },
                    childCount: _filteredPlatforms.length,
                  ),
                ),
              ),
            
            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformCard extends StatefulWidget {
  final PlatformModel platform;
  final int index;
  final VoidCallback onTap;

  const PlatformCard({
    super.key,
    required this.platform,
    required this.index,
    required this.onTap,
  });

  @override
  State<PlatformCard> createState() => _PlatformCardState();
}

class _PlatformCardState extends State<PlatformCard> with SingleTickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Interval(
          (widget.index % 15) * 0.05,
          1.0,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Interval(
          (widget.index % 15) * 0.05,
          0.8,
          curve: Curves.easeIn,
        ),
      ),
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()..scale(_isPressed ? 0.94 : 1.0),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed 
                    ? widget.platform.color.withOpacity(0.6) 
                    : Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
                boxShadow: [
                  if (_isPressed)
                    BoxShadow(
                      color: widget.platform.color.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: -5,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container with Glassy Glow
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.platform.color.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.platform.color.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.platform.icon,
                        color: widget.platform.color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Responsive Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 16,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.platform.name,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

