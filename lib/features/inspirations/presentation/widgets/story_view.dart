import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_body.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_engagement.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_gallery.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_header.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_tips.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_vendors.dart';

/// Satu cerita lengkap. Dipakai di tab Inspirations (cerita utama) dan di
/// halaman cerita. Bagian yang datanya kosong tidak ditampilkan.
class StoryView extends StatefulWidget {
  const StoryView({
    required this.story,
    required this.onPortfolio,
    required this.onShare,
    this.onRelatedPackage,
    super.key,
  });

  final RealWeddingStory story;
  final ValueChanged<StoryVendor> onPortfolio;
  final VoidCallback onShare;

  /// Dipanggil dengan id paket terkait; null menyembunyikan kartu paket.
  final ValueChanged<String>? onRelatedPackage;

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  // Hanya di memori (prototype).
  bool _saved = false;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    const gap = SizedBox(height: AppSpacing.lg);
    final hasBody =
        s.stats.isNotEmpty || s.paragraphs.isNotEmpty || s.quote != null;
    final baseLikes = s.likes;
    final packageId = s.relatedPackageId;
    final onPackage = widget.onRelatedPackage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StoryHeader(
          story: s,
          saved: _saved,
          onSave: () => setState(() => _saved = !_saved),
          onShare: widget.onShare,
        ),
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
            onPortfolio: widget.onPortfolio,
          ),
        ],
        if (s.tips.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          StoryTips(title: s.tipsTitle ?? 'Tips', tips: s.tips),
        ],
        if (packageId != null && onPackage != null) ...[
          gap,
          _RelatedPackageCard(onOpen: () => onPackage(packageId)),
        ],
        if (baseLikes != null || s.reads != null) ...[
          const SizedBox(height: AppSpacing.md),
          StoryEngagement(
            likes: baseLikes == null ? null : baseLikes + (_liked ? 1 : 0),
            reads: s.reads,
            liked: _liked,
            onLike: () => setState(() => _liked = !_liked),
          ),
        ],
      ],
    );
  }
}

class _RelatedPackageCard extends StatelessWidget {
  const _RelatedPackageCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paket terkait',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  'Lihat paket pernikahan dari cerita ini.',
                  style: TextStyle(
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
