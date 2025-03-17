import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

//Used for picking the required files

class DocumentMediaUtils {
  static final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;

  static Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'xls'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return File(result.files.first.path!);
    }
    return null;
  }

  static Future<File?> captureImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<File?> recordVideo() async {
    final pickedFile = await _imagePicker.pickVideo(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> startRecording(Function(String) onError) async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);
        isRecording = true;
      }
    } catch (e) {
      onError('Failed to start recording: $e');
    }
  }

  Future<File?> stopRecording(Function(String) onError) async {
    try {
      final path = await _audioRecorder.stop();
      isRecording = false;
      return path != null ? File(path) : null;
    } catch (e) {
      onError('Failed to stop recording: $e');
      return null;
    }
  }
}
