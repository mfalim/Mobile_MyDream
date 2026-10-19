import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/badge_pill.dart';

/// Kartu pilihan skema pembayaran (DP / pelunasan penuh).
class SchemeCard extends StatelessWidget {
  const SchemeCard({
    required this.title,
    required this.badge,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.price,
    required this.description,
    required this.footer,
    required this.selected,
    required this.onTap,
    this.strikePrice,
    super.key,
  });

  final String title;
  final String badge;
  final Color badgeBackground;
  final Color badgeForeground;
  final String price;
  final String? strikePrice;
  final String description;
  final Widget footer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strike = strikePrice;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              BadgePill(
                                badge,
                                background: badgeBackground,
                                foreground: badgeForeground,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    price,
                                    style: AppTypography.heading(28),
                                  ),
                                ),
                              ),
                              if (strike != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  strike,
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
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
              ),
              Container(
                width: double.infinity,
                color: AppColors.surfaceTint,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: footer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
