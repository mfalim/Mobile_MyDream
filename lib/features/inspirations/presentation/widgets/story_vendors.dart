import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class StoryVendors extends StatelessWidget {
  const StoryVendors({
    required this.title,
    required this.vendors,
    required this.onPortfolio,
    super.key,
  });

  final String title;
  final List<StoryVendor> vendors;
  final ValueChanged<StoryVendor> onPortfolio;

  IconData _icon(StoryVendorKind kind) => switch (kind) {
        StoryVendorKind.planner => Icons.event_note_outlined,
        StoryVendorKind.decor => Icons.local_florist_outlined,
        StoryVendorKind.photographer => Icons.photo_camera_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.verified_outlined, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: AppTypography.heading(20))),
            const SizedBox(width: 8),
            const Text(
              'Terverifikasi Aura',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final v in vendors)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(_icon(v.kind), color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          v.role,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rating ${v.rating} (${v.reviewCount} review)',
                          style: const TextStyle(
                            color: AppColors.onGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => onPortfolio(v),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceTint,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Lihat\nPortofolio',
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
