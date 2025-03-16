// ignore_for_file: deprecated_member_use

import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

//used for both pdf and excel, pdf page no also
class PdfExcelViewer extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfExcelViewer({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfExcelViewer> createState() => _PdfExcelViewerState();
}

class _PdfExcelViewerState extends State<PdfExcelViewer> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    final extension = path.extension(widget.filePath).toLowerCase();

    if (extension == '.pdf') {
      return Scaffold(
        body: Stack(
          children: [
            PDFView(
              filePath: widget.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages!;
                  _isReady = true;
                });
              },
              onPageChanged: (page, total) {
                setState(() {
                  _currentPage = page!;
                });
              },
              onError: (error) {
                DMAppMethods.showSnackBar(
                    context, 'Error: $error', DMColors.error);
              },
              onPageError: (page, error) {
                DMAppMethods.showSnackBar(
                    context, 'Error: $error', DMColors.error);
              },
            ),
            if (_isReady)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Page ${_currentPage + 1} of $_totalPages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      // Excel viewer externl
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.table_chart,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Excel Document',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            path.basename(widget.filePath),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Excel files need to be opened in a spreadsheet app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              OpenFile.open(widget.filePath);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in External App'),
          ),
        ],
      );
    }
  }
}
