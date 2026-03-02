import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import '../../controllers/qr_screen_controller.dart';
import '../../services/haptic_service.dart';
import '../premium_locked_widget.dart';
import '../../screens/premium_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'qr_generator_components.dart';

class CustomizerBottomSheet extends StatelessWidget {
  final QRScreenController controller;
  final bool isPremium;

  const CustomizerBottomSheet({
    super.key,
    required this.controller,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.70,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.65),
            border: Border(
              top: BorderSide(
                color: CupertinoColors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildPanel(context),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel(
              icon: CupertinoIcons.paintbrush_fill,
              text: 'TASARIMI ÖZELLEŞTİR',
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(
                CupertinoIcons.xmark_circle_fill,
                color: CupertinoColors.systemGrey,
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Ana Renk / Degrade (Gradient)"),
        if (!isPremium)
          PremiumLockedWidget(
            featureName: 'Degrade Renkler',
            child: _buildColorPalette(),
          )
        else
          _buildColorPalette(),
        
        _buildSectionTitle("Nokta Stili (Vücut Kalıbı)"),
        if (!isPremium)
          PremiumLockedWidget(
            featureName: 'Nokta Stilleri',
            child: _buildShapeSelector('shape'),
          )
        else
          _buildShapeSelector('shape'),
        
        _buildSectionTitle("Köşe Göz Stili"),
        if (!isPremium)
          PremiumLockedWidget(
            featureName: 'Köşe Tasarımları',
            child: _buildShapeSelector('eye'),
          )
        else
          _buildShapeSelector('eye'),
        
        _buildSectionTitle("Logo Ekle"),
        if (!isPremium)
          PremiumLockedWidget(
            featureName: 'Özel Logo',
            child: _buildLogoSection(context),
          )
        else
          _buildLogoSection(context),
        
        const SizedBox(height: 32),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (isPremium) {
              controller.saveTemplate();
              Navigator.pop(context);
            } else {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const PremiumScreen()),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D2FF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                isPremium ? "Şablon Olarak Kaydet" : "Premium’a Yükselt",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Column(
      children: [
        Row(
          children: [
            CupertinoSwitch(
              value: controller.useGradientValue,
              onChanged: (v) => controller.useGradient = v,
            ),
            const SizedBox(width: 12),
            const Text(
              "Degrade (Gradient) Kullan",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.useGradientValue)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: QRScreenController.gradientPresets.map((g) {
                final isSelected = controller.gradientColorsValue[0] == g[0] &&
                    controller.gradientColorsValue[1] == g[1];
                return _gradientNode(
                  g,
                  (selected) => controller.gradientColors = selected,
                  isSelected: isSelected,
                );
              }).toList(),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: QRScreenController.solidPresets.map((c) => _colorNode(
                    c,
                    (selected) => controller.qrColor = selected,
                    isSelected: controller.qrColorValue == c,
                  )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _gradientNode(List<Color> colors, Function(List<Color>) onSelect,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        onSelect(colors);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors[0].withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _colorNode(Color color, Function(Color) onSelect,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        onSelect(color);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildShapeSelector(String mode) {
    final shapes = ['square', 'rounded', 'circle'];
    final current =
        mode == 'shape' ? controller.qrShapeValue : controller.qrEyeShapeValue;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: shapes
            .map((s) => DesignCard(
                  label: s,
                  isSelected: current == s,
                  onTap: () {
                    HapticService.selectionClick();
                    if (mode == 'shape') {
                      controller.qrShape = s;
                    } else {
                      controller.qrEyeShape = s;
                    }
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final pickedFile =
                await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) controller.setLogo(pickedFile.path);
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: controller.logoPathValue != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(controller.logoPathValue!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(CupertinoIcons.camera_fill, color: Colors.white30),
          ),
        ),
        if (controller.logoPathValue != null) ...[
          const SizedBox(width: 12),
          CupertinoButton(
            child: const Text(
              "Logoyu Kaldır",
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
            onPressed: () => controller.setLogo(null),
          )
        ]
      ],
    );
  }
}
