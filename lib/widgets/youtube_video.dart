import 'package:flutter/cupertino.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerDialogContent extends StatefulWidget {
  final String videoId;
  const YoutubePlayerDialogContent({super.key, required this.videoId});

  @override
  State<YoutubePlayerDialogContent> createState() =>
      _YoutubePlayerDialogContentState();
}

class _YoutubePlayerDialogContentState
    extends State<YoutubePlayerDialogContent> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );
  }
}
