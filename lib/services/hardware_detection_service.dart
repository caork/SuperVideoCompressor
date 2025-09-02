import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import '../models/hardware_info.dart';
import '../models/compression_settings.dart';

class HardwareDetectionService {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

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
      // Test with a simple command
      final command = '-f lavfi -i testsrc=duration=1:size=320x240:rate=1 -c:v libx264 -f null -';
      final result = await _ffmpeg.execute(command);
      return result == 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getAvailableEncoders() async {
    // This would query FFmpeg for available encoders
    return ['libx264', 'libx265', 'libvpx-vp9'];
  }

  Future<List<String>> getAvailableDecoders() async {
    // This would query FFmpeg for available decoders
    return ['h264', 'h265', 'vp9'];
  }
}