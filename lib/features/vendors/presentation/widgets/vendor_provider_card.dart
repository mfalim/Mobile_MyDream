import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

class VendorProviderCard extends StatelessWidget {
  const VendorProviderCard({required this.provider, this.onVisit, super.key});

  final VendorProviderInfo provider;

  /// Tombol "Kunjungi Profil Vendor" hanya tampil bila diisi (halaman profil
  /// vendor belum ada).
  final VoidCallback? onVisit;

  @override
  Widget build(BuildContext context) {
    final visit = onVisit;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: ImagePlaceholder(
                  icon: Icons.storefront_outlined,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.tagline,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star, size: 18, color: AppColors.onGold),
              const SizedBox(width: 4),
              Text(
                '${provider.rating} (${provider.reviewCount})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (visit != null) ...[
            const SizedBox(height: 14),
            FilledButton(
              onPressed: visit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceTint,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Kunjungi Profil Vendor'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
