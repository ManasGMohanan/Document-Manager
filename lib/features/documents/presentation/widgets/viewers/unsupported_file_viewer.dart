import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class UnsupportedFileViewer extends StatelessWidget {
  final String filePath;

  const UnsupportedFileViewer({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_drive_file,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'Unsupported File Type',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            path.basename(filePath),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              OpenFile.open(filePath);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in External App'),
          ),
        ],
      ),
    );
  }
}
