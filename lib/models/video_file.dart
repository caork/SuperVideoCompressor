import 'dart:io';

class VideoFile {
  final File file;
  final String name;
  final String path;
  final int size;
  final Duration duration;
  final int width;
  final int height;
  final String codec;
  final double frameRate;
  final int bitrate;

  VideoFile({
    required this.file,
    required this.name,
    required this.path,
    required this.size,
    required this.duration,
    required this.width,
    required this.height,
    required this.codec,
    required this.frameRate,
    required this.bitrate,
  });

  factory VideoFile.fromFile(File file) {
    // This would be populated by FFprobe or similar
    // For now, dummy values
    return VideoFile(
      file: file,
      name: file.path.split('/').last,
      path: file.path,
      size: file.lengthSync(),
      duration: const Duration(minutes: 1),
      width: 1920,
      height: 1080,
      codec: 'h264',
      frameRate: 30.0,
      bitrate: 5000000,
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}