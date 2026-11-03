import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({required this.package, required this.onOpen, super.key});

  final WeddingPackage package;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final capacity = package.guestCapacity;
    final period = package.eventPeriod;
    final total = package.vendorsTotal;

    return Semantics(
      button: true,
      label: 'Buka ${package.name}',
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(url: package.photoUrl),
                    if (package.isFeatured)
                      const Positioned(
                        top: 12,
                        left: 12,
                        child: BadgePill('Pilihan Editor', icon: Icons.star),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.name, style: AppTypography.heading(22)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        if (capacity != null)
                          PackageFact(
                            icon: Icons.groups_outlined,
                            text: 'Hingga $capacity tamu',
                          ),
                        PackageFact(
                          icon: Icons.storefront_outlined,
                          text: '${package.vendors.length} vendor',
                        ),
                        if (period != null)
                          PackageFact(
                            icon: Icons.celebration_outlined,
                            text: period,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Harga paket',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (package.price > 0)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            formatRupiah(package.price),
                            style: AppTypography.heading(22),
                          ),
                          if (total != null && package.savings > 0) ...[
                            Text(
                              formatRupiah(total),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            BadgePill(
                              'Hemat ${formatRupiah(package.savings, prefix: 'Rp')}',
                            ),
                          ],
                        ],
                      )
                    else
                      const Text(
                        'Harga menyusul',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: onOpen,
                      child: const Text('Lihat Paket'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu poin kecil dengan ikon, mis. "Hingga 100 tamu".
class PackageFact extends StatelessWidget {
  const PackageFact({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
