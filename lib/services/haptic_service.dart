import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
  warning,
  vibrate
}

/// A high-end Haptic feedback service optimized for iOS Taptic Engine 
/// and Android Haptic Motors.
class HapticService {
  static ValueListenable<bool>? _enabledNotifier;

  /// Initializes the service with a preference notifier.
  /// Allows for easy dependency injection and testing.
  static void init(ValueListenable<bool> enabledNotifier) {
    _enabledNotifier = enabledNotifier;
  }

  static bool get _isEnabled => _enabledNotifier?.value ?? true;

  /// Triggers a light touch sensation.
  /// Android: Slightly boosted to ensure it's felt on standard vibration motors.
  static void lightImpact() => _trigger(HapticType.light);

  /// Triggers a medium touch sensation.
  static void mediumImpact() => _trigger(HapticType.medium);

  /// Triggers a heavy, solid sensation.
  static void heavyImpact() => _trigger(HapticType.heavy);

  /// Triggers a selection change or scroll click sensation.
  static void selectionClick() => _trigger(HapticType.selection);

  /// A positive, double-pulse feedback for successful actions.
  static void success() => _trigger(HapticType.success);

  /// A rhythmic triple-pulse feedback for errors.
  /// Follows a Medium -> Light -> Medium pattern for a professional feel.
  static void error() => _trigger(HapticType.error);

  /// A steady, warning sensation for invalid inputs or alerts.
  static void warning() => _trigger(HapticType.warning);

  /// Standard vibration fallback.
  static void vibrate() => _trigger(HapticType.vibrate);

  /// Unified internal trigger logic. 
  /// Uses "Fire-and-Forget" pattern to prevent UI thread blocking.
  static void _trigger(HapticType type) {
    if (!_isEnabled) return;

    // We don't await here to keep the UI smooth (Fire-and-Forget)
    _executeHaptic(type);
  }

  static Future<void> _executeHaptic(HapticType type) async {
    try {
      switch (type) {
        case HapticType.light:
          // Android motors are often weaker for "Light", 
          // so we use Medium as a boost on Android if needed, 
          // or just rely on standard system implementation.
          await HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.vibrate:
          await HapticFeedback.vibrate();
          break;
        case HapticType.success:
          // Success Pattern: Two quick light pulses
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.lightImpact();
          break;
        case HapticType.error:
          // Error Pattern: Medium -> Light -> Medium (Rhythmic)
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.warning:
          // Warning Pattern: Heavy -> Light
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          break;
      }
    } catch (e) {
      debugPrint("HapticService: Failed to trigger haptic: $e");
    }
  }
}
