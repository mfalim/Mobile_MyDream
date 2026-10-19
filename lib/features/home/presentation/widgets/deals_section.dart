import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/horizontal_card_list.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/core/widgets/section_header.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

class DealsSection extends StatelessWidget {
  const DealsSection({
    required this.deals,
    required this.onClaim,
    this.onSeeAll,
    super.key,
  });

  final List<DealItem> deals;
  final ValueChanged<DealItem> onClaim;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'Penawaran Terbatas',
          eyebrowIcon: Icons.local_fire_department_outlined,
          title: 'Deals of the Week',
          actionLabel: 'Lihat Semua',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 12),
        HorizontalCardList(
          children: [
            for (final deal in deals)
              _DealCard(deal: deal, onClaim: () => onClaim(deal)),
          ],
        ),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal, required this.onClaim});

  final DealItem deal;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
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
            height: 170,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ImagePlaceholder(icon: Icons.photo_outlined),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: BadgePill(
                    deal.badge,
                    background:
                        deal.isDiscount ? AppColors.error : AppColors.gold,
                    foreground:
                        deal.isDiscount ? Colors.white : AppColors.onGold,
                  ),
                ),
                if (deal.locationLabel != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: BadgePill(
                      deal.locationLabel!,
                      icon: Icons.place_outlined,
                      background: AppColors.surface,
                      foreground: AppColors.textPrimary,
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BadgePill(
                        deal.tag,
                        background: AppColors.onGold,
                        foreground: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                Row(
                  children: [
                    Icon(
                      deal.detailIcon,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        deal.detail,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (deal.originalPrice != null)
                  Text(
                    formatRupiah(deal.originalPrice!),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  formatRupiah(deal.price),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onClaim,
                  icon: const Icon(Icons.local_offer_outlined, size: 18),
                  label: const Text('Klaim Voucher Deal'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
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
