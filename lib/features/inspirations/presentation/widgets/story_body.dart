import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

class StoryBody extends StatelessWidget {
  const StoryBody({
    required this.stats,
    required this.body,
    required this.quote,
    super.key,
  });

  final List<StoryStat> stats;
  final String body;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: AppRadius.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in stats)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        s.label.toUpperCase(),
                        style: AppTypography.eyebrow.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(body, style: const TextStyle(fontSize: 15, height: 1.7)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: AppRadius.card,
          ),
          child: Text(
            quote,
            style: AppTypography.heading(
              20,
            ).copyWith(fontStyle: FontStyle.italic, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
