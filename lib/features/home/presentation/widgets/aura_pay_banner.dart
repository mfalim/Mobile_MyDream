import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/badge_pill.dart';

class AuraPayBanner extends StatelessWidget {
  const AuraPayBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final onBanner = Colors.white.withValues(alpha: 0.9);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.coral],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BadgePill(
                      'AURA PAY • CICILAN 0%',
                      icon: Icons.credit_card,
                      background: Colors.white.withValues(alpha: 0.2),
                      foreground: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bayar Vendor Impian Tanpa Beban',
                      style: AppTypography.heading(
                        22,
                      ).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nikmati cicilan 0% hingga 24 bulan & jaminan proteksi '
                      'garansi vendor 100%.',
                      style:
                          TextStyle(color: onBanner, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.savings_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bebas DP',
                    style: TextStyle(color: onBanner, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const BadgePill(
                '0% hingga 24 bln',
                background: Colors.white,
                foreground: AppColors.primary,
              ),
              BadgePill(
                'Cashback 5 Juta',
                background: Colors.white.withValues(alpha: 0.2),
                foreground: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
