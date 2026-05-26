import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressService {
  static Future<List<int>> compressImageBytes(
    File sourceFile, {
    int minWidth = 1024,
    int minHeight = 1024,
    int quality = 80,
    int? maxBytes,
  }) async {
    int currentQuality = quality;
    int attempt = 0;

    while (attempt < 4) {
      final bytes = await FlutterImageCompress.compressWithFile(
        sourceFile.absolute.path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: currentQuality,
        format: CompressFormat.jpeg,
      );

      if (bytes == null) {
        break;
      }

      if (maxBytes == null || bytes.length <= maxBytes) {
        return bytes;
      }

      currentQuality = (currentQuality - 15).clamp(40, 80);
      attempt += 1;
    }

    return await sourceFile.readAsBytes();
  }

  static Future<File> compressImageFile(
    File sourceFile, {
    int minWidth = 1024,
    int minHeight = 1024,
    int quality = 80,
    int? maxBytes,
  }) async {
    final tempDir = await getTemporaryDirectory();
    File? compressedFile;
    int currentQuality = quality;
    int attempt = 0;

    while (attempt < 4) {
      final targetPath =
          '${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}_$attempt.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: currentQuality,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        break;
      }

      compressedFile = File(result.path);
      if (maxBytes == null) {
        return compressedFile;
      }

      final size = await compressedFile.length();
      if (size <= maxBytes) {
        return compressedFile;
      }

      // too large, try smaller quality
      currentQuality = (currentQuality - 15).clamp(40, 80);
      attempt += 1;
    }

    return compressedFile ?? sourceFile;
  }
}
