import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';

/// Kartu putih dengan ikon + judul serif, dipakai tiap bagian form.
class CheckoutSection extends StatelessWidget {
  const CheckoutSection({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    final end = trailing;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTypography.heading(20))),
              if (end != null) ...[const SizedBox(width: 8), end],
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(
              sub,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
