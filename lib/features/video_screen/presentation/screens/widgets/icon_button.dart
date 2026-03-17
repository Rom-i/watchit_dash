import 'package:flutter/material.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

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
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bg, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.7),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}