import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/horizontal_card_list.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/core/widgets/section_header.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

class InspirationsSection extends StatelessWidget {
  const InspirationsSection({required this.articles, this.onSeeAll, super.key});

  final List<InspirationArticle> articles;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'Aura Editorial',
          eyebrowIcon: Icons.menu_book_outlined,
          title: 'Wedding Inspirations',
          actionLabel: 'Artikel Lainnya',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 12),
        HorizontalCardList(
          children: [for (final a in articles) _ArticleCard(article: a)],
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final InspirationArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ImagePlaceholder(icon: Icons.photo_outlined),
                Positioned(
                  top: 10,
                  left: 10,
                  child: BadgePill(
                    article.category,
                    background: AppColors.surface,
                    foreground: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  article.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
