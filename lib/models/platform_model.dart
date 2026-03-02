import 'package:flutter/cupertino.dart';

class PlatformModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String inputHint;

  const PlatformModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.inputHint = 'Link veya kullanıcı adı girin...',
  });
}
