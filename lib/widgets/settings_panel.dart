import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/compression_provider.dart';
import '../models/compression_settings.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompressionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Selection
              const Text('Input Video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: provider.isCompressing ? null : provider.pickVideoFile,
                icon: const Icon(Icons.video_file),
                label: const Text('Select Video File'),
              ),
              if (provider.selectedVideo != null) ...[
                const SizedBox(height: 8),
                Text('File: ${provider.selectedVideo!.name}'),
                Text('Size: ${provider.selectedVideo!.formattedSize}'),
                Text('Duration: ${provider.selectedVideo!.formattedDuration}'),
                Text('Resolution: ${provider.selectedVideo!.width}x${provider.selectedVideo!.height}'),
              ],

              const SizedBox(height: 24),

              // Output Settings
              const Text('Output Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: provider.settings.outputFormat,
                decoration: const InputDecoration(labelText: 'Format'),
                items: ['mp4', 'avi', 'mov', 'webm', 'mkv'].map((format) {
                  return DropdownMenuItem(value: format, child: Text(format.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.updateSettings(provider.settings.copyWith(outputFormat: value));
                  }
                },
              ),

              const SizedBox(height: 16),

              // Video Codec
              DropdownButtonFormField<VideoCodec>(
                value: provider.settings.videoCodec,
                decoration: const InputDecoration(labelText: 'Video Codec'),
                items: VideoCodec.values.map((codec) {
                  return DropdownMenuItem(value: codec, child: Text(codec.name.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.updateSettings(provider.settings.copyWith(videoCodec: value));
                  }
                },
              ),

              const SizedBox(height: 16),

              // Resolution
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: provider.settings.width?.toString() ?? '',
                      decoration: const InputDecoration(labelText: 'Width'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final width = int.tryParse(value);
                        provider.updateSettings(provider.settings.copyWith(width: width));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('x'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: provider.settings.height?.toString() ?? '',
                      decoration: const InputDecoration(labelText: 'Height'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final height = int.tryParse(value);
                        provider.updateSettings(provider.settings.copyWith(height: height));
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isCompressing ? null : provider.startCompression,
                      child: Text(provider.isCompressing ? 'Compressing...' : 'Compress'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: provider.reset,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset',
                  ),
                ],
              ),

              if (provider.isCompressing) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: provider.progress / 100),
                const SizedBox(height: 8),
                Text('Progress: ${provider.progress.toStringAsFixed(1)}%'),
                Text(provider.status),
              ],
            ],
          ),
        );
      },
    );
  }
}