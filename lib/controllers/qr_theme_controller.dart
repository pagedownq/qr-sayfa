import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class QRThemeController extends ChangeNotifier {
  Color _qrColor = Colors.black;
  Color _bgColor = CupertinoColors.white;
  String _qrShape = 'square';
  String _qrEyeShape = 'square';
  bool _useLogo = false; 
  String? _logoPath;
  bool _useGradient = false;
  List<Color> _gradientColors = List.from(AppTheme.defaultGradient);

  // Getters
  Color get qrColor => _qrColor;
  Color get bgColor => _bgColor;
  String get qrShape => _qrShape;
  String get qrEyeShape => _qrEyeShape;
  bool get useLogo => _useLogo;
  String? get logoPath => _logoPath;
  bool get useGradient => _useGradient;
  List<Color> get gradientColors => _gradientColors;

  Future<void> loadTemplate(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!isPremium) {
      resetToDefault();
      return;
    }

    final colorVal = prefs.getInt('qr_template_color');
    if (colorVal != null) _qrColor = Color(colorVal);
    
    _qrShape = prefs.getString('qr_template_shape_str') ?? 'square';
    _qrEyeShape = prefs.getString('qr_template_eye_shape') ?? 'square';
    
    _logoPath = prefs.getString('qr_template_logo');
    _useLogo = _logoPath != null;

    _useGradient = prefs.getBool('qr_template_use_gradient') ?? false;
    final grad1 = prefs.getInt('qr_template_grad1');
    final grad2 = prefs.getInt('qr_template_grad2');
    if (grad1 != null && grad2 != null) {
      _gradientColors = [Color(grad1), Color(grad2)];
    }
    
    notifyListeners();
  }

  Future<void> saveTemplate() async {
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

  void setQrColor(Color color) {
    _qrColor = color;
    _useGradient = false;
    notifyListeners();
  }

  void setBgColor(Color color) {
    _bgColor = color;
    notifyListeners();
  }

  void setQrShape(String shape) {
    _qrShape = shape;
    notifyListeners();
  }

  void setQrEyeShape(String shape) {
    _qrEyeShape = shape;
    notifyListeners();
  }

  void setLogoPath(String? path) {
    _logoPath = path;
    _useLogo = path != null;
    notifyListeners();
  }

  void setGradient(List<Color> colors) {
    _gradientColors = colors;
    _useGradient = true;
    notifyListeners();
  }

  void clearGradient() {
    _useGradient = false;
    notifyListeners();
  }
}
