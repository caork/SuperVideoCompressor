enum VideoCodec { h264, h265, vp9, av1 }
enum AudioCodec { aac, mp3, opus }
enum HardwareAcceleration { none, cuda, amf, qsv, videotoolbox, vaapi, vdpau }

class CompressionSettings {
  final String outputFormat;
  final VideoCodec videoCodec;
  final AudioCodec audioCodec;
  final int? width;
  final int? height;
  final double? bitrate;
  final double? frameRate;
  final HardwareAcceleration hardwareAcceleration;
  final bool maintainAspectRatio;
  final bool twoPassEncoding;

  const CompressionSettings({
    this.outputFormat = 'mp4',
    this.videoCodec = VideoCodec.h264,
    this.audioCodec = AudioCodec.aac,
    this.width,
    this.height,
    this.bitrate,
    this.frameRate,
    this.hardwareAcceleration = HardwareAcceleration.none,
    this.maintainAspectRatio = true,
    this.twoPassEncoding = false,
  });

  CompressionSettings copyWith({
    String? outputFormat,
    VideoCodec? videoCodec,
    AudioCodec? audioCodec,
    int? width,
    int? height,
    double? bitrate,
    double? frameRate,
    HardwareAcceleration? hardwareAcceleration,
    bool? maintainAspectRatio,
    bool? twoPassEncoding,
  }) {
    return CompressionSettings(
      outputFormat: outputFormat ?? this.outputFormat,
      videoCodec: videoCodec ?? this.videoCodec,
      audioCodec: audioCodec ?? this.audioCodec,
      width: width ?? this.width,
      height: height ?? this.height,
      bitrate: bitrate ?? this.bitrate,
      frameRate: frameRate ?? this.frameRate,
      hardwareAcceleration: hardwareAcceleration ?? this.hardwareAcceleration,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      twoPassEncoding: twoPassEncoding ?? this.twoPassEncoding,
    );
  }

  String get videoCodecString {
    switch (videoCodec) {
      case VideoCodec.h264:
        return 'libx264';
      case VideoCodec.h265:
        return 'libx265';
      case VideoCodec.vp9:
        return 'libvpx-vp9';
      case VideoCodec.av1:
        return 'libaom-av1';
    }
  }

  String get audioCodecString {
    switch (audioCodec) {
      case AudioCodec.aac:
        return 'aac';
      case AudioCodec.mp3:
        return 'mp3';
      case AudioCodec.opus:
        return 'libopus';
    }
  }

  String get hardwareAccelString {
    switch (hardwareAcceleration) {
      case HardwareAcceleration.cuda:
        return 'cuda';
      case HardwareAcceleration.amf:
        return 'd3d11va';
      case HardwareAcceleration.qsv:
        return 'qsv';
      case HardwareAcceleration.videotoolbox:
        return 'videotoolbox';
      case HardwareAcceleration.vaapi:
        return 'vaapi';
      case HardwareAcceleration.vdpau:
        return 'vdpau';
      case HardwareAcceleration.none:
        return '';
    }
  }
}