import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

class LinkDesignCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const LinkDesignCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00D2FF).withOpacity(0.1) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF00D2FF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: child,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00D2FF) : CupertinoColors.systemGrey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class ColorPalette extends StatelessWidget {
  final Color selected;
  final Function(Color) onSelect;

  const ColorPalette({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<Color> paletteColors = [
    Color(0xFF0F172A), // Dark
    CupertinoColors.white,
    CupertinoColors.systemBlue,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
    CupertinoColors.systemGreen,
    CupertinoColors.systemOrange,
    CupertinoColors.systemIndigo,
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: paletteColors.map((color) {
        final isSelected = selected.value == color.value;
        return GestureDetector(
          onTap: () => onSelect(color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF00D2FF) : Colors.white.withOpacity(0.1),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: isSelected ? const Icon(
              CupertinoIcons.checkmark,
              size: 18,
              color: Color(0xFF00D2FF),
            ) : null,
          ),
        );
      }).toList(),
    );
  }
}

class CupertinoInput extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType type;
  final bool obscure;

  const CupertinoInput({
    super.key,
    required this.controller,
    required this.placeholder,
    this.type = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: type,
      obscureText: obscure,
      padding: const EdgeInsets.all(16),
      placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
      style: const TextStyle(color: CupertinoColors.white),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
    );
  }
}

class InputLabel extends StatelessWidget {
  final String label;

  const InputLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: CupertinoColors.systemGrey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SegmentedText extends StatelessWidget {
  final String text;
  final bool isSelected;
  final double fontSize;

  const SegmentedText({
    super.key,
    required this.text,
    required this.isSelected,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? CupertinoColors.black : CupertinoColors.white,
          fontSize: fontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class ShapeIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const ShapeIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: isSelected ? const Color(0xFF00D2FF) : CupertinoColors.white,
      size: 28,
    );
  }
}
