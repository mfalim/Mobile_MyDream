import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';

class PaymentBar extends StatelessWidget {
  const PaymentBar({
    required this.dueNow,
    required this.buttonLabel,
    required this.onPay,
    super.key,
  });

  final int dueNow;
  final String buttonLabel;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KEWAJIBAN PEMBAYARAN SAAT INI',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatRupiah(dueNow),
                            style: AppTypography.heading(
                              24,
                            ).copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 20,
                    color: AppColors.onGold,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Bridestory\nProtection',
                    style: TextStyle(
                      color: AppColors.onGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.lock_outline, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
