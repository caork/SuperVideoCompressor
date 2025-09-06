import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/compression_provider.dart';

class PreviewPanel extends StatefulWidget {
  const PreviewPanel({super.key});

  @override
  State<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<PreviewPanel> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompressionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Preview
              const Text('Video Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: provider.selectedVideo != null
                      ? _buildVideoPlayer(provider.selectedVideo!.path)
                      : const Center(
                          child: Text('No video selected'),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Thumbnail Grid
              const Text('Thumbnails', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Mock thumbnails
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 32),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Progress and Status
              if (provider.isCompressing || provider.progress > 0) ...[
                const Text('Compression Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: provider.progress / 100),
                const SizedBox(height: 8),
                Text('${provider.progress.toStringAsFixed(1)}% - ${provider.status}'),
              ],

              // Output Info
              if (provider.outputPath != null) ...[
                const SizedBox(height: 16),
                const Text('Output', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Path: ${provider.outputPath}'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (provider.outputPath != null) {
                      // Open the output directory
                      final directory = provider.outputPath!.substring(0, provider.outputPath!.lastIndexOf('/'));
                      // Note: Opening directory requires platform-specific code
                      // For now, we'll show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Output saved to: $directory')),
                      );
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Output Folder'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(String videoPath) {
    // Check if video_player is supported on this platform
    if (Platform.isLinux) {
      // On Linux, show a placeholder since video_player doesn't support Linux
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Video preview not available on Linux',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Video compression will still work',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.play_arrow, color: Colors.grey),
              ),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.volume_up, color: Colors.grey),
              ),
            ],
          ),
        ],
      );
    }

    // Initialize video player for supported platforms
    _controller ??= VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {});
      });

    if (_controller!.value.isInitialized) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
              Expanded(
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _controller!.setVolume(
                      _controller!.value.volume > 0 ? 0 : 1,
                    );
                  });
                },
                icon: Icon(
                  _controller!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}