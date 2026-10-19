import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';

class StoryEngagement extends StatelessWidget {
  const StoryEngagement({
    required this.likes,
    required this.reads,
    required this.liked,
    required this.onLike,
    super.key,
  });

  final int likes;
  final int reads;
  final bool liked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: onLike,
              icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
              label: Text(
                '${formatNumber(likes)} Terinspirasi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          const Icon(
            Icons.visibility_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${formatNumber(reads)} kali dibaca',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
