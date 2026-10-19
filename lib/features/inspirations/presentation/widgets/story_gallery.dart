import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/horizontal_card_list.dart';
import 'package:w51/core/widgets/image_placeholder.dart';

class StoryGallery extends StatelessWidget {
  const StoryGallery({required this.captions, super.key});

  final List<String> captions;

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
                'Sorotan Visual Hari Bahagia',
                style: AppTypography.heading(20),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${captions.length} Galeri Eksklusif',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HorizontalCardList(
          children: [
            for (final caption in captions)
              SizedBox(
                width: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.card,
                      child: const SizedBox(
                        height: 170,
                        width: 170,
                        child: ImagePlaceholder(icon: Icons.photo_outlined),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
