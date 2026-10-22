import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

/// Dua kartu per baris, tinggi disamakan per baris (aman untuk teks besar).
class FeaturedVendorGrid extends StatelessWidget {
  const FeaturedVendorGrid({
    required this.vendors,
    required this.onOpen,
    required this.onChat,
    super.key,
  });

  final List<FeaturedVendor> vendors;
  final ValueChanged<FeaturedVendor> onOpen;
  final ValueChanged<FeaturedVendor> onChat;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < vendors.length; i += 2) {
      final left = vendors[i];
      final right = i + 1 < vendors.length ? vendors[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FeaturedVendorCard(
                    vendor: left,
                    onOpen: () => onOpen(left),
                    onChat: () => onChat(left),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: right == null
                      ? const SizedBox.shrink()
                      : FeaturedVendorCard(
                          vendor: right,
                          onOpen: () => onOpen(right),
                          onChat: () => onChat(right),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class FeaturedVendorCard extends StatefulWidget {
  const FeaturedVendorCard({
    required this.vendor,
    required this.onOpen,
    required this.onChat,
    super.key,
  });

  final FeaturedVendor vendor;
  final VoidCallback onOpen;
  final VoidCallback onChat;

  @override
  State<FeaturedVendorCard> createState() => _FeaturedVendorCardState();
}

class _FeaturedVendorCardState extends State<FeaturedVendorCard> {
  // Status simpan hanya di memori (prototype).
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;
    final original = v.originalPrice;
    final note = v.priceNote;
    return Semantics(
      button: true,
      label: 'Buka detail ${v.name}',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ImagePlaceholder(icon: Icons.photo_outlined),
                    if (v.badge != null)
                      Positioned(
                        top: 10,
                        left: 8,
                        right: 48,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: BadgePill(v.badge!),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton.filled(
                        tooltip:
                            _saved ? 'Hapus dari simpanan' : 'Simpan vendor',
                        onPressed: () => setState(() => _saved = !_saved),
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                        ),
                        icon: Icon(
                          _saved ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.categoryLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.eyebrow.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading(16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.onGold,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${v.rating} (${v.reviewCount})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      v.priceLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatRupiah(v.price, prefix: 'Rp'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (original != null)
                      Text(
                        formatRupiah(original, prefix: 'Rp'),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    if (note != null)
                      Text(
                        note,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BadgePill(v.promoBadge),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            tooltip: 'Chat vendor',
                            onPressed: widget.onChat,
                            padding: EdgeInsets.zero,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceTint,
                              foregroundColor: AppColors.primary,
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: widget.onOpen,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text(
                              'Pricelist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}
