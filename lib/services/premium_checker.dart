import '../utils/app_state.dart';

/// Kullanıcının Premium yetkilerini merkezi olarak kontrol eden servis.
/// UI içinde anlık değişimleri yakalamak için isPremiumNotifier dinlenir.
class PremiumChecker {
  static bool get isPremium {
    return isPremiumNotifier.value;
  }
}
