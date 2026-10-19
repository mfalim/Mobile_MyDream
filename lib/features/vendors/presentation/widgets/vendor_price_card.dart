import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

class VendorPriceCard extends StatelessWidget {
  const VendorPriceCard({required this.detail, super.key});

  final VendorDetail detail;

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
              Expanded(
                child: Text(
                  'SPECIAL WEDDING RATE',
                  style: AppTypography.eyebrow.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                formatRupiah(detail.originalPrice),
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatRupiah(detail.price),
                    style: AppTypography.heading(28),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BadgePill(
                'Save ${detail.savePercent}%',
                background: AppColors.coral.withValues(alpha: 0.25),
                foreground: AppColors.primary,
              ),
            ],
          ),
          const Divider(height: 28, color: AppColors.outline),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _Fact(
                icon: Icons.groups_outlined,
                text: '${detail.paxIncluded} Pax Included',
              ),
              _Fact(icon: Icons.wb_sunny_outlined, text: detail.setting),
            ],
          ),
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
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
