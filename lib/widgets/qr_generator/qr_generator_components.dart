import 'dart:io' show File;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../utils/pretty_qr_helper.dart';

class SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const SectionLabel({super.key, required this.icon, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D2FF), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class CustomizerButton extends StatelessWidget {
  final bool isPremium;
  const CustomizerButton({super.key, required this.isPremium});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B).withOpacity(0.8),
            const Color(0xFF0F172A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.paintbrush_fill, color: Color(0xFF00D2FF), size: 18),
          const SizedBox(width: 12),
          const Text(
            'Tasarımı Özelleştir',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
              fontSize: 15,
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.lock_fill, color: Color(0xFFFFD700), size: 14),
          ]
        ],
      ),
    );
  }
}

class DesignCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const DesignCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D2FF).withOpacity(0.1) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D2FF) : Colors.white10,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? const Color(0xFF00D2FF) : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MainActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final List<Color> gradient;
  
  const MainActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  
  const SecondaryActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CupertinoColors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaticBlob extends StatelessWidget {
  final Color color;
  final double opacity;
  final double size;
  const StaticBlob({super.key, required this.color, required this.opacity, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }
}

class QrEmptyState extends StatelessWidget {
  const QrEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.qrcode_viewfinder, size: 80,
            color: const Color(0xFF64748B).withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Oluşturmak için veri girin',
          style: TextStyle(
            color: const Color(0xFF94A3B8).withOpacity(0.6),
            fontSize: 15, fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class GlassPreviewCard extends StatelessWidget {
  final Color bgColor;
  final Widget child;
  final double shimmerValue;

  const GlassPreviewCard({
    super.key,
    required this.bgColor,
    required this.child,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 274, height: 274,
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.98),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
        ),
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-2.0 + (shimmerValue * 5), -1.0),
                    end: Alignment(0.0 + (shimmerValue * 5), 1.0),
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.4, 0.5, 0.6],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class PremiumQrView extends StatelessWidget {
  final String data;
  final bool isPremium;
  final bool useLogo;
  final String? logoPath;
  final String shape;
  final String eyeShape;
  final Color color;
  final bool useGradient;
  final List<Color> gradientColors;

  const PremiumQrView({
    super.key,
    required this.data,
    required this.isPremium,
    required this.useLogo,
    this.logoPath,
    required this.shape,
    required this.eyeShape,
    required this.color,
    required this.useGradient,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final effectShape = isPremium ? shape : 'square';
    final effectEye = isPremium ? eyeShape : 'square';
    final effectColor = isPremium ? color : Colors.black;
    final actuallyUseLogo = isPremium && useLogo && logoPath != null;

    Widget qrView = SizedBox(
      width: 210, height: 210,
      child: PrettyQrView.data(
        data: data,
        errorCorrectLevel: actuallyUseLogo ? QrErrorCorrectLevel.H : QrErrorCorrectLevel.M,
        decoration: PrettyQrHelper.getDecoration(
          shape: effectShape,
          eyeShape: effectEye,
          color: (useGradient && isPremium) ? Colors.white : effectColor,
          image: actuallyUseLogo ? FileImage(File(logoPath!)) : null,
        ),
      ),
    );

    if (useGradient && isPremium) {
      qrView = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: qrView,
      );
    }

    return qrView;
  }
}
