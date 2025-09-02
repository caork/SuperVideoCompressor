import 'compression_settings.dart';

class HardwareInfo {
  final bool hasCuda;
  final bool hasAmf;
  final bool hasQsv;
  final bool hasVideoToolbox;
  final bool hasVaapi;
  final bool hasVdpau;
  final List<HardwareAcceleration> availableAccelerations;

  const HardwareInfo({
    this.hasCuda = false,
    this.hasAmf = false,
    this.hasQsv = false,
    this.hasVideoToolbox = false,
    this.hasVaapi = false,
    this.hasVdpau = false,
    this.availableAccelerations = const [],
  });

  HardwareAcceleration get bestAcceleration {
    if (availableAccelerations.isEmpty) return HardwareAcceleration.none;

    // Priority order: CUDA > QSV > AMF > VideoToolbox > VAAPI > VDPAU
    final priority = [
      HardwareAcceleration.cuda,
      HardwareAcceleration.qsv,
      HardwareAcceleration.amf,
      HardwareAcceleration.videotoolbox,
      HardwareAcceleration.vaapi,
      HardwareAcceleration.vdpau,
    ];

    for (final accel in priority) {
      if (availableAccelerations.contains(accel)) {
        return accel;
      }
    }

    return HardwareAcceleration.none;
  }

  factory HardwareInfo.detect() {
    // This would implement actual hardware detection
    // For now, return mock data
    return const HardwareInfo(
      hasCuda: true,
      hasQsv: true,
      availableAccelerations: [
        HardwareAcceleration.cuda,
        HardwareAcceleration.qsv,
      ],
    );
  }
}