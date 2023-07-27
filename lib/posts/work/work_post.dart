import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class WorkPost extends StatefulWidget {
  final Widget? drawingCanvas;
  const WorkPost({super.key, this.drawingCanvas});

  @override
  State<WorkPost> createState() => _WorkPostState();
}

class _WorkPostState extends State<WorkPost> {
  final Map<String, double> _playBackSpeeds = {
    'Slower': 0.1,
    'Slow': 0.5,
    'Default': 1.0,
    'x1.5': 1.5,
    'x2.0': 2.0,
    'x2.5': 2.5,
    'x3.0': 3.0
  };

  late VideoPlayerController _controller;

  bool _showSpeedPicker = false, _showVolumeSlider = false;
  double? _volumeSlidingValue, _seekPosition;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/working.mp4'
        // Uri.parse(
        //   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        // ),
        )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      ).then(
        (value) => _controller
          ..setLooping(true)
          ..play(),
      );
      _controller.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (_controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            if (_controller.value.isInitialized)
              Column(
                children: [
                  Expanded(
                    child: widget.drawingCanvas ?? Container(),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: 45,
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(.3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_outlined
                                  : Icons.play_arrow_outlined,
                              color: Colors.white,
                            ),
                          ),
                          if (_controller.value.isPlaying) ...[
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 10,
                                  thumbShape: const RoundSliderThumbShape(
                                    elevation: 0,
                                    disabledThumbRadius: 5,
                                    enabledThumbRadius: 5,
                                  ),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: _controller.value.duration.inSeconds
                                      .toDouble(),
                                  value: _seekPosition ??
                                      _controller.value.position.inSeconds
                                          .toDouble(),
                                  onChangeEnd: _onSliderValueChanged,
                                  onChanged: (value) {
                                    setState(() {
                                      _seekPosition = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showVolumeSlider = !_showVolumeSlider;
                                  _showSpeedPicker = false;
                                });
                              },
                              icon: Icon(
                                _controller.value.volume > 0
                                    ? Icons.volume_down
                                    : Icons.volume_off,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showSpeedPicker = !_showSpeedPicker;
                                  _showVolumeSlider = false;
                                });
                              },
                              child: Text(
                                'x${_controller.value.playbackSpeed}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _toggleFullScreen(_isFullScreen ? false : true);
                              },
                              icon: Icon(
                                _isFullScreen
                                    ? Icons.fullscreen
                                    : Icons.fullscreen_exit,
                                color: Colors.white,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            if (_controller.value.isPlaying && _showSpeedPicker)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    margin:
                        const EdgeInsets.only(top: 25, bottom: 55, right: 20),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _playBackSpeeds.keys
                            .map(
                              (e) => InkWell(
                                onTap: () =>
                                    _playbackSpeedSelected(_playBackSpeeds[e]!),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 7),
                                  child: _playBackSpeeds[e] ==
                                          _controller.value.playbackSpeed
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.done_rounded,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(e)
                                          ],
                                        )
                                      : Text(e),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )),
              ),
            if (_controller.value.isPlaying && _showVolumeSlider)
              Positioned(
                bottom: 55,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        elevation: 0,
                        disabledThumbRadius: 10,
                        enabledThumbRadius: 10,
                      ),
                      activeTrackColor: Colors.black87,
                      activeTickMarkColor: Colors.black87,
                      thumbColor: Colors.black87,
                      disabledActiveTickMarkColor: Colors.black38,
                      disabledActiveTrackColor: Colors.grey,
                    ),
                    child: Slider(
                      value: _volumeSlidingValue ?? _controller.value.volume,
                      label: 'Playback speed',
                      min: 0.0,
                      max: 1.0,
                      // divisions: 5,
                      onChangeEnd: _volumeSelected,
                      onChanged: (value) {
                        setState(() {
                          _volumeSlidingValue = value;
                        });
                      },
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  bool _isFullScreen = false;
  _toggleFullScreen(bool enabled) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        if (enabled) ...[SystemUiOverlay.bottom, SystemUiOverlay.top]
      ],
    );
    _isFullScreen = enabled;
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      // SystemChrome.setEnabledSystemUIMode(
      //   SystemUiMode.manual,
      //   overlays: [
      //     SystemUiOverlay.bottom,
      //     if (!_isFullScreen) SystemUiOverlay.top,
      //   ],
      // );
    } else {
      _controller.play();
      // if (_isFullScreen) {
      //   _toggleFullScreen(true);
      // }
    }
  }

  void _onSliderValueChanged(double value) {
    _seekPosition = null;
    _controller.seekTo(
      Duration(
        seconds: value.toInt(),
      ),
    );
  }

  void _playbackSpeedSelected(double value) {
    _showSpeedPicker = false;

    _controller.setPlaybackSpeed(
      double.parse(
        value.toStringAsFixed(1),
      ),
    );
  }

  void _volumeSelected(double value) {
    _showVolumeSlider = false;
    _volumeSlidingValue = null;
    _controller.setVolume(
      double.parse(
        value.toStringAsFixed(1),
      ),
    );
  }
}
