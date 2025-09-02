import 'dart:async';
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import '../models/video_file.dart';
import '../models/compression_settings.dart';
import '../models/hardware_info.dart';

class CompressionService {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
  final FlutterFFprobe _ffprobe = FlutterFFprobe();

  Future<VideoFile> getVideoInfo(File file) async {
    final info = await _ffprobe.getMediaInformation(file.path);

    final streams = info['streams'] as List?;
    final videoStream = streams?.firstWhere(
      (stream) => stream['codec_type'] == 'video',
      orElse: () => null,
    );

    final format = info['format'] as Map?;
    final duration = double.tryParse(format?['duration'] ?? '0') ?? 0;
    final size = int.tryParse(format?['size'] ?? '0') ?? 0;

    return VideoFile(
      file: file,
      name: file.path.split('/').last,
      path: file.path,
      size: size,
      duration: Duration(seconds: duration.toInt()),
      width: int.tryParse(videoStream?['width']?.toString() ?? '0') ?? 0,
      height: int.tryParse(videoStream?['height']?.toString() ?? '0') ?? 0,
      codec: videoStream?['codec_name'] ?? 'unknown',
      frameRate: double.tryParse(videoStream?['r_frame_rate']?.split('/')[0] ?? '30') ?? 30.0,
      bitrate: int.tryParse(videoStream?['bit_rate'] ?? '0') ?? 0,
    );
  }

  Future<String> buildFFmpegCommand(VideoFile input, CompressionSettings settings, String outputPath) async {
    final command = <String>[];

    // Input
    command.addAll(['-i', input.path]);

    // Hardware acceleration
    if (settings.hardwareAcceleration != HardwareAcceleration.none) {
      command.addAll(['-hwaccel', settings.hardwareAccelString]);
    }

    // Video codec
    command.addAll(['-c:v', settings.videoCodecString]);

    // Video settings
    if (settings.bitrate != null) {
      command.addAll(['-b:v', '${settings.bitrate!.toInt()}k']);
    }

    if (settings.width != null && settings.height != null) {
      command.addAll(['-vf', 'scale=${settings.width}:${settings.height}']);
    }

    if (settings.frameRate != null) {
      command.addAll(['-r', settings.frameRate!.toString()]);
    }

    // Audio codec
    command.addAll(['-c:a', settings.audioCodecString]);

    // Output
    command.add(outputPath);

    return command.join(' ');
  }

  Future<int> executeCompression(String command, Function(int progress) onProgress) async {
    final executionId = await _ffmpeg.executeAsync(command, (executionId, returnCode) {
      // Compression completed
    });

    // Monitor progress
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final statistics = await _ffmpeg.getLastReceivedStatistics();
      if (statistics != null) {
        final time = statistics.time;
        // Calculate progress based on time
        // This is simplified; in real implementation, you'd need input duration
        onProgress((time / 1000).toInt()); // Mock progress
      }
    });

    return executionId;
  }

  Future<void> cancelCompression(int executionId) async {
    await _ffmpeg.cancelExecution(executionId);
  }
}