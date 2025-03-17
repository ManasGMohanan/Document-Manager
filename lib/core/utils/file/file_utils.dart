import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

class DMFileUtils {
  static const uuid = Uuid();
  static final _thumbnailLock = Lock();
  static const int _thumbnailSize = 300;

  static Future<String> saveFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${uuid.v4()}${path.extension(file.path)}';
    final savedFile = await file.copy('${appDir.path}/$fileName');
    return savedFile.path;
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // delete thumbnail too if exists
    final thumbnailPath = await _getThumbnailPath(filePath);
    final thumbnailFile = File(thumbnailPath);
    if (await thumbnailFile.exists()) {
      await thumbnailFile.delete();
    }
  }

  static String getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return 'PDF';
      case '.xlsx':
      case '.xls':
        return 'Excel';
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return 'Image';
      case '.mp4':
      case '.mov':
      case '.avi':
        return 'Video';
      case '.mp3':
      case '.wav':
      case '.aac':
      case '.m4a':
        return 'Audio';
      default:
        return 'Other';
    }
  }

  static IconData getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.xlsx':
      case '.xls':
        return Icons.table_chart;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Icons.videocam;
      case '.mp3':
      case '.wav':
      case '.aac':
      case '.m4a':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  static Color getFileColor(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Colors.red.shade400;
      case '.xlsx':
      case '.xls':
        return Colors.green.shade400;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Colors.blue.shade400;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Colors.purple.shade400;
      case '.mp3':
      case '.wav':
      case '.aac':
      case '.m4a':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  static String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) {
          return '$bytes B';
        } else if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else if (bytes < 1024 * 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else {
          return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
        }
      }
    } catch (e) {
      // check error
    }
    return 'Unknown size';
  }

  // Get the path where the thumbnail should be stored
  static Future<String> _getThumbnailPath(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${appDir.path}/thumbnails');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }

    final fileHash = path.basename(filePath).split('.').first;
    return '${thumbnailDir.path}/$fileHash.jpg';
  }

  // Generate a thumbnail for an image file used image compress package
  static Future<File?> _generateImageThumbnail(
      String filePath, String thumbnailPath) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        thumbnailPath,
        quality: 70,
        minWidth: _thumbnailSize,
        minHeight: _thumbnailSize,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      return null;
    }
  }

  // fixed issue
  // Generate a thumbnail for a video file used get thumbnail video package
  static Future<File?> _generateVideoThumbnail(
      String filePath, String thumbnailPath) async {
    try {
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: _thumbnailSize,
        quality: 50,
      );
      final file = File(thumbnailPath);
      await file.writeAsBytes(thumbnailBytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  // thumbnail for a PDF file, used first page render using pdf render package
  static Future<File?> _generatePdfThumbnail(
      String filePath, String thumbnailPath) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      final page = await document.getPage(1);

      final pageWidth = page.width;
      final pageHeight = page.height;

      final aspectRatio = pageWidth / pageHeight;
      int width, height;

      if (aspectRatio > 1) {
        width = _thumbnailSize;
        height = (_thumbnailSize / aspectRatio).round();
      } else {
        height = _thumbnailSize;
        width = (_thumbnailSize * aspectRatio).round();
      }

      final pageImage = await page.render(
        width: width,
        height: height,
      );

      final image = await pageImage.createImageDetached();
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final byteList = bytes!.buffer.asUint8List();

      //fixed issue
      final file = File(thumbnailPath);
      await file.writeAsBytes(byteList);

      // Close pdf
      document.dispose();

      return file;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> getThumbnail(String filePath) async {
    // Use a lock to prevent multiple thumbnail generations for the same file, with synchronized package
    return _thumbnailLock.synchronized(() async {
      try {
        final thumbnailPath = await _getThumbnailPath(filePath);
        final thumbnailFile = File(thumbnailPath);

        // If thumbnail already exists, return it
        if (await thumbnailFile.exists()) {
          return thumbnailFile;
        }

        // thumbnail based on file type, using mime package
        final extension = path.extension(filePath).toLowerCase();
        final mimeType = lookupMimeType(filePath);

        if (mimeType?.startsWith('image/') ?? false) {
          return await _generateImageThumbnail(filePath, thumbnailPath);
        } else if (extension == '.pdf') {
          return await _generatePdfThumbnail(filePath, thumbnailPath);
        } else if (['.mp4', '.mov', '.avi'].contains(extension)) {
          return await _generateVideoThumbnail(filePath, thumbnailPath);
        } else {
          // Buggy code
          // return await _generateGenericThumbnail(filePath, thumbnailPath);
        }
      } catch (e) {
        return null;
      }
      return null;
    });
  }
}
