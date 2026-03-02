import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogoGenerator {
  /// Generates a branded logo from an icon to be placed in QR codes.
  /// 
  /// [size] : The pixel dimensions of the logo.
  /// [shape] : The background shape ([BoxShape.circle] or [BoxShape.rectangle]).
  /// [borderRadius] : Corner radius if the shape is a rectangle.
  static Future<String> saveIconToImage(
    IconData icon, 
    Color backgroundColor, {
    double size = 150.0,
    BoxShape shape = BoxShape.circle,
    double borderRadius = 24.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);
    
    try {
      // 1. High-Quality Rendering Configuration
      final ui.Paint paint = ui.Paint()
        ..color = backgroundColor
        ..isAntiAlias = true // Smooth edges
        ..filterQuality = ui.FilterQuality.high;

      // 2. Draw Background Shape
      if (shape == BoxShape.circle) {
        canvas.drawCircle(ui.Offset(size / 2, size / 2), size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size, size),
            Radius.circular(borderRadius),
          ),
          paint,
        );
      }

      // 3. Icon Rendering with Font Safety
      final bool isBackgroundLight = backgroundColor.computeLuminance() > 0.5;
      final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size * 0.55,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: isBackgroundLight ? Colors.black : Colors.white,
        ),
      );

      // Layout and Font Loading Validation
      textPainter.layout();
      if (textPainter.width == 0) {
        // If font isn't ready yet, wait briefly and retry
        await Future.delayed(const Duration(milliseconds: 100));
        textPainter.layout();
      }

      textPainter.paint(
        canvas, 
        ui.Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2)
      );

      // 4. Transform to ui.Image
      final ui.Image image = await pictureRecorder.endRecording().toImage(
        size.toInt(), 
        size.toInt()
      );
      
      try {
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw Exception("LogoGenerator: ByteData generation failed.");
        }
        
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // 5. Storage Management: Reuse single file or cleanup old ones
        final Directory tempDir = await getTemporaryDirectory();
        
        // Cleanup phase: Remove any existing temp logos to prevent storage bloat
        try {
          final List<FileSystemEntity> existingFiles = tempDir.listSync();
          for (var entity in existingFiles) {
            if (entity is File && entity.path.contains('qurio_temp_logo_')) {
              await entity.delete();
            }
          }
        } catch (e) {
          debugPrint("LogoGenerator: Cleanup warning: $e");
        }

        // Use a unique name for the current session's logo to avoid ImageProvider cache issues
        final String fileName = 'qurio_temp_logo_${DateTime.now().millisecondsSinceEpoch}.png';
        final File file = File('${tempDir.path}/$fileName');
        
        await file.writeAsBytes(pngBytes, flush: true);
        return file.path;
      } finally {
        // 6. Memory Management: Mandatory disposal of image
        image.dispose();
      }
    } catch (e) {
      debugPrint("LogoGenerator Error: $e");
      throw Exception("LogoGenerator failed to create logo: $e");
    }
  }
}
