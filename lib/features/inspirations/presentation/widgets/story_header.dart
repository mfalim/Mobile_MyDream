import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class StoryHeader extends StatelessWidget {
  const StoryHeader({
    required this.story,
    required this.saved,
    required this.onSave,
    required this.onShare,
    super.key,
  });

  final RealWeddingStory story;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onShare;

  String _initials(String name) => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join()
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final tag = story.tag ?? story.category;
    final location = story.location;
    final excerpt = story.excerpt;
    final author = story.authorName;
    final published = story.publishedLabel;
    final minutes = story.readMinutes;
    final caption = story.heroCaption;
    final metaParts = [
      if (published != null) 'Dipublikasi $published',
      if (minutes != null) '$minutes mnt bacaan',
    ];
    final meta = metaParts.isEmpty ? null : metaParts.join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (tag != null)
              BadgePill(
                tag.toUpperCase(),
                background: AppColors.coral.withValues(alpha: 0.25),
                foreground: AppColors.primary,
              ),
            if (location != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tag != null ? '• $location' : location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            IconButton(
              tooltip: saved ? 'Hapus dari simpanan' : 'Simpan cerita',
              onPressed: onSave,
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            ),
            IconButton(
              tooltip: 'Bagikan',
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(story.title, style: AppTypography.heading(26)),
        if (excerpt != null) ...[
          const SizedBox(height: 10),
          Text(
            excerpt,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (author != null || meta != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              if (author != null) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceTint,
                  child: Text(
                    _initials(author),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (author != null)
                      Text(
                        author,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    if (meta != null)
                      Text(
                        meta,
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
        ],
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: AppRadius.card,
          child: SizedBox(
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(url: story.photoUrl),
                if (caption != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.photo_camera_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
