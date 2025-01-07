import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final List<Map<String, String>> videos = const [
    {
      'title': 'Winter Girl',
      'id': 'OI9XhYOElOk',
      'thumbnail': 'https://img.youtube.com/vi/OI9XhYOElOk/0.jpg',
    },
    {
      'title': 'Real Madrid',
      'id': 'LiPo6ausJIU',
      'thumbnail': 'https://img.youtube.com/vi/LiPo6ausJIU/0.jpg',
    },
    {
      'title': 'Real Madrid',
      'id': 'xfeBelVzEHQ',
      'thumbnail': 'https://img.youtube.com/vi/iLnmTe5Q2Qw/0.jpg',
    },
  ];

  late PageController _pageController;
  List<YoutubePlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Khởi tạo controllers cho mỗi video
    _controllers = videos.map((video) {
      return YoutubePlayerController(
        initialVideoId: video['id']!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          loop: true,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Shorts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: videos.length,
        onPageChanged: (index) {
          // Dừng video hiện tại khi chuyển trang
          for (var controller in _controllers) {
            controller.pause();
          }
          // Phát video mới
          _controllers[index].play();
        },
        itemBuilder: (context, index) {
          return Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _controllers[index],
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.red,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.red,
                      handleColor: Colors.redAccent,
                    ),
                    aspectRatio: 9 / 16, // Tỷ lệ dọc cho Shorts
                  ),
                  builder: (context, player) {
                    return player;
                  },
                ),
                // Overlay controls
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_down, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Video title and description
                Positioned(
                  left: 16,
                  bottom: 50,
                  right: 80,
                  child: Text(
                    videos[index]['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}