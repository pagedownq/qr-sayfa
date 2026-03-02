import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String urlString) async {
  final Uri uri = Uri.parse(urlString);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Android 11+ cihazlarda <queries> tanımlanmadığı için canLaunchUrl false dönse bile 
      // launchUrl çalışabilir (özellikle tel:, mailto: gibi scheme'ler için).
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        debugPrint('Could not launch $urlString');
      }
    }
  } catch (e) {
    debugPrint('Exception while launching $urlString: $e');
  }
}
