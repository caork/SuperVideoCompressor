# Super Video Compressor - Video Preview Functionality

## Overview
The video preview system provides both thumbnail previews and full video playback capabilities, allowing users to review input videos and preview compression results.

## Thumbnail Generation

### FFmpeg Thumbnail Extraction
- Extract frames at specific timestamps (0%, 25%, 50%, 75%, 100%)
- Generate multiple sizes (small: 160x90, medium: 320x180, large: 640x360)
- Optimize for fast generation with low quality settings
- Cache thumbnails in app data directory

### Thumbnail Command Examples
```
# Single thumbnail at 10 seconds
ffmpeg -i input.mp4 -ss 00:00:10 -vframes 1 -q:v 2 thumbnail.jpg

# Multiple thumbnails with grid layout
ffmpeg -i input.mp4 -vf "select='eq(n,0)+eq(n,150)+eq(n,300)',scale=320:180,tile=3x1" thumbnails.jpg
```

### Caching Strategy
- File-based caching with hash-based naming
- Cache invalidation on file modification
- Memory caching for recently used thumbnails
- Background thumbnail generation for batch files

## Video Playback

### Package Selection
- **Primary**: `video_player` package for Flutter
- **Alternative**: Custom native video players via platform channels
- **Backup**: System default video player launch

### Playback Features
- Play/Pause controls
- Seek bar with time display
- Volume control
- Fullscreen toggle
- Playback speed adjustment (0.5x, 1x, 1.5x, 2x)

### Preview Widget Architecture
```dart
class VideoPreviewWidget extends StatefulWidget {
  final File videoFile;
  final bool isInputVideo;
  final VoidCallback? onVideoLoaded;

  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}
```

## Preview Modes

### Input Video Preview
- Display original video with metadata overlay
- Show file information (duration, resolution, size)
- Allow scrubbing to different parts of the video

### Output Video Preview
- Preview compressed video before final save
- Compare quality with input video
- Show compression statistics (file size reduction, quality metrics)

### Side-by-Side Comparison
- Split-screen view for input vs output
- Synchronized playback
- Quality difference visualization

## Thumbnail Grid

### Layout Options
- Grid view: 2x2, 3x3, 4x4 thumbnails
- Timeline view: Horizontal strip of thumbnails
- Filmstrip view: Vertical stack with timestamps

### Interaction
- Click thumbnail to seek to that position
- Drag to scrub through video
- Hover to show timestamp and frame info

## Performance Optimization

### Lazy Loading
- Generate thumbnails on demand
- Prioritize visible thumbnails
- Background processing for non-visible items

### Memory Management
- Limit concurrent video players to 1-2
- Dispose unused video controllers
- Cache video metadata separately from media

### Hardware Acceleration
- Use hardware decoding for smooth playback
- Fallback to software decoding if needed
- GPU-accelerated rendering for Flutter

## Integration with Compression

### Real-time Preview
- Generate preview during compression process
- Show progress with partial video playback
- Update thumbnails as compression completes

### Preview Generation Workflow
1. Start compression in background
2. Generate temporary output file
3. Extract thumbnails from temporary file
4. Update preview widget with new content
5. Clean up temporary files on completion

## Error Handling

### Playback Errors
- Corrupted video files
- Unsupported codecs
- Hardware decoding failures
- Network issues (for remote files)

### Thumbnail Generation Errors
- FFmpeg execution failures
- Permission issues
- Disk space limitations
- Invalid video files

### Fallback Strategies
- Show file icon for failed thumbnails
- Disable playback for unsupported formats
- Provide alternative preview methods

## User Experience

### Loading States
- Skeleton screens during thumbnail generation
- Progress indicators for video loading
- Placeholder images for missing thumbnails

### Accessibility
- Keyboard navigation for controls
- Screen reader support for video content
- High contrast mode for controls

### Customization
- User preferences for thumbnail sizes
- Playback quality settings
- Auto-play options