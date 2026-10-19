import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

class ProfileFooter extends StatelessWidget {
  const ProfileFooter({required this.version, super.key});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.favorite_border, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'Aura Wedding & Bridestory Partner',
          textAlign: TextAlign.center,
          style: AppTypography.heading(
            20,
          ).copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Versi $version',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 2),
        const Text(
          'Dibuat penuh cinta untuk momen terindah Anda',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
