import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class MoreStoriesList extends StatelessWidget {
  const MoreStoriesList({
    required this.stories,
    required this.onOpen,
    required this.onSeeAll,
    super.key,
  });

  final List<StoryTeaser> stories;
  final ValueChanged<StoryTeaser> onOpen;
  final VoidCallback onSeeAll;

  String _reads(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Cerita & Inspirasi Lainnya',
                style: AppTypography.heading(20),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Semua'), Icon(Icons.chevron_right, size: 18)],
              ),
            ),
          ],
        ),
        const Text(
          'Kisah nyata penuh romansa dari para pengantin Aura',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (stories.isEmpty)
          const EmptyState(
            message: 'Belum ada cerita di kategori ini.',
            icon: Icons.menu_book_outlined,
          )
        else
          for (final s in stories)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                child: InkWell(
                  onTap: () => onOpen(s),
                  borderRadius: AppRadius.card,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: ImagePlaceholder(
                            icon: Icons.photo_outlined,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.category.toUpperCase(),
                                style: AppTypography.eyebrow.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${s.dateLabel} • ${_reads(s.reads)} dibaca',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
