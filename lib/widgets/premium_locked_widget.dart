import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../services/haptic_service.dart';
import '../screens/premium_screen.dart';

class PremiumLockedWidget extends StatelessWidget {
  final String featureName;
  final Widget child;

  const PremiumLockedWidget({
    super.key,
    required this.featureName,
    required this.child,
  });

  void _showPremiumDialog(BuildContext context) {
    HapticService.selectionClick();
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPremiumDialog(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Original Feature UI (slightly blurred or desaturated)
          Opacity(
            opacity: 0.5,
            child: child,
          ),
          
          // Lock Overlay
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.lock_fill,
              color: Color(0xFFFFD700), // Gold
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
