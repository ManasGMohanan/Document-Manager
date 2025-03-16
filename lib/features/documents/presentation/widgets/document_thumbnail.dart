// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:document_manager/core/utils/file/file_utils.dart';

// A reusable widget that displays a thumbnail for a document.
// It first attempts to load a generated thumbnail using DMFileUtils.getThumbnail.
// If a thumbnail exists, it displays it used in a Hero for smooth transitions, check working.
// Otherwise, it shows a fallback thumbnail based on the file type.
class DocumentThumbnail extends StatelessWidget {
  final String filePath;
  final String documentId;
  final double width;
  final double height;
  final BoxFit fit;

  const DocumentThumbnail({
    super.key,
    required this.filePath,
    required this.documentId,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
  });

  // when no thumbnail is available.
  Widget _buildFallbackThumbnail(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DMFileUtils.getFileColor(filePath).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          DMFileUtils.getFileIcon(filePath),
          size: 40,
          color: DMFileUtils.getFileColor(filePath),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: DMFileUtils.getThumbnail(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                // child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Hero(
            tag: 'thumbnail-$documentId',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                snapshot.data!,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackThumbnail(context),
              ),
            ),
          );
        }
        return _buildFallbackThumbnail(context);
      },
    );
  }
}
