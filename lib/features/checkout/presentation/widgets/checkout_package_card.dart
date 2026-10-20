import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';

class CheckoutPackageCard extends StatelessWidget {
  const CheckoutPackageCard(
      {required this.item, this.otherCount = 0, super.key});

  final CartItem item;

  /// Jumlah paket lain yang dicentang di keranjang tapi belum diproses.
  final int otherCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PAKET YANG DIPILIH',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const BadgePill(
                'Verified Organizer',
                icon: Icons.verified,
                background: AppColors.surfaceTint,
                foreground: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: ImagePlaceholder(
                  icon: Icons.photo_outlined,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.packageTitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.providerName} • Wedding Organizer',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatRupiah(item.price),
                style: AppTypography.heading(
                  20,
                ).copyWith(color: AppColors.primary),
              ),
              Text(
                formatRupiah(item.originalPrice),
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              BadgePill(item.savingsBadge),
              if (item.paxIncluded > 0)
                Text(
                  '${item.paxIncluded} Pax',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (otherCount > 0) ...[
            const SizedBox(height: 10),
            Text(
              '+ $otherCount paket lain di keranjang belum diproses '
              '(satu pemesanan per vendor).',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
