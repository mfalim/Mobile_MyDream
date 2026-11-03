import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';

/// Jumlah suka dan dibaca. Hilang seluruhnya bila keduanya tidak ada datanya.
class StoryEngagement extends StatelessWidget {
  const StoryEngagement({
    required this.likes,
    required this.reads,
    required this.liked,
    required this.onLike,
    super.key,
  });

  final int? likes;
  final int? reads;
  final bool liked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final likeCount = likes;
    final readCount = reads;
    if (likeCount == null && readCount == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          if (likeCount != null)
            Expanded(
              child: TextButton.icon(
                onPressed: onLike,
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  '${formatNumber(likeCount)} Terinspirasi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  alignment: Alignment.centerLeft,
                ),
              ),
            )
          else
            const Spacer(),
          if (readCount != null) ...[
            const Icon(
              Icons.visibility_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${formatNumber(readCount)} kali dibaca',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
