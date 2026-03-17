import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';
import 'package:watchit_dash/features/video_viewer/data/model/video_model.dart';
import 'package:watchit_dash/features/video_viewer/data/repo/video_repo.dart';
import 'package:watchit_dash/features/video_viewer/presentation/cubit/video_cubit.dart';
import 'package:watchit_dash/features/video_viewer/presentation/cubit/video_state.dart';
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
    for (final c in _controllers.values) {
      c.dispose();
    }
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
          disableDragSeek: false,
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
      appBar: _buildAppBar(),
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
                    const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red),
                      onPressed: () =>
                          context.read<VideoCubit>().loadVideos(),
                      child: const Text(' Reload '),
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
                SliverToBoxAdapter(child: _buildSectionLabel()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      return _VideoCard(
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

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg.withOpacity(0.85),
          border: const Border(
            bottom: BorderSide(color: Color(0xFF22223A), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  ' Watch IT',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                _AppBarIconButton(icon: Icons.search_rounded, onTap: () {}),
                const SizedBox(width: 4),
                _AppBarIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: () {},
                  badge: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: AppColors.gold, size: 14),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.2)),
      ],
    );
  }

  

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.red.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 0)
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'New Videos ',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}



class _VideoCard extends StatefulWidget {
  const _VideoCard({
    super.key,
    required this.index,
    required this.video,
    required this.controller,
    required this.isExpanded,
    required this.onTap,
  });

  final int index;
  final VideoModel video;
  final YoutubePlayerController controller;
  final bool isExpanded;
  final VoidCallback onTap;

  static const Color _card          = Color(0xFF1A1A26);
  static const Color _red           = Color(0xFFE8001C);
  static const Color _gold          = Color(0xFFFFC94D);
  static const Color _textPrimary   = Color(0xFFF0F0F5);
  static const Color _textSecondary = Color(0xFF7A7A95);

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(_VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _VideoCard._card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isExpanded
                  ? _VideoCard._red.withOpacity(0.5)
                  : const Color(0xFF22223A),
              width: 1,
            ),
            boxShadow: widget.isExpanded
                ? [
                    BoxShadow(
                      color: _VideoCard._red.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? _VideoCard._red
                            : const Color(0xFF22223A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: widget.isExpanded
                              ? Colors.white
                              : _VideoCard._textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.video.title,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: _VideoCard._textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),
                          if (widget.video.desc.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.video.desc,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _VideoCard._textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.isExpanded
                            ? _VideoCard._red
                            : _VideoCard._textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: widget.isExpanded
                          ? _VideoCard._red.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Theme(
                        data: ThemeData.dark().copyWith(
                          iconTheme:
                              const IconThemeData(color: Colors.white),
                        ),
                        child: YoutubePlayer(
                          controller: widget.controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: _VideoCard._red,
                          progressColors: const ProgressBarColors(
                            playedColor: _VideoCard._red,
                            handleColor: _VideoCard._gold,
                            bufferedColor: Color(0x55E8001C),
                            backgroundColor: Color(0xFF1A1A26),
                          ),
                          bottomActions: [
                            const SizedBox(width: 8),
                            CurrentPosition(
                                controller: widget.controller),
                            const SizedBox(width: 8),
                            ProgressBar(
                              isExpanded: true,
                              colors: const ProgressBarColors(
                                playedColor: _VideoCard._red,
                                handleColor: _VideoCard._gold,
                                bufferedColor: Color(0x55E8001C),
                                backgroundColor: Color(0xFF1A1A26),
                              ),
                            ),
                            RemainingDuration(
                                controller: widget.controller),
                            const PlaybackSpeedButton(),
                            FullScreenButton(
                                controller: widget.controller),
                          ],
                          onReady: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  static const Color _red           = Color(0xFFE8001C);
  static const Color _textSecondary = Color(0xFF7A7A95);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A26),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF22223A), width: 1),
            ),
            child: Icon(icon, color: _textSecondary, size: 18),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF0A0A0F), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: _red.withOpacity(0.7),
                        blurRadius: 6,
                        spreadRadius: 0)
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}