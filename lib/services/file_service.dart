import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_file.dart';

class FileService {
  Future<VideoFile?> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      return VideoFile.fromFile(file);
    }

    return null;
  }

  Future<String?> pickOutputDirectory() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    return directory;
  }

  Future<String> getDefaultOutputPath(VideoFile input, String format) async {
    final directory = await getApplicationDocumentsDirectory();
    final inputName = input.name.split('.').first;
    final outputName = '${inputName}_compressed.$format';
    return '${directory.path}/$outputName';
  }

  Future<String> generateThumbnail(String videoPath, String thumbnailPath) async {
    // This would use FFmpeg to generate thumbnail
    // For now, return the video path as placeholder
    return videoPath;
  }

  Future<List<String>> getRecentFiles() async {
    // This would load from shared preferences
    return [];
  }

  Future<void> saveRecentFile(String path) async {
    // This would save to shared preferences
  }
}