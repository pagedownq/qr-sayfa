import 'package:flutter/cupertino.dart';
import '../services/haptic_service.dart';
import '../utils/app_theme.dart';

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 34,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.glassBackground, // alpha: 0.95
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppTheme.borderLight, // alpha: 0.12
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowDark, // alpha: 0.4
              blurRadius: 30,
              offset: Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              icon: CupertinoIcons.house_fill,
              onTap: onIndexChanged,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              icon: CupertinoIcons.qrcode_viewfinder,
              onTap: onIndexChanged,
            ),
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              icon: CupertinoIcons.settings_solid,
              onTap: onIndexChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isSelected) {
          HapticService.selectionClick();
          onTap(index);
        }
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : const Color(0x99999999),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryBlue : const Color(0x99999999),
                size: isSelected ? 30 : 28,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(top: 6),
              height: isSelected ? 4 : 0,
              width: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xCC00D2FF), // alpha: 0.8
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
