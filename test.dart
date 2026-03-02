import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() {
  final view = PrettyQrView.data(
    data: 'test',
    decoration: PrettyQrDecoration(
      shape: PrettyQrSmoothSymbol(
        color: Colors.red,
        roundFactor: 0.5,
      ),
      image: PrettyQrDecorationImage(
        image: AssetImage('x'),
        position: PrettyQrDecorationImagePosition.embedded,
      ),
    ),
  );
}
