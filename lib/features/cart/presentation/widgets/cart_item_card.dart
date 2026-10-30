import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    required this.item,
    required this.onToggle,
    required this.onRemove,
    required this.onChat,
    required this.onOpenPackage,
    super.key,
  });

  final CartItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final VoidCallback onChat;
  final VoidCallback onOpenPackage;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            item: item,
            onToggle: onToggle,
            onRemove: onRemove,
            onChat: onChat,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Package(item: item),
                const SizedBox(height: 12),
                _Inclusions(item: item, onDetail: onOpenPackage),
                if (item.cashbackPoints > 0) ...[
                  const SizedBox(height: 10),
                  _PointsRow(item: item),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.installmentMonths > 0
                            ? 'Cicilan 0% hingga ${item.installmentMonths} bln'
                            : 'DP & pelunasan via transfer bank',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: onOpenPackage,
                      child: const Text('Ubah Paket'),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.item,
    required this.onToggle,
    required this.onRemove,
    required this.onChat,
  });

  final CartItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceTint.withValues(alpha: 0.6),
      padding: const EdgeInsets.fromLTRB(6, 8, 4, 8),
      child: Row(
        children: [
          Checkbox(
            value: item.selected,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.outline,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.apartment,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.providerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 15,
                      color: AppColors.onGold,
                    ),
                  ],
                ),
                Text(
                  item.providerSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chat vendor',
            onPressed: onChat,
            icon: const Icon(Icons.chat_bubble_outline, size: 22),
          ),
          // Tombol hapus tidak ada di Figma, tapi keranjang butuh cara membuang item.
          IconButton(
            tooltip: 'Hapus dari keranjang',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Package extends StatelessWidget {
  const _Package({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              if (item.paxIncluded > 0)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: BadgePill(
                    '${item.paxIncluded} Pax',
                    background: Colors.black54,
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
              if (item.savingsBadge.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const BadgePill('Best Price', icon: Icons.verified),
                    BadgePill(
                      item.savingsBadge,
                      background: AppColors.coral.withValues(alpha: 0.4),
                      foreground: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Text(
                item.packageTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              if (item.originalPrice > item.price)
                Text(
                  formatRupiah(item.originalPrice),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatRupiah(item.price),
                  style: AppTypography.heading(20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Inclusions extends StatelessWidget {
  const _Inclusions({required this.item, required this.onDetail});

  final CartItem item;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Vendor dalam paket',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDetail,
                child: const Text('Lihat Detail'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              item.inclusionSummary,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  const _PointsRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, size: 20, color: AppColors.onGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dapatkan ${formatNumber(item.cashbackPoints)} MyDream Points',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Cashback ${item.cashbackPercent}%',
            style: const TextStyle(
              color: AppColors.onGold,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
