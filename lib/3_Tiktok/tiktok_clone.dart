import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_showcases/3_Tiktok/animated_text.dart';
import 'package:ui_showcases/3_Tiktok/pexels_service.dart';
import 'package:ui_showcases/3_Tiktok/video.dart';
import 'package:video_player/video_player.dart';

class TiktokHomeClone extends StatefulWidget {
  const TiktokHomeClone({
    super.key,
  });

  @override
  State<TiktokHomeClone> createState() => _TiktokHomeCloneState();
}

class _TiktokHomeCloneState extends State<TiktokHomeClone> {
  late final PexelsService _pexelsService;
  List<Video> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pexelsService = PexelsService(dotenv.env['PEXELS_API_KEY'] ?? '');
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await _pexelsService.getPopularVideos();
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load videos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _VideoFeed(videos: _videos),
    );
  }
}

class _VideoFeed extends StatefulWidget {
  final List<Video> videos;
  const _VideoFeed({required this.videos});

  @override
  State<_VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<_VideoFeed> {
  late final PageController _pageController;
  late List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _videoControllers = widget.videos
        .map((video) => VideoPlayerController.networkUrl(Uri.parse(video.path)))
        .toList();

    // Initialize all video controllers
    for (var controller in _videoControllers) {
      controller.initialize().then((_) {
        setState(() {});
      });
    }

    // Start playing the first video
    _playVideo(0);
  }

  void _playVideo(int index) {
    // Pause all videos
    for (var controller in _videoControllers) {
      controller.pause();
    }

    // Play the current video
    if (_videoControllers[index].value.isInitialized) {
      _videoControllers[index].play();
      _videoControllers[index].setLooping(true);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (index) {
              _playVideo(index);
            },
            itemBuilder: (context, index) {
              final rand = Random();
              final video = widget.videos[index];
              final controller = _videoControllers[index];
              return Stack(
                children: [
                  Positioned.fill(
                    child: // Video player
                        controller.value.isInitialized
                            ? VideoPlayer(controller)
                            : const Center(child: CircularProgressIndicator()),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '@${video.username}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            video.description,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('#hashtag #second #follow #like #share',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SvgPicture.asset('assets/icons/tiktok/music.svg',
                                  width: 12, height: 12),
                              const SizedBox(width: 8),
                              AnimatedText(
                                  text: 'original sound - @username',
                                  width: 150,
                                  textStyle: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 12,
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 16,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 24,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    AssetImage('assets/images/user_avatar.png'),
                              ),
                              Positioned(
                                bottom: -12,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffFE2C55),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAction("like", rand.nextInt(10000).toString()),
                        _buildAction("comment", rand.nextInt(10000).toString()),
                        _buildAction("share", rand.nextInt(1000).toString()),
                      ],
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Following',
                              style: GoogleFonts.montserrat(
                                color: const Color.fromARGB(255, 84, 84, 84),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 16),
                          Text('For you',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      )),
                ],
              );
            },
          ),
        ),
        const TiktokBottomBar(),
      ],
    );
  }

  Widget _buildAction(String svgName, String text) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/tiktok/$svgName.svg',
          width: 26,
          height: 26,
        ),
        Text(text,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class TiktokBottomBar extends StatelessWidget {
  const TiktokBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _makeIcon('home'),
          _makeIcon('friends'),
          Image.asset('assets/icons/tiktok/tiktok_button.png',
              width: 32, height: 32),
          _makeIcon('inbox'),
          _makeIcon('profile'),
        ],
      ),
    );
  }

  Widget _makeIcon(String svgName) {
    return SvgPicture.asset(
      'assets/icons/tiktok/$svgName.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        Colors.white,
        BlendMode.srcIn,
      ),
    );
  }
}
