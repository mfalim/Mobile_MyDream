import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/presentation/widgets/more_stories_list.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_body.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_engagement.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_gallery.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_header.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_tips.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_vendors.dart';

/// Satu cerita lengkap. Dipakai di tab Inspirations (cerita utama) dan di
/// halaman cerita. Bagian yang datanya kosong tidak ditampilkan.
class StoryView extends StatelessWidget {
  const StoryView({
    required this.story,
    required this.onOpenVendor,
    this.onRelatedPackage,
    this.onOpenRelatedStory,
    super.key,
  });

  final RealWeddingStory story;
  final ValueChanged<StoryVendor> onOpenVendor;

  /// Dipanggil dengan id paket terkait; null menyembunyikan kartu paket.
  final ValueChanged<String>? onRelatedPackage;
  final ValueChanged<StoryTeaser>? onOpenRelatedStory;

  @override
  Widget build(BuildContext context) {
    final s = story;
    const gap = SizedBox(height: AppSpacing.lg);
    final hasBody =
        s.stats.isNotEmpty || s.paragraphs.isNotEmpty || s.quote != null;
    final packageId = s.relatedPackageId;
    final onPackage = onRelatedPackage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StoryHeader(story: s),
        if (hasBody) ...[
          const SizedBox(height: AppSpacing.md),
          StoryBody(stats: s.stats, paragraphs: s.paragraphs, quote: s.quote),
        ],
        if (s.gallery.isNotEmpty) ...[gap, StoryGallery(photos: s.gallery)],
        if (s.vendors.isNotEmpty) ...[
          gap,
          StoryVendors(
            title: s.vendorsTitle ?? 'Vendor Pilihan',
            vendors: s.vendors,
            onOpen: onOpenVendor,
          ),
        ],
        if (s.tips.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          StoryTips(title: s.tipsTitle ?? 'Tips', tips: s.tips),
        ],
        if (packageId != null && onPackage != null) ...[
          gap,
          _RelatedPackageCard(
            packageName: s.relatedPackageName,
            onOpen: () => onPackage(packageId),
          ),
        ],
        if (s.likes != null || s.reads != null) ...[
          const SizedBox(height: AppSpacing.md),
          StoryEngagement(likes: s.likes, reads: s.reads),
        ],
        if (s.related.isNotEmpty && onOpenRelatedStory != null) ...[
          gap,
          const Divider(color: AppColors.outline),
          gap,
          MoreStoriesList(
            title: 'Artikel Terkait',
            stories: s.related,
            onOpen: onOpenRelatedStory!,
          ),
        ],
      ],
    );
  }
}

class _RelatedPackageCard extends StatelessWidget {
  const _RelatedPackageCard({required this.onOpen, this.packageName});

  final VoidCallback onOpen;
  final String? packageName;

  @override
  Widget build(BuildContext context) {
    final pkgName = packageName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paket terkait',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  pkgName != null && pkgName.isNotEmpty
                      ? 'Lihat paket pernikahan: $pkgName'
                      : 'Lihat paket pernikahan dari cerita ini.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Lihat Paket'),
          ),
        ],
      ),
    );
  }
}
