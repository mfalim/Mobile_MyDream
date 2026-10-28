import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/icon_mapper.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

class VendorPriceCard extends StatelessWidget {
  const VendorPriceCard({required this.detail, super.key});

  final VendorDetail detail;

  @override
  Widget build(BuildContext context) {
    final d = detail;
    final original = d.originalPrice;
    final percent = d.savePercent;
    final hasDiscount = d.savings > 0 && original != null;

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
              Expanded(
                child: Text(
                  hasDiscount ? 'SPECIAL WEDDING RATE' : 'HARGA VENDOR',
                  style: AppTypography.eyebrow.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (hasDiscount)
                Text(
                  formatRupiah(original),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (d.price > 0)
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatRupiah(d.price),
                      style: AppTypography.heading(28),
                    ),
                  ),
                ),
                if (percent != null) ...[
                  const SizedBox(width: 8),
                  BadgePill(
                    'Save $percent%',
                    background: AppColors.coral.withValues(alpha: 0.25),
                    foreground: AppColors.primary,
                  ),
                ],
              ],
            )
          else
            const Text(
              'Harga menyusul',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (d.facts.isNotEmpty) ...[
            const Divider(height: 28, color: AppColors.outline),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                for (final f in d.facts)
                  _Fact(icon: iconFor(f.iconKey), text: f.text),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child:
              Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
