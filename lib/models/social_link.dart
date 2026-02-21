import 'package:flutter/cupertino.dart';

class SocialLink {
  final String platform;
  final IconData icon;
  final Color color;
  final String url;
  final String category; // 'personal' or 'business'

  SocialLink({
    required this.platform,
    required this.icon,
    required this.color,
    required this.url,
    this.category = 'personal',
  });

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'iconCode': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'colorValue': color.toARGB32(),
    'url': url,
    'category': category,
  };

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
    platform: json['platform'] as String,
    icon: IconData(
      json['iconCode'] as int,
      fontFamily: json['iconFontFamily'] as String?,
      fontPackage: json['iconFontPackage'] as String?,
    ),
    color: Color(json['colorValue'] as int),
    url: json['url'] as String,
    category: json['category'] as String? ?? 'personal',
  );
}
