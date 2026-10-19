import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/core/widgets/section_header.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

class CuratedVendorsSection extends StatefulWidget {
  const CuratedVendorsSection({
    required this.categories,
    required this.vendors,
    this.onSeeAll,
    this.onAsk,
    super.key,
  });

  final List<String> categories;
  final List<CuratedVendor> vendors;
  final VoidCallback? onSeeAll;
  final ValueChanged<CuratedVendor>? onAsk;

  @override
  State<CuratedVendorsSection> createState() => _CuratedVendorsSectionState();
}

class _CuratedVendorsSectionState extends State<CuratedVendorsSection> {
  late String _selected = widget.categories.first;

  List<CuratedVendor> get _filtered => _selected == widget.categories.first
      ? widget.vendors
      : widget.vendors.where((v) => v.category == _selected).toList();

  @override
  Widget build(BuildContext context) {
    final vendors = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'Terpilih & Terpercaya',
          eyebrowIcon: Icons.verified_outlined,
          title: 'Curated Vendors',
          actionLabel: 'Lihat Direktori',
          onAction: widget.onSeeAll,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in widget.categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: category,
                    selected: category == _selected,
                    onTap: () => setState(() => _selected = category),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (vendors.isEmpty)
          const EmptyState(
            message: 'Belum ada vendor di kategori ini.',
            icon: Icons.storefront_outlined,
          )
        else
          for (final vendor in vendors)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VendorCard(
                vendor: vendor,
                onAsk: () => widget.onAsk?.call(vendor),
              ),
            ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.coral.withValues(alpha: 0.3)
          : AppColors.surfaceTint,
      borderRadius: AppRadius.chip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chip,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor, required this.onAsk});

  final CuratedVendor vendor;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImagePlaceholder(
                  icon: Icons.photo_outlined,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: BadgePill(
                    vendor.tag,
                    background: AppColors.onGold,
                    foreground: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.heading(17),
                      ),
                    ),
                    if (vendor.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          size: 16, color: AppColors.onGold),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: AppColors.onGold),
                        const SizedBox(width: 2),
                        Text(
                          '${vendor.rating} (${vendor.reviewCount} ulasan)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    BadgePill(vendor.highlight),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mulai dari',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatRupiah(vendor.startingPrice),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        onTap: onAsk,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Tanya Kuota',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
