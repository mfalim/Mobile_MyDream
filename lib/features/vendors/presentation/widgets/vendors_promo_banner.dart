import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/badge_pill.dart';

class VendorsPromoBanner extends StatelessWidget {
  const VendorsPromoBanner({required this.onClaim, super.key});

  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BadgePill('Pricelist 2026 Ready'),
          const SizedBox(height: 12),
          Text(
            'Bridal Expo & Vendor Deals',
            style: AppTypography.heading(24).copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Dapatkan cashback Bridestory Pay hingga Rp 15 Juta.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onClaim,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(140, 44),
            ),
            child: const Text('Klaim Voucher'),
          ),
        ],
      ),
    );
  }
}
