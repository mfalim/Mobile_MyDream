import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';

class EscrowGuaranteeCard extends StatelessWidget {
  const EscrowGuaranteeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.outline,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Escrow Protection Guarantee',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Dana Anda aman di rekening bersama Bridestory Escrow. '
                  'Vendor baru dibayar sesuai progres akad kerja.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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
