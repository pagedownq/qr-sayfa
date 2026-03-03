import 'package:flutter/cupertino.dart';
import '../../models/social_link.dart';
import '../../services/haptic_service.dart';

class SocialGridItem extends StatelessWidget {
  final SocialLink link;
  final bool isPremium;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SocialGridItem({
    super.key,
    required this.link,
    required this.isPremium,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      onLongPress: () {
        HapticService.heavyImpact();
        onLongPress();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: link.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(link.icon, size: 50, color: link.color),
            const SizedBox(height: 16),
            Text(
              link.platform,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
