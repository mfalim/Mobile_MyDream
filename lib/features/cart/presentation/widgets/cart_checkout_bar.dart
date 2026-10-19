import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';

class CartCheckoutBar extends StatelessWidget {
  const CartCheckoutBar({
    required this.total,
    required this.deposit,
    required this.selectedCount,
    required this.onHelp,
    required this.onContinue,
    super.key,
  });

  final int total;
  final int deposit;
  final int selectedCount;
  final VoidCallback onHelp;
  final VoidCallback onContinue;

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
          // Tinggi bar mengikuti isinya (bukan setinggi layar).
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opsi Booking:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BadgePill('DP Tersedia ${formatRupiah(deposit)}'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Bayar:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        formatRupiah(total),
                        style: AppTypography.heading(18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: onHelp,
                    icon: const Icon(Icons.headset_mic_outlined, size: 18),
                    label: const Text('Bantuan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceTint,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: selectedCount == 0 ? null : onContinue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Lanjut ke Validasi Data ($selectedCount Item)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
