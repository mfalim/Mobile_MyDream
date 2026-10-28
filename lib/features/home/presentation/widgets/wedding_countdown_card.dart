import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

class WeddingCountdownCard extends StatelessWidget {
  const WeddingCountdownCard({
    required this.countdown,
    required this.coupleNames,
    required this.dateLabel,
    required this.daysLeft,
    this.onDetail,
    super.key,
  });

  /// Kemajuan persiapan; null bila belum ada datanya (bagiannya disembunyikan).
  final WeddingCountdown? countdown;
  final String coupleNames;
  final String dateLabel;
  final int daysLeft;
  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    final readiness = countdown?.readiness;
    final nextTask = countdown?.nextTask;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BadgePill(
                      'WEDDING COUNTDOWN',
                      icon: Icons.local_florist,
                      background: AppColors.surface,
                    ),
                    const SizedBox(height: 10),
                    Text(coupleNames, style: AppTypography.heading(24)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ProgressBadge(daysLeft: daysLeft, readiness: readiness),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (nextTask != null) ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tugas berikutnya: $nextTask',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ] else
                const Spacer(),
              TextButton(
                onPressed: onDetail,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail'),
                    Icon(Icons.chevron_right, size: 18)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.daysLeft, required this.readiness});

  final int daysLeft;
  final double? readiness;

  @override
  Widget build(BuildContext context) {
    final value = readiness;
    final percent = value == null ? null : (value * 100).round();

    return Semantics(
      label: percent == null
          ? '$daysLeft hari lagi'
          : '$daysLeft hari lagi, persiapan $percent persen',
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value ?? 1,
                      strokeWidth: 6,
                      backgroundColor: AppColors.outline,
                      color: value == null
                          ? AppColors.coral.withValues(alpha: 0.4)
                          : AppColors.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$daysLeft', style: AppTypography.heading(22)),
                      const Text(
                        'Hari',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (percent != null) ...[
              const SizedBox(height: 6),
              Text(
                '$percent% Siap',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
