import 'package:flutter/material.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
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
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
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