import 'dart:io';
import 'package:document_manager/core/utils/document_media/document_media.dart';
import 'package:document_manager/core/utils/file/file_utils.dart';
import 'package:flutter/material.dart';

class DocumentFileSelection extends StatelessWidget {
  final File? selectedFile;
  final DocumentMediaUtils mediaUtils;
  final VoidCallback onPickFile;
  final VoidCallback onCaptureImage;
  final VoidCallback onRecordVideo;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onRemoveFile;

  const DocumentFileSelection({
    super.key,
    required this.selectedFile,
    required this.mediaUtils,
    required this.onPickFile,
    required this.onCaptureImage,
    required this.onRecordVideo,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document File',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (selectedFile != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    DMFileUtils.getFileIcon(selectedFile!.path),
                    size: 40,
                    color: DMFileUtils.getFileColor(selectedFile!.path),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedFile!.path.split('/').last,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${(selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onRemoveFile,
                  ),
                ],
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No file selected')),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach File'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            ElevatedButton.icon(
              onPressed: onCaptureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Image'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: onRecordVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Record Video'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
            ElevatedButton.icon(
              onPressed:
                  mediaUtils.isRecording ? onStopRecording : onStartRecording,
              icon: Icon(mediaUtils.isRecording ? Icons.stop : Icons.mic),
              label: Text(
                  mediaUtils.isRecording ? 'Stop Recording' : 'Record Audio'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    mediaUtils.isRecording ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
        if (mediaUtils.isRecording) ...[
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const Icon(Icons.graphic_eq, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Recording in progress...',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
