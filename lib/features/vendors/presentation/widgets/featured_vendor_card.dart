import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

class FeaturedVendorCard extends StatefulWidget {
  const FeaturedVendorCard({
    required this.vendor,
    required this.onChat,
    required this.onPricelist,
    super.key,
  });

  final FeaturedVendor vendor;
  final VoidCallback onChat;
  final VoidCallback onPricelist;

  @override
  State<FeaturedVendorCard> createState() => _FeaturedVendorCardState();
}

class _FeaturedVendorCardState extends State<FeaturedVendorCard> {
  // Status simpan hanya di memori (prototype).
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ImagePlaceholder(icon: Icons.photo_outlined),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 60,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      BadgePill(
                        '${v.rating} (${v.reviewCount} reviews)',
                        icon: Icons.star,
                        background: AppColors.surface,
                        foreground: AppColors.textPrimary,
                      ),
                      if (v.badge != null)
                        BadgePill(
                          v.badge!,
                          background: AppColors.gold,
                          foreground: AppColors.onGold,
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    tooltip: _saved ? 'Hapus dari simpanan' : 'Simpan vendor',
                    onPressed: () => setState(() => _saved = !_saved),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: Icon(
                      _saved ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.categoryLabel.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.eyebrow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BadgePill(
                      v.tag,
                      icon: v.tagIcon,
                      background: AppColors.surfaceTint,
                      foreground: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(v.name, style: AppTypography.heading(22)),
                const SizedBox(height: 6),
                Text(
                  v.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _PriceBox(vendor: v),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onChat,
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Chat Vendor'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.surfaceTint,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onPricelist,
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Cek Pricelist'),
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

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.vendor});

  final FeaturedVendor vendor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.priceLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  children: [
                    Text(
                      formatRupiah(vendor.price, prefix: 'Rp'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (vendor.priceUnit != null)
                      Text(
                        vendor.priceUnit!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    if (vendor.originalPrice != null)
                      Text(
                        formatRupiah(vendor.originalPrice!, prefix: 'Rp'),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BadgePill(vendor.promoBadge),
              const SizedBox(height: 6),
              Text(
                vendor.promoNote,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
