import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_state.dart';
import '../services/haptic_service.dart';

import '../utils/logo_generator.dart';
import '../models/platform_model.dart';
import '../constants/platforms.dart';

class QRScreenController extends ChangeNotifier {
  // UI Data Notifiers - Keep as ValueNotifier for real-time input debounce
  final TextEditingController inputController = TextEditingController();
  final ValueNotifier<String> qrDataNotifier = ValueNotifier<String>('');
  
  bool _isLogoLoading = false;
  bool get isLogoLoading => _isLogoLoading;
  
  // Predefined Presets
  static const List<Color> solidPresets = [
    Colors.black,
    Color(0xFF3B82F6), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
  ];

  static const List<List<Color>> gradientPresets = [
    [Color(0xFF00D2FF), Color(0xFF3B82F6)], // Electric Blue
    [Color(0xFFF59E0B), Color(0xFFEF4444)], // Sunset
    [Color(0xFF10B981), Color(0xFF059669)], // Emerald
    [Color(0xFF8B5CF6), Color(0xFFD946EF)], // Bubblegum
    [Color(0xFF06B6D4), Color(0xFF10B981)], // Oceanic
    [Color(0xFF000000), Color(0xFF434343)], // Midnight
  ];

  // Customization State
  Color _qrColor = solidPresets[0];
  Color _bgColor = CupertinoColors.white;
  String _qrShape = 'square';
  String _qrEyeShape = 'square';
  bool _useLogo = false;
  String? _logoPath;
  bool _useGradient = false;
  List<Color> _gradientColors = [Color(0xFF00D2FF), Color(0xFF3B82F6)];

  // Getters
  Color get qrColorValue => _qrColor;
  Color get bgColorValue => _bgColor;
  String get qrShapeValue => _qrShape;
  String get qrEyeShapeValue => _qrEyeShape;
  bool get useLogoValue => _useLogo;
  String? get logoPathValue => _logoPath;
  bool get useGradientValue => _useGradient;
  List<Color> get gradientColorsValue => _gradientColors;

  Timer? _debounceTimer;

  QRScreenController() {
    inputController.addListener(_onInputChanged);
    isPremiumNotifier.addListener(loadTemplate);
    loadTemplate();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    inputController.removeListener(_onInputChanged);
    isPremiumNotifier.removeListener(loadTemplate);
    inputController.dispose();
    qrDataNotifier.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      qrDataNotifier.value = inputController.text.trim();
    });
  }

  // Setters with notifyListeners
  set qrColor(Color value) { _qrColor = value; notifyListeners(); }
  set bgColor(Color value) { _bgColor = value; notifyListeners(); }
  set qrShape(String value) { _qrShape = value; notifyListeners(); }
  set qrEyeShape(String value) { _qrEyeShape = value; notifyListeners(); }
  set useGradient(bool value) { _useGradient = value; notifyListeners(); }
  set gradientColors(List<Color> value) { _gradientColors = value; notifyListeners(); }

  void setLogo(String? path) {
    if (_logoPath != null && path != _logoPath) {
      FileImage(File(_logoPath!)).evict();
    }
    _logoPath = path;
    _useLogo = path != null;
    notifyListeners();
  }

  Future<void> applyPlatformLogo(PlatformModel platform) async {
    _isLogoLoading = true;
    notifyListeners();
    try {
      final path = await LogoGenerator.saveIconToImage(platform.icon, platform.color);
      
      // Save the platform ID to persist it across restarts
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('qr_template_platform_id', platform.id);
      
      setLogo(path);
    } catch (e) {
      debugPrint("Error applying platform logo: $e");
    } finally {
      _isLogoLoading = false;
      notifyListeners();
    }
  }

  void clearPlatformLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qr_template_platform_id');
    setLogo(null);
  }

  Future<void> loadTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!isPremiumNotifier.value) {
      resetToDefault();
      return;
    }

    final colorVal = prefs.getInt('qr_template_color');
    if (colorVal != null) _qrColor = Color(colorVal);

    _qrShape = prefs.getString('qr_template_shape_str') ?? 'square';
    _qrEyeShape = prefs.getString('qr_template_eye_shape') ?? 'square';
    
    final String? platformId = prefs.getString('qr_template_platform_id');
    if (platformId != null) {
      // Find the platform model and regenerate the logo because temporary files are cleared
      try {
        final platform = AppPlatforms.availablePlatforms.firstWhere((p) => p.id == platformId);
        // We use a safe version of regeneration that doesn't trigger another notifyListeners loop
        final path = await LogoGenerator.saveIconToImage(platform.icon, platform.color);
        _logoPath = path;
        _useLogo = true;
      } catch (e) {
        debugPrint("Error regenerating logo for $platformId: $e");
      }
    } else {
      _logoPath = prefs.getString('qr_template_logo');
      _useLogo = _logoPath != null;
    }

    _useGradient = prefs.getBool('qr_template_use_gradient') ?? false;
    final grad1 = prefs.getInt('qr_template_grad1');
    final grad2 = prefs.getInt('qr_template_grad2');
    if (grad1 != null && grad2 != null) {
      _gradientColors = [Color(grad1), Color(grad2)];
    }
    
    notifyListeners();
  }

  void resetToDefault() {
    _qrColor = Colors.black;
    _bgColor = CupertinoColors.white;
    _qrShape = 'square';
    _qrEyeShape = 'square';
    _useLogo = false;
    _logoPath = null;
    _useGradient = false;
    notifyListeners();
  }

  Future<void> saveTemplate() async {
    HapticService.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('qr_template_color', _qrColor.value);
    await prefs.setString('qr_template_shape_str', _qrShape);
    await prefs.setString('qr_template_eye_shape', _qrEyeShape);
    await prefs.setBool('qr_template_use_gradient', _useGradient);
    await prefs.setInt('qr_template_grad1', _gradientColors[0].value);
    await prefs.setInt('qr_template_grad2', _gradientColors[1].value);

    if (_logoPath != null) {
      await prefs.setString('qr_template_logo', _logoPath!);
    } else {
      await prefs.remove('qr_template_logo');
    }
    
    // Check if there is a platform-specific logo being used
    // We could extend the state to track this properly, but for now we'll rely on the fact that
    // applyPlatformLogo is the main way logos are set.
  }

  bool validateGradientContrast() {
    double avgLuminance = (_gradientColors[0].computeLuminance() + _gradientColors[1].computeLuminance()) / 2;
    double bgLuminance = _bgColor.computeLuminance();
    return (avgLuminance - bgLuminance).abs() > 0.3;
  }
}
