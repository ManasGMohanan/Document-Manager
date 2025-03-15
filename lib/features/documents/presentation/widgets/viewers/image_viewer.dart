import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String filePath;

  const ImageViewer({
    super.key,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(File(filePath)),
      ),
    );
  }
}
