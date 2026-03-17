import 'package:flutter/material.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';
import 'package:watchit_dash/features/video_screen/presentation/screens/widgets/icon_button.dart';


class VideoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VideoAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'Watch IT',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              AppBarIconButton(icon: Icons.search_rounded, onTap: () {}),
              const SizedBox(width: 4),
              AppBarIconButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
                badge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}