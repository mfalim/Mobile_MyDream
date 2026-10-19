import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/features/checkout/domain/entities/checkout_options.dart';

class GuestTierSelector extends StatelessWidget {
  const GuestTierSelector({
    required this.tiers,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<GuestTier> tiers;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiers.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _TierCard(
                tier: tiers[i],
                selected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final GuestTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      selected: selected,
      label: '${tier.guests} tamu, ${tier.label}, ${tier.note}',
      child: Material(
        color: selected
            ? AppColors.coral.withValues(alpha: 0.3)
            : AppColors.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${tier.guests}', style: AppTypography.heading(24)),
                const SizedBox(height: 2),
                Text(
                  tier.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tier.note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
