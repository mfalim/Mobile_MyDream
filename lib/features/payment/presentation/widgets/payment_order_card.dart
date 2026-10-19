import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/image_placeholder.dart';

class PaymentOrderCard extends StatelessWidget {
  const PaymentOrderCard({
    required this.providerName,
    required this.packageTitle,
    required this.dateLabel,
    required this.guests,
    required this.packagePrice,
    required this.originalPrice,
    super.key,
  });

  final String providerName;
  final String packageTitle;
  final String dateLabel;
  final int guests;
  final int packagePrice;
  final int originalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
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
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 15,
                          color: AppColors.onGold,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      packageTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$dateLabel • $guests Pax',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Nilai Paket Wedding',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(originalPrice),
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      formatRupiah(packagePrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
