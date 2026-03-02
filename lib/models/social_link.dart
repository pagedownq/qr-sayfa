import 'package:flutter/cupertino.dart';

class SocialLink {
  final String platform;
  final String platformId;
  final IconData icon;
  final Color color;
  final String url;
  final String category; // 'personal' or 'business'
  final Color? qrColor;
  final Color? qrBgColor;
  final String? qrShape;
  final String? qrEyeShape;
  final String? qrLogoPath;
  final String? qrLogoShape; // 'square' or 'circle'

  SocialLink({
    required this.platform,
    required this.platformId,
    required this.icon,
    required this.color,
    required this.url,
    this.category = 'personal',
    this.qrColor,
    this.qrBgColor,
    this.qrShape,
    this.qrEyeShape,
    this.qrLogoPath,
    this.qrLogoShape,
  });

  SocialLink copyWith({
    String? platform,
    String? platformId,
    IconData? icon,
    Color? color,
    String? url,
    String? category,
    Color? qrColor,
    Color? qrBgColor,
    String? qrShape,
    String? qrEyeShape,
    String? qrLogoPath,
    String? qrLogoShape,
  }) => SocialLink(
    platform: platform ?? this.platform,
    platformId: platformId ?? this.platformId,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    url: url ?? this.url,
    category: category ?? this.category,
    qrColor: qrColor ?? this.qrColor,
    qrBgColor: qrBgColor ?? this.qrBgColor,
    qrShape: qrShape ?? this.qrShape,
    qrEyeShape: qrEyeShape ?? this.qrEyeShape,
    qrLogoPath: qrLogoPath ?? this.qrLogoPath,
    qrLogoShape: qrLogoShape ?? this.qrLogoShape,
  );

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'platformId': platformId,
    'iconCode': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'colorValue': color.toARGB32(),
    'url': url,
    'category': category,
    'qrColorValue': qrColor?.toARGB32(),
    'qrBgColorValue': qrBgColor?.toARGB32(),
    'qrShape': qrShape,
    'qrEyeShape': qrEyeShape,
    'qrLogoPath': qrLogoPath,
    'qrLogoShape': qrLogoShape,
  };

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
    platform: json['platform'] as String? ?? 'Diğer',
    platformId: json['platformId'] as String? ?? 'other',
    icon: IconData(
      json['iconCode'] as int? ?? 0xe232, // Default to generic QR icon if missing
      fontFamily: json['iconFontFamily'] as String?,
      fontPackage: json['iconFontPackage'] as String?,
    ),
    color: Color(json['colorValue'] as int? ?? 0xFF000000),
    url: json['url'] as String? ?? '',
    category: json['category'] as String? ?? 'personal',
    qrColor: json['qrColorValue'] != null ? Color(json['qrColorValue'] as int) : null,
    qrBgColor: json['qrBgColorValue'] != null ? Color(json['qrBgColorValue'] as int) : null,
    qrShape: json['qrShape'] as String?,
    qrEyeShape: json['qrEyeShape'] as String?,
    qrLogoPath: json['qrLogoPath'] as String?,
    qrLogoShape: json['qrLogoShape'] as String?,
  );
}
