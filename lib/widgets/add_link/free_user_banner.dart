import 'package:flutter/cupertino.dart';
import '../../screens/premium_screen.dart';

class FreeUserBanner extends StatelessWidget {
  const FreeUserBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D2FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.star_fill, color: Color(0xFF00D2FF), size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Özellikler',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'QR renklerini ve şekillerini değiştirin',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFF00D2FF),
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const PremiumScreen()),
                );
              },
              child: const Text(
                'Premium\'a Geç',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
