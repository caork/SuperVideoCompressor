# Super Video Compressor

A cross-platform video compression application built with Flutter, featuring FFmpeg integration, hardware acceleration support, and video preview capabilities.

## Features

- **Cross-Platform**: Supports Linux, macOS, and Windows
- **FFmpeg Integration**: Powerful video compression using FFmpeg
- **Hardware Acceleration**: Automatic detection and utilization of GPU acceleration
- **Video Preview**: Built-in video player with thumbnail generation
- **Modern UI**: Material Design 3 interface
- **Parameter Control**: Customizable compression settings

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- FFmpeg (automatically bundled)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/super_video_compressor.git
   cd super_video_compressor
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/           # Data models
├── services/         # Business logic services
├── providers/        # State management
├── screens/          # UI screens
└── widgets/          # Reusable UI components
```

## Architecture

The app follows a layered architecture:
- **UI Layer**: Flutter widgets with Provider for state management
- **Business Logic Layer**: Services for compression, file handling, and hardware detection
- **FFmpeg Integration Layer**: Dart interface to FFmpeg commands
- **Platform Layer**: Platform-specific implementations

## Dependencies

- `flutter_ffmpeg`: FFmpeg integration for Flutter
- `video_player`: Video playback functionality
- `file_picker`: File selection dialogs
- `provider`: State management
- `path_provider`: File system access

## Building

### Linux
```bash
flutter build linux --release
```

### macOS
```bash
flutter build macos --release
```

### Windows
```bash
flutter build windows --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
