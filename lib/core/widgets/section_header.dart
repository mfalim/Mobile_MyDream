import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

/// Label kecil + judul serif + tautan aksi, seperti "Deals of the Week".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.eyebrow,
    required this.title,
    this.eyebrowIcon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String eyebrow;
  final String title;
  final IconData? eyebrowIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (eyebrowIcon != null) ...[
                    Icon(eyebrowIcon, size: 14, color: AppColors.onGold),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      eyebrow.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        color: AppColors.onGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(title, style: AppTypography.heading(24)),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}
