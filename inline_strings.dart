import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.contains('app_localizations.dart'),
      )
      .toList();

  final appLocFile = File('lib/l10n/app_localizations.dart');
  final appLocContent = await appLocFile.readAsString();

  // Extract all property names and values
  final Map<String, String> translations = {};

  final RegExp regex = RegExp(r"static const String (\w+) = '(.*?)';");
  for (final match in regex.allMatches(appLocContent)) {
    translations[match.group(1)!] = match.group(2)!;
  }

  print('Extracted ${translations.length} translations.');

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // Remove import
    content = content.replaceAll(
      RegExp(r"import\s+'[^']*l10n/app_localizations\.dart';\s*\n"),
      '',
    );

    // Replace method calls (welcome, addPlatformLink)
    if (content.contains('AppLocalizations.welcome')) {
      content = content.replaceAllMapped(
        RegExp(r"AppLocalizations\.welcome\((.*?)\)"),
        (m) {
          modified = true;
          return "'Merhaba \${${m.group(1)}}'";
        },
      );
    }

    if (content.contains('AppLocalizations.addPlatformLink')) {
      content = content.replaceAllMapped(
        RegExp(r"AppLocalizations\.addPlatformLink\((.*?)\)"),
        (m) {
          modified = true;
          return "'\${${m.group(1)}} Linki Ekle'";
        },
      );
    }

    // Replace properties
    for (final entry in translations.entries) {
      final key = 'AppLocalizations.${entry.key}';
      if (content.contains(key)) {
        content = content.replaceAll(
          key,
          "'${entry.value.replaceAll(r"\'", "'")}'",
        );
        modified = true;
      }
    }

    if (modified) {
      await file.writeAsString(content);
      print('Updated: ${file.path}');
    }
  }
}
