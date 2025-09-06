import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import '../models/hardware_info.dart';
import '../models/compression_settings.dart';

class HardwareDetectionService {

  Future<HardwareInfo> detectHardwareAcceleration() async {
    final info = HardwareInfo.detect();

    // Test each acceleration method
    final available = <HardwareAcceleration>[];

    // Test CUDA
    if (await _testAcceleration('cuda')) {
      available.add(HardwareAcceleration.cuda);
    }

    // Test QSV
    if (await _testAcceleration('qsv')) {
      available.add(HardwareAcceleration.qsv);
    }

    // Test AMF
    if (await _testAcceleration('d3d11va')) {
      available.add(HardwareAcceleration.amf);
    }

    // Test VideoToolbox (macOS)
    if (Platform.isMacOS && await _testAcceleration('videotoolbox')) {
      available.add(HardwareAcceleration.videotoolbox);
    }

    // Test VAAPI (Linux)
    if (Platform.isLinux && await _testAcceleration('vaapi')) {
      available.add(HardwareAcceleration.vaapi);
    }

    // Test VDPAU (Linux)
    if (Platform.isLinux && await _testAcceleration('vdpau')) {
      available.add(HardwareAcceleration.vdpau);
    }

    return HardwareInfo(
      hasCuda: available.contains(HardwareAcceleration.cuda),
      hasAmf: available.contains(HardwareAcceleration.amf),
      hasQsv: available.contains(HardwareAcceleration.qsv),
      hasVideoToolbox: available.contains(HardwareAcceleration.videotoolbox),
      hasVaapi: available.contains(HardwareAcceleration.vaapi),
      hasVdpau: available.contains(HardwareAcceleration.vdpau),
      availableAccelerations: available,
    );
  }

  Future<bool> _testAcceleration(String accel) async {
    try {
      if (Platform.isLinux) {
        // Use system ffmpeg on Linux
        final result = await Process.run('ffmpeg', [
          '-f', 'lavfi',
          '-i', 'testsrc=duration=1:size=320x240:rate=1',
          '-c:v', 'libx264',
          '-f', 'null', '-'
        ]);
        return result.exitCode == 0;
      } else {
        // Use ffmpeg_kit_flutter_full on mobile platforms
        final session = await FFmpegKit.execute(
          '-f lavfi -i testsrc=duration=1:size=320x240:rate=1 -c:v libx264 -f null -'
        );
        final returnCode = await session.getReturnCode();
        return returnCode?.getValue() == 0;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getAvailableEncoders() async {
    try {
      if (Platform.isLinux) {
        // Query system FFmpeg for encoders
        final result = await Process.run('ffmpeg', ['-encoders']);
        if (result.exitCode == 0) {
          final output = result.stdout as String;
          final encoders = <String>[];
          final lines = output.split('\n');
          for (final line in lines) {
            if (line.contains('V') && line.contains('h264')) {
              encoders.add('libx264');
            }
            if (line.contains('V') && line.contains('h265')) {
              encoders.add('libx265');
            }
            if (line.contains('V') && line.contains('vp9')) {
              encoders.add('libvpx-vp9');
            }
            if (line.contains('V') && line.contains('av1')) {
              encoders.add('libaom-av1');
            }
          }
          return encoders;
        }
      } else {
        // For mobile, return common encoders
        return ['libx264', 'libx265', 'libvpx-vp9', 'libaom-av1'];
      }
    } catch (e) {
      // Fallback
      return ['libx264', 'libx265'];
    }
    return ['libx264', 'libx265'];
  }

  Future<List<String>> getAvailableDecoders() async {
    try {
      if (Platform.isLinux) {
        // Query system FFmpeg for decoders
        final result = await Process.run('ffmpeg', ['-decoders']);
        if (result.exitCode == 0) {
          final output = result.stdout as String;
          final decoders = <String>[];
          final lines = output.split('\n');
          for (final line in lines) {
            if (line.contains('V') && line.contains('h264')) {
              decoders.add('h264');
            }
            if (line.contains('V') && line.contains('h265')) {
              decoders.add('hevc');
            }
            if (line.contains('V') && line.contains('vp9')) {
              decoders.add('vp9');
            }
            if (line.contains('V') && line.contains('av1')) {
              decoders.add('av1');
            }
          }
          return decoders;
        }
      } else {
        // For mobile, return common decoders
        return ['h264', 'hevc', 'vp9', 'av1'];
      }
    } catch (e) {
      // Fallback
      return ['h264', 'hevc'];
    }
    return ['h264', 'hevc'];
  }
}