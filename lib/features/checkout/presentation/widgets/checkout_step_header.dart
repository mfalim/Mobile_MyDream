import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

class CheckoutStepHeader extends StatelessWidget {
  const CheckoutStepHeader({
    required this.step,
    required this.total,
    required this.caption,
    super.key,
  });

  final int step;
  final int total;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceTint.withValues(alpha: 0.6),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$step',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('LANGKAH $step DARI $total', style: AppTypography.eyebrow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: step / total,
              minHeight: 6,
              backgroundColor: AppColors.outline,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
