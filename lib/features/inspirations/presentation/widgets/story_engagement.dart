import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';

/// Jumlah "terinspirasi" dan dibaca, hanya sebagai informasi. Hilang
/// seluruhnya bila keduanya tidak ada datanya.
class StoryEngagement extends StatelessWidget {
  const StoryEngagement({required this.likes, required this.reads, super.key});

  final int? likes;
  final int? reads;

  @override
  Widget build(BuildContext context) {
    final likeCount = likes;
    final readCount = reads;
    if (likeCount == null && readCount == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          if (likeCount != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '${formatNumber(likeCount)} Terinspirasi',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          if (readCount != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${formatNumber(readCount)} kali dibaca',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
