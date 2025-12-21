import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:video_player/video_player.dart';

/// A widget that displays and plays a video-based question.
///
/// The `QuizVideoWidget` class is a stateful widget that renders a video player
/// for quiz questions. It displays a video with playback controls that adapt
/// to different screen sizes.
///
/// The widget automatically manages the video player lifecycle and provides
/// visual feedback for playback state, loading, and errors.
class QuizVideoWidget extends StatefulWidget {
  /// The question entry containing the video URL.
  final QuestionEntry entry;

  /// The width constraint for the video player container.
  final double width;

  /// The height constraint for the video player container.
  final double height;

  /// Creates a `QuizVideoWidget` with the specified question entry and dimensions.
  ///
  /// [key] is the unique key for this widget.
  /// [entry] is the `QuestionEntry` object containing the video question.
  /// [width] is the width constraint for the video player container.
  /// [height] is the height constraint for the video player container.
  const QuizVideoWidget({
    required Key key,
    required this.entry,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<QuizVideoWidget> createState() => _QuizVideoWidgetState();
}

class _QuizVideoWidgetState extends State<QuizVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoQuestion = widget.entry.type as VideoQuestion;

      // Check if it's a network URL or asset
      if (videoQuestion.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(videoQuestion.videoUrl),
        );
      } else {
        _controller = VideoPlayerController.asset(videoQuestion.videoUrl);
      }

      _controller.setLooping(true);

      await _controller.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }

      // Auto-play the video
      _controller.play();

      _controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = (widget.entry.otherOptions["id"] as String).toLowerCase();
    final videoQuestion = widget.entry.type as VideoQuestion;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildContent(context, code, videoQuestion),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, String code, VideoQuestion videoQuestion) {
    if (_hasError) {
      return _buildErrorState(context);
    }

    if (!_isInitialized) {
      return _buildLoadingState(context, videoQuestion);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video player
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        // Play/Pause overlay
        if (!_controller.value.isPlaying)
          _buildPlayPauseOverlay(context, code),
        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildControls(context),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, VideoQuestion videoQuestion) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show thumbnail if available
          if (videoQuestion.thumbnailPath != null)
            Expanded(
              child: Image.asset(
                videoQuestion.thumbnailPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: _getErrorIconSize(context),
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load video',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: _getErrorTextSize(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseOverlay(BuildContext context, String code) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Container(
        color: Colors.black45,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              key: Key("video_button_$code"),
              size: _getPlayIconSize(context),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black87,
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Play/Pause button
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: _getControlIconSize(context),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
          // Progress bar
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.white24,
                bufferedColor: Colors.white38,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Time display
          Text(
            _formatDuration(_controller.value.position) +
                ' / ' +
                _formatDuration(_controller.value.duration),
            style: TextStyle(
              color: Colors.white,
              fontSize: _getTimeTextSize(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double _getPlayIconSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 64,
      tablet: 96,
      desktop: 112,
      watch: 48,
    );
  }

  double _getControlIconSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 24,
      tablet: 32,
      desktop: 36,
      watch: 20,
    );
  }

  double _getTimeTextSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 12,
      tablet: 16,
      desktop: 18,
      watch: 10,
    );
  }

  double _getErrorIconSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 48,
      tablet: 72,
      desktop: 84,
      watch: 36,
    );
  }

  double _getErrorTextSize(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 28,
      watch: 12,
    );
  }
}
