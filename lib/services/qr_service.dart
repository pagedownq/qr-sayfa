import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result object for QR operations to provide context for failure or success.
class QRServiceResult {
  final bool success;
  final String? message;
  final Uint8List? data;

  const QRServiceResult({required this.success, this.message, this.data});

  factory QRServiceResult.success([Uint8List? data]) => QRServiceResult(success: true, data: data);
  factory QRServiceResult.error(String message) => QRServiceResult(success: false, message: message);
}

class QRService {
  /// Captures a [RepaintBoundary] as a [Uint8List] image bytes with safety checks.
  static Future<QRServiceResult> captureFromBoundary(GlobalKey boundaryKey, {double pixelRatio = 3.0}) async {
    try {
      final RenderRepaintBoundary? boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) return QRServiceResult.error("Görsel yakalama alanı bulunamadı.");
      
      // 1. Rendering Safeblocks: Ensure boundary is ready and painted
      if (!boundary.hasSize) {
         return QRServiceResult.error("Görsel henüz oluşturulmadı (Boyut hatası).");
      }

      if (boundary.debugNeedsPaint) {
        // Wait for the next frame if painting is still pending
        final Completer<void> completer = Completer<void>();
        SchedulerBinding.instance.addPostFrameCallback((_) => completer.complete());
        await completer.future;
      }

      // 2. Memory Management: Pixel ratio safety & disposal
      final ui.Image uiImage = await boundary.toImage(pixelRatio: pixelRatio);
      
      try {
        final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return QRServiceResult.error("Görsel verisi oluşturulamadı.");
        
        return QRServiceResult.success(byteData.buffer.asUint8List());
      } finally {
        // Mandatory disposal to prevent RAM bloating, especially with high pixelRatio
        uiImage.dispose();
      }
    } catch (e) {
      debugPrint('QRService Capture Error: $e');
      return QRServiceResult.error("Görsel yakalanırken bir hata oluştu: $e");
    }
  }

  /// Saves image bytes to the gallery with updated permission handling.
  static Future<QRServiceResult> saveToGallery(Uint8List imageBytes) async {
    try {
      // 3. Updated Permission Handling (Android 13+ & iOS)
      bool hasPermission = false;
      if (Platform.isAndroid) {
         // Android 13+ requires photos permission, older versions require storage
         final status = await Permission.photos.request();
         if (status.isGranted || status.isLimited) {
            hasPermission = true;
         } else if (status.isPermanentlyDenied) {
            return QRServiceResult.error("Galeri izni kalıcı olarak reddedildi. Ayarlardan izin verebilirsiniz.");
         }
      } else {
        // iOS
        final status = await Permission.photos.request();
        hasPermission = status.isGranted || status.isLimited;
      }

      if (!hasPermission) return QRServiceResult.error("Galeriye kaydetmek için izin verilmesi gerekiyor.");

      await Gal.putImageBytes(
        imageBytes,
        name: "Qurio_QR_${DateTime.now().millisecondsSinceEpoch}",
      );
      return QRServiceResult.success();
    } catch (e) {
      debugPrint('QRService Save Error: $e');
      return QRServiceResult.error("Galeriye kaydedilemedi: $e");
    }
  }

  /// Generates a PDF (300 DPI) from image bytes, shares it, and cleans up.
  static Future<QRServiceResult> saveAndSharePDF(Uint8List imageBytes, {String? text}) async {
    File? tempFile;
    try {
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);

      // 4. PDF Optimization: Using DPI control for professional print standards (300 DPI)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pdfImage, 
                fit: pw.BoxFit.contain,
                dpi: 300, // Print standard DPI
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      tempFile = File('${output.path}/Qurio_Export_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(await pdf.save(), flush: true);

      // 5. File System Cleanup: Run cleanup after sharing
      final ShareResult shareResult = await Share.shareXFiles(
        [XFile(tempFile.path)], 
        text: text ?? 'Qurio Pro: Yüksek Kalite QR Kod PDF'
      );

      // If sharing is successful or dismissed, we can trigger cleanup
      _cleanupTempFile(tempFile);
      
      return QRServiceResult.success();
    } catch (e) {
      debugPrint('QRService PDF Error: $e');
      if (tempFile != null) _cleanupTempFile(tempFile);
      return QRServiceResult.error("PDF oluşturulamadı veya paylaşılamadı: $e");
    }
  }

  static void _cleanupTempFile(File file) {
    Future.delayed(const Duration(minutes: 1), () async {
      try {
        if (await file.exists()) {
          await file.delete();
          debugPrint("QRService: Temp file cleaned - ${file.path}");
        }
      } catch (e) {
        debugPrint("QRService: Cleanup failed (harmless) - $e");
      }
    });
  }

  /// Dynamically determines ideal pixelRatio for PDF based on density.
  static double getIdealPdfPixelRatio(BuildContext context) {
    // 6. Ideal Pixel Ratio Mechanism:
    // If devicePixelRatio < 2.0 (older devices), we upsample more to maintain quality.
    final double density = MediaQuery.of(context).devicePixelRatio;
    if (density < 2.0) {
      return 6.0; // Higher upsampling for low-res screens
    }
    return 8.0; // High quality for modern screens
  }
}
