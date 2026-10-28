import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/horizontal_card_list.dart';
import 'package:w51/core/widgets/section_header.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

class DealsSection extends StatelessWidget {
  const DealsSection({
    required this.deals,
    required this.onOpen,
    required this.onAction,
    this.onSeeAll,
    super.key,
  });

  final List<DealItem> deals;

  /// Kartu diketuk: buka detail.
  final ValueChanged<DealItem> onOpen;

  /// Tombol di kartu: pasang voucher bila ada, selain itu buka detail.
  final ValueChanged<DealItem> onAction;
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
              _DealCard(
                deal: deal,
                onOpen: () => onOpen(deal),
                onAction: () => onAction(deal),
              ),
          ],
        ),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.deal,
    required this.onOpen,
    required this.onAction,
  });

  final DealItem deal;
  final VoidCallback onOpen;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final badge = deal.badge;
    final tag = deal.tag;
    final location = deal.locationLabel;
    final original = deal.originalPrice;
    final hasVoucher = deal.voucherCode != null;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 170,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(url: deal.photoUrl),
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
                    if (badge != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: BadgePill(
                          badge,
                          background: deal.isDiscount
                              ? AppColors.error
                              : AppColors.gold,
                          foreground:
                              deal.isDiscount ? Colors.white : AppColors.onGold,
                        ),
                      ),
                    if (location != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: BadgePill(
                          location,
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
                          if (tag != null) ...[
                            BadgePill(
                              tag,
                              background: AppColors.onGold,
                              foreground: Colors.white,
                            ),
                            const SizedBox(height: 6),
                          ],
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
                    if (original != null)
                      Text(
                        formatRupiah(original),
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
                      onPressed: onAction,
                      icon: Icon(
                        hasVoucher
                            ? Icons.local_offer_outlined
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(
                        hasVoucher ? 'Klaim Voucher Deal' : 'Lihat Paket',
                      ),
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
        ),
      ),
    );
  }
}
