import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';
import 'package:watchit_dash/features/video_screen/data/model/video_model.dart';
import 'package:watchit_dash/features/video_screen/data/repo/video_repo.dart';
import 'package:watchit_dash/features/video_screen/presentation/cubit/video_cubit.dart';
import 'package:watchit_dash/features/video_screen/presentation/cubit/video_state.dart';
import 'package:watchit_dash/features/video_screen/presentation/screens/widgets/app_bar.dart';
import 'package:watchit_dash/features/video_screen/presentation/screens/widgets/label.dart';
import 'package:watchit_dash/features/video_screen/presentation/screens/widgets/video_card.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoCubit(VideoRepo())..loadVideos(),
      child: const _VideosView(),
    );
  }
}

class _VideosView extends StatefulWidget {
  const _VideosView();

  @override
  State<_VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<_VideosView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int? _expandedIndex;

  final Map<String, YoutubePlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  YoutubePlayerController _controllerFor(VideoModel video) {
    final videoId =
        YoutubePlayer.convertUrlToId(video.videoUrl) ?? video.videoUrl;
    return _controllers.putIfAbsent(
      video.id,
      () => YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
          loop: false,
          isLive: false,
          forceHD: false,
          controlsVisibleAtStart: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: const VideoAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocBuilder<VideoCubit, VideoState>(
          builder: (context, state) {
            if (state is VideoLoading || state is VideoInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.red),
              );
            }
            if (state is VideoError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red),
                      onPressed: () =>
                          context.read<VideoCubit>().loadVideos(),
                      child: const Text('Reload'),
                    ),
                  ],
                ),
              );
            }

            final videos = (state as VideoLoaded).videos;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
                SliverToBoxAdapter(
                  child: SectionLabel(label: 'New Videos'),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      return VideoCard(
                        key: ValueKey(video.id),
                        index: index,
                        video: video,
                        controller: _controllerFor(video),
                        isExpanded: _expandedIndex == index,
                        onTap: () => setState(() {
                          _expandedIndex =
                              _expandedIndex == index ? null : index;
                        }),
                      );
                    },
                    childCount: videos.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }
}