import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/badge_pill.dart';

/// Pengganti kartu hitung mundur saat data pernikahan belum diisi.
class CoupleCtaCard extends StatelessWidget {
  const CoupleCtaCard({
    required this.isGuest,
    required this.onStart,
    super.key,
  });

  final bool isGuest;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BadgePill(
            'MULAI DARI SINI',
            icon: Icons.local_florist,
            background: AppColors.surface,
          ),
          const SizedBox(height: 10),
          Text('Rencanakan Hari Bahagiamu', style: AppTypography.heading(24)),
          const SizedBox(height: 6),
          Text(
            isGuest
                ? 'Masuk lalu isi tanggal pernikahanmu untuk melihat hitung '
                    'mundur dan mengisi data pesanan otomatis.'
                : 'Isi nama pasangan dan tanggal pernikahan untuk melihat '
                    'hitung mundur dan mengisi data pesanan otomatis.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(
              isGuest ? 'Masuk & Atur Tanggal' : 'Atur Tanggal Pernikahan',
            ),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
        ],
      ),
    );
  }
}
