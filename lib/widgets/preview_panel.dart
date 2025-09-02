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
                  onPressed: () {
                    // Open output directory
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
    // Initialize video player
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