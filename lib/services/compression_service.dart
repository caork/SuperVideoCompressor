import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import '../models/video_file.dart';
import '../models/compression_settings.dart';
import '../models/hardware_info.dart';

class CompressionService {

  Future<VideoFile> getVideoInfo(File file) async {
    if (Platform.isLinux) {
      // Use system ffprobe on Linux
      return await _getVideoInfoFromSystemFFprobe(file);
    } else {
      // Use ffmpeg_kit_flutter_full on mobile platforms
      return await _getVideoInfoFromPlugin(file);
    }
  }

  Future<VideoFile> _getVideoInfoFromSystemFFprobe(File file) async {
    try {
      // Run ffprobe to get media information in JSON format
      final result = await Process.run('ffprobe', [
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        file.path
      ]);

      if (result.exitCode != 0) {
        throw Exception('ffprobe failed: ${result.stderr}');
      }

      final jsonData = json.decode(result.stdout as String);
      final streams = jsonData['streams'] as List?;
      final videoStream = streams?.firstWhere(
        (stream) => stream['codec_type'] == 'video',
        orElse: () => null,
      );

      final format = jsonData['format'] as Map?;
      final duration = double.tryParse(format?['duration']?.toString() ?? '0') ?? 0;
      final size = int.tryParse(format?['size']?.toString() ?? '0') ?? 0;

      return VideoFile(
        file: file,
        name: file.path.split('/').last,
        path: file.path,
        size: size,
        duration: Duration(seconds: duration.toInt()),
        width: int.tryParse(videoStream?['width']?.toString() ?? '0') ?? 0,
        height: int.tryParse(videoStream?['height']?.toString() ?? '0') ?? 0,
        codec: videoStream?['codec_name']?.toString() ?? 'unknown',
        frameRate: double.tryParse(videoStream?['r_frame_rate']?.toString().split('/')[0] ?? '30') ?? 30.0,
        bitrate: int.tryParse(videoStream?['bit_rate']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  Future<VideoFile> _getVideoInfoFromPlugin(File file) async {
    final session = await FFprobeKit.getMediaInformation(file.path);
    final info = session.getMediaInformation();

    if (info == null) {
      throw Exception('Could not get media information');
    }

    final mediaProperties = info.getAllProperties();
    final streams = mediaProperties?['streams'] as List?;
    final videoStream = streams?.firstWhere(
      (stream) => (stream as Map)['codec_type'] == 'video',
      orElse: () => null,
    ) as Map?;

    final format = mediaProperties?['format'] as Map?;
    final duration = double.tryParse(format?['duration']?.toString() ?? '0') ?? 0;
    final size = int.tryParse(format?['size']?.toString() ?? '0') ?? 0;

    return VideoFile(
      file: file,
      name: file.path.split('/').last,
      path: file.path,
      size: size,
      duration: Duration(seconds: duration.toInt()),
      width: int.tryParse(videoStream?['width']?.toString() ?? '0') ?? 0,
      height: int.tryParse(videoStream?['height']?.toString() ?? '0') ?? 0,
      codec: videoStream?['codec_name']?.toString() ?? 'unknown',
      frameRate: double.tryParse(videoStream?['r_frame_rate']?.toString().split('/')[0] ?? '30') ?? 30.0,
      bitrate: int.tryParse(videoStream?['bit_rate']?.toString() ?? '0') ?? 0,
    );
  }

  Future<String> buildFFmpegCommand(VideoFile input, CompressionSettings settings, String outputPath) async {
    final command = <String>[];

    // Input
    command.addAll(['-i', input.path]);

    // Hardware acceleration for decoding (if GPU encoder selected)
    if (settings.encoderType == EncoderType.gpu && settings.hardwareAcceleration != HardwareAcceleration.none) {
      command.addAll(['-hwaccel', settings.hardwareAccelString]);
    }

    // Video codec
    command.addAll(['-c:v', settings.videoCodecString]);

    // Video settings
    if (settings.bitrate != null) {
      command.addAll(['-b:v', '${settings.bitrate!.toInt()}k']);
    }

    // Handle dimensions
    if (settings.matchSourceDimensions) {
      // Don't scale, keep original dimensions
    } else if (settings.width != null && settings.height != null) {
      command.addAll(['-vf', 'scale=${settings.width}:${settings.height}']);
    }

    if (settings.frameRate != null) {
      command.addAll(['-r', settings.frameRate!.toString()]);
    }

    // Audio codec
    command.addAll(['-c:a', settings.audioCodecString]);

    // Progress reporting
    command.addAll(['-progress', 'pipe:1']);

    // Output
    command.add(outputPath);

    return command.join(' ');
  }

  Future<int> executeCompression(String command, Function(int progress) onProgress) async {
    if (Platform.isLinux) {
      // Use system ffmpeg on Linux
      return await _executeCompressionWithSystemFFmpeg(command, onProgress);
    } else {
      // Use ffmpeg_kit_flutter_full on mobile platforms
      return await _executeCompressionWithPlugin(command, onProgress);
    }
  }

  Future<int> _executeCompressionWithSystemFFmpeg(String command, Function(int progress) onProgress) async {
    try {
      // Parse the command string into arguments
      final args = command.split(' ').where((arg) => arg.isNotEmpty).toList();

      final process = await Process.start('ffmpeg', args);

      // Monitor progress
      process.stdout.transform(utf8.decoder).listen((data) {
        // Parse FFmpeg progress output
        final lines = data.split('\n');
        for (final line in lines) {
          if (line.startsWith('out_time_ms=')) {
            // Duration in microseconds
            final durationMs = int.tryParse(line.split('=')[1]) ?? 0;
            // For now, we'll need to get total duration from input
            // This is a simplified version - in production, you'd parse duration from ffprobe
            onProgress(50); // Placeholder
          } else if (line.startsWith('progress=')) {
            if (line.contains('end')) {
              onProgress(100);
            }
          }
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        // Also check stderr for progress info
        if (data.contains('time=')) {
          // Parse time from stderr (older FFmpeg versions)
          final timeMatch = RegExp(r'time=(\d+):(\d+):(\d+)\.(\d+)').firstMatch(data);
          if (timeMatch != null) {
            final hours = int.parse(timeMatch.group(1)!);
            final minutes = int.parse(timeMatch.group(2)!);
            final seconds = int.parse(timeMatch.group(3)!);
            final totalSeconds = hours * 3600 + minutes * 60 + seconds;
            // This is approximate - you'd need total duration for accurate percentage
            onProgress(50);
          }
        }
      });

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        onProgress(100);
      }

      return exitCode;
    } catch (e) {
      throw Exception('Failed to execute compression: $e');
    }
  }

  Future<int> _executeCompressionWithPlugin(String command, Function(int progress) onProgress) async {
    final session = await FFmpegKit.executeAsync(command, (session) async {
      // Compression completed
      final returnCode = await session.getReturnCode();
      if (returnCode?.getValue() == 0) {
        onProgress(100);
      }
    });

    // Try to get progress from logs
    final logs = await session.getLogs();
    for (final log in logs) {
      final message = log.getMessage();
      if (message?.contains('time=') == true) {
        // Parse progress from logs (similar to system version)
        onProgress(50); // Simplified
      }
    }

    return session.getSessionId() ?? 0;
  }

  Future<void> cancelCompression(int executionId) async {
    await FFmpegKit.cancel(executionId);
  }
}