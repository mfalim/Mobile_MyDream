import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/horizontal_card_list.dart';
import 'package:w51/core/widgets/section_header.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class PublicEventsSection extends StatelessWidget {
  const PublicEventsSection({
    required this.events,
    this.onSeeAll,
    this.onOpen,
    super.key,
  });

  final List<PublicEventItem> events;
  final VoidCallback? onSeeAll;
  final ValueChanged<PublicEventItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'Agenda Kegiatan',
          eyebrowIcon: Icons.event_available_outlined,
          title: 'Event & Pameran Mendatang',
          actionLabel: 'Semua Event',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 12),
        HorizontalCardList(
          children: [
            for (final e in events)
              _EventCard(event: e, onTap: () => onOpen?.call(e)),
          ],
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onTap});

  final PublicEventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeBg = switch (event.status) {
      'ongoing' => AppColors.primary,
      'finished' => Colors.black87,
      _ => AppColors.surface,
    };
    final badgeFg = switch (event.status) {
      'ongoing' || 'finished' => Colors.white,
      _ => AppColors.primary,
    };
    final meta = [
      if (event.dateLabel != null && event.dateLabel!.isNotEmpty)
        event.dateLabel!,
      if (event.location != null && event.location!.isNotEmpty) event.location!,
    ].join(' • ');

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 135,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      url: event.photoUrl,
                      icon: Icons.event_outlined,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: BadgePill(
                        event.statusLabel,
                        background: badgeBg,
                        foreground: badgeFg,
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
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
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
    );
  }
}

class InspirationsSection extends StatelessWidget {
  const InspirationsSection({
    required this.articles,
    this.onSeeAll,
    this.onOpen,
    super.key,
  });

  final List<InspirationArticle> articles;
  final VoidCallback? onSeeAll;
  final ValueChanged<InspirationArticle>? onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'MyDream Editorial',
          eyebrowIcon: Icons.menu_book_outlined,
          title: 'Cerita & Tips Pernikahan',
          actionLabel: 'Artikel Lainnya',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 12),
        HorizontalCardList(
          children: [
            for (final a in articles)
              _ArticleCard(article: a, onTap: () => onOpen?.call(a)),
          ],
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});

  final InspirationArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 130,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      url: article.photoUrl,
                      icon: Icons.photo_outlined,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: BadgePill(
                        article.category,
                        background: AppColors.surface,
                        foreground: AppColors.textPrimary,
                      ),
                    ),
                    if (article.rating != null && article.rating! > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: BadgePill(
                          '★ ${article.rating}/5',
                          background: Colors.white,
                          foreground: const Color(0xFFD97706),
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
                    if (article.excerpt.isNotEmpty) ...[
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
