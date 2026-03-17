import 'package:flutter/material.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';
import 'package:watchit_dash/features/video_screen/data/model/video_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({
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

  // static const Color _card          = Color(0xFF1A1A26);
  // static const Color _red           = Color(0xFFE8001C);
  // static const Color _gold          = Color(0xFFFFC94D);
  // static const Color _textPrimary   = Color(0xFFF0F0F5);
  // static const Color _textSecondary = Color(0xFF7A7A95);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
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
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.isExpanded
        ? _expandController.forward()
        : _expandController.reverse();
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
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isExpanded
                  ? AppColors.red.withOpacity(0.5)
                  : const Color(0xFF22223A),
              width: 1,
            ),
            boxShadow: widget.isExpanded
                ? [BoxShadow(color: AppColors.red.withOpacity(0.15),
                    blurRadius: 20, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.isExpanded
                  ? AppColors.red
                  : const Color(0xFF22223A),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                color: widget.isExpanded
                    ? Colors.white
                    : AppColors.textSecondary,
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
                    color: AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
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
                  ? AppColors.red
                  : AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      axisAlignment: -1,
      child: Column(
        children: [
          Container(
            height: 1,
            color: widget.isExpanded
                ? AppColors.red.withOpacity(0.3)
                : Colors.transparent,
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Theme(
              data: ThemeData.dark().copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              child: YoutubePlayer(
                controller: widget.controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.red,
                progressColors: const ProgressBarColors(
                  playedColor:     AppColors.red,
                  handleColor:     AppColors.gold,
                  bufferedColor:   Color(0x55E8001C),
                  backgroundColor: Color(0xFF1A1A26),
                ),
                bottomActions: [
                  const SizedBox(width: 8),
                  CurrentPosition(controller: widget.controller),
                  const SizedBox(width: 8),
                  ProgressBar(
                    isExpanded: true,
                    colors: const ProgressBarColors(
                      playedColor:     AppColors.red,
                      handleColor:     AppColors.gold,
                      bufferedColor:   Color(0x55E8001C),
                      backgroundColor: Color(0xFF1A1A26),
                    ),
                  ),
                  RemainingDuration(controller: widget.controller),
                  const PlaybackSpeedButton(),
                  FullScreenButton(controller: widget.controller),
                ],
                onReady: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}