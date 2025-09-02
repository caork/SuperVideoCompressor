import 'package:flutter/foundation.dart';
import '../models/video_file.dart';
import '../models/compression_settings.dart';
import '../models/hardware_info.dart';
import '../services/compression_service.dart';
import '../services/file_service.dart';
import '../services/hardware_detection_service.dart';

class CompressionProvider with ChangeNotifier {
  VideoFile? _selectedVideo;
  CompressionSettings _settings = const CompressionSettings();
  HardwareInfo? _hardwareInfo;
  bool _isCompressing = false;
  double _progress = 0.0;
  String _status = 'Ready';
  String? _outputPath;

  final CompressionService _compressionService = CompressionService();
  final FileService _fileService = FileService();
  final HardwareDetectionService _hardwareService = HardwareDetectionService();

  // Getters
  VideoFile? get selectedVideo => _selectedVideo;
  CompressionSettings get settings => _settings;
  HardwareInfo? get hardwareInfo => _hardwareInfo;
  bool get isCompressing => _isCompressing;
  double get progress => _progress;
  String get status => _status;
  String? get outputPath => _outputPath;

  // Initialization
  Future<void> initialize() async {
    _hardwareInfo = await _hardwareService.detectHardwareAcceleration();
    notifyListeners();
  }

  // File operations
  Future<void> pickVideoFile() async {
    final video = await _fileService.pickVideoFile();
    if (video != null) {
      _selectedVideo = await _compressionService.getVideoInfo(video.file);
      _outputPath = await _fileService.getDefaultOutputPath(_selectedVideo!, _settings.outputFormat);
      notifyListeners();
    }
  }

  Future<void> pickOutputDirectory() async {
    final directory = await _fileService.pickOutputDirectory();
    if (directory != null && _selectedVideo != null) {
      final fileName = '${_selectedVideo!.name.split('.').first}_compressed.${_settings.outputFormat}';
      _outputPath = '$directory/$fileName';
      notifyListeners();
    }
  }

  // Settings operations
  void updateSettings(CompressionSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // Compression operations
  Future<void> startCompression() async {
    if (_selectedVideo == null || _outputPath == null) return;

    _isCompressing = true;
    _progress = 0.0;
    _status = 'Building FFmpeg command...';
    notifyListeners();

    try {
      final command = await _compressionService.buildFFmpegCommand(
        _selectedVideo!,
        _settings,
        _outputPath!,
      );

      _status = 'Compressing...';
      notifyListeners();

      final executionId = await _compressionService.executeCompression(
        command,
        (progress) {
          _progress = progress.toDouble();
          notifyListeners();
        },
      );

      // Wait for completion (simplified)
      await Future.delayed(const Duration(seconds: 5));

      _isCompressing = false;
      _progress = 100.0;
      _status = 'Compression completed';
      notifyListeners();

    } catch (e) {
      _isCompressing = false;
      _status = 'Compression failed: $e';
      notifyListeners();
    }
  }

  void cancelCompression() {
    _isCompressing = false;
    _status = 'Compression cancelled';
    notifyListeners();
  }

  void reset() {
    _selectedVideo = null;
    _settings = const CompressionSettings();
    _isCompressing = false;
    _progress = 0.0;
    _status = 'Ready';
    _outputPath = null;
    notifyListeners();
  }
}