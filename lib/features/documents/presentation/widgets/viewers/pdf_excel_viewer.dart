import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

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
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            if (_isReady)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            PDFView(
              filePath: widget.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
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
              onViewCreated: (PDFViewController controller) {
                // You can store the controller for future use if needed
              },
              onPageChanged: (page, total) {
                setState(() {
                  _currentPage = page!;
                });
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              onPageError: (page, error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error on page $page: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
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
      // Excel viewer (unchanged)
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.table_chart,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              Text(
                'Excel Document',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                path.basename(widget.filePath),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  OpenFile.open(widget.filePath);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in External App'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
