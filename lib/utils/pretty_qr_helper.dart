import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PrettyQrHelper {
  static PrettyQrDecoration getDecoration({
    required String shape,
    required String eyeShape,
    required Color color,
    ImageProvider? image,
  }) {
    // Generate body shape
    PrettyQrShape bodyShape = _buildShape(shape, color);
    
    // Generate eye shape
    PrettyQrShape finderPatternShape = _buildShape(eyeShape, color);

    // Combine them using PrettyQrShape.custom
    final combinedShape = PrettyQrShape.custom(
      bodyShape,
      finderPattern: finderPatternShape,
    );

    return PrettyQrDecoration(
      shape: combinedShape,
      image: image != null
          ? PrettyQrDecorationImage(
              image: image, 
              position: PrettyQrDecorationImagePosition.embedded,
            )
          : null,
    );
  }

  static PrettyQrShape _buildShape(String shapeStr, Color color) {
    switch (shapeStr) {
      case 'circle':
      case 'dots':
        return PrettyQrSmoothSymbol(color: color, roundFactor: 1.0);
      case 'rounded':
        return PrettyQrSmoothSymbol(color: color, roundFactor: 0.5);
      case 'square':
      default:
        return PrettyQrSmoothSymbol(color: color, roundFactor: 0.0);
    }
  }
}
