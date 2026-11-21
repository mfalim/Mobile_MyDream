import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class MoreStoriesList extends StatelessWidget {
  const MoreStoriesList({
    required this.stories,
    required this.onOpen,
    this.onSeeAll,
    this.title = 'Cerita & Inspirasi Lainnya',
    this.subtitle = 'Kisah nyata penuh romansa, tips, dan panduan dari MyDream',
    super.key,
  });

  final List<StoryTeaser> stories;
  final ValueChanged<StoryTeaser> onOpen;
  final VoidCallback? onSeeAll;
  final String title;
  final String subtitle;

  String _reads(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  String? _meta(StoryTeaser s) {
    final author = s.authorName;
    final date = s.dateLabel;
    final reads = s.reads;
    final parts = [
      if (author != null && author.isNotEmpty) 'Oleh $author',
      if (date != null) date,
      if (reads != null) '${_reads(reads)} dibaca',
    ];
    return parts.isEmpty ? null : parts.join(' • ');
  }

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
                title,
                style: AppTypography.heading(20),
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Semua'), Icon(Icons.chevron_right, size: 18)],
                ),
              ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                          width: 96,
                          height: 96,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: AppImage(url: s.photoUrl),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      s.category.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.eyebrow.copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  if (s.rating != null && s.rating! > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '★ ${s.rating}/5',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                              if (s.excerpt != null &&
                                  s.excerpt!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  s.excerpt!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                              if (_meta(s) != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _meta(s)!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
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
