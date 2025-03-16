import 'dart:io';
import 'package:document_manager/core/common_widgets/section_header_widget.dart';
import 'package:document_manager/core/utils/constants/text_strings.dart';
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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: DMTexts.fileSelectionHeader,
            icon: Icons.insert_drive_file,
          ),
          const SizedBox(height: 16),
          if (selectedFile != null)
            _buildSelectedFileCard(context)
          else
            _buildNoFileCard(context),
          const SizedBox(height: 16),
          Text(
            DMTexts.addDocumentBy,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildFileSelectionOptions(context),
          if (mediaUtils.isRecording) ...[
            const SizedBox(height: 16),
            _buildRecordingIndicator(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedFileCard(BuildContext context) {
    final fileName = selectedFile!.path.split('/').last;
    final fileSize = (selectedFile!.lengthSync() / 1024).toStringAsFixed(2);
    final fileIcon = DMFileUtils.getFileIcon(selectedFile!.path);
    final fileColor = DMFileUtils.getFileColor(selectedFile!.path);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: fileColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              fileIcon,
              size: 30,
              color: fileColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: $fileSize KB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade400),
            onPressed: onRemoveFile,
            tooltip: 'Remove file',
          ),
        ],
      ),
    );
  }

  Widget _buildNoFileCard(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: Colors.grey.shade500,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              DMTexts.noFileText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionOptions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                context,
                icon: Icons.attach_file,
                label: 'File',
                color: Colors.blue,
                onPressed: onPickFile,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOptionButton(
                context,
                icon: Icons.camera_alt,
                label: 'Camera',
                color: Colors.green,
                onPressed: onCaptureImage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                context,
                icon: Icons.videocam,
                label: 'Video',
                color: Colors.purple,
                onPressed: onRecordVideo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOptionButton(
                context,
                icon: mediaUtils.isRecording ? Icons.stop : Icons.mic,
                label: mediaUtils.isRecording ? 'Stop' : 'Audio',
                color: mediaUtils.isRecording ? Colors.red : Colors.orange,
                onPressed:
                    mediaUtils.isRecording ? onStopRecording : onStartRecording,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPulsatingCircle(),
          const SizedBox(width: 12),
          Text(
            'Recording in progress...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsatingCircle() {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
