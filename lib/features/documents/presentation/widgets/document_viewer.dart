import 'package:document_manager/features/documents/presentation/widgets/viewers/audio_player.dart';
import 'package:document_manager/features/documents/presentation/widgets/viewers/image_viewer.dart';
import 'package:document_manager/features/documents/presentation/widgets/viewers/pdf_excel_viewer.dart';
import 'package:document_manager/features/documents/presentation/widgets/viewers/unsupported_file_viewer.dart';
import 'package:document_manager/features/documents/presentation/widgets/viewers/video_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class DocumentViewer extends StatelessWidget {
  final String filePath;
  final String title;
  final String documentId;

  const DocumentViewer({
    super.key,
    required this.filePath,
    required this.title,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //changing the title first letter to capital, as it's an appbar showing that.
        title: Text(
          title.isNotEmpty ? title[0].toUpperCase() + title.substring(1) : '',
        ),
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.pdf':
      case '.xlsx':
      case '.xls':
        return PdfExcelViewer(filePath: filePath, title: title);

      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Hero(
          tag: 'thumbnail-$documentId',
          child: ImageViewer(filePath: filePath),
        );

      case '.mp4':
      case '.mov':
      case '.avi':
        return VideoViewer(filePath: filePath);

      case '.mp3':
      case '.wav':
      case '.aac':
      case '.m4a':
        return AudioPlayerWidget(filePath: filePath);

      default:
        return UnsupportedFileViewer(filePath: filePath);
    }
  }
}
