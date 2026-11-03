import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';

class PaymentBar extends StatelessWidget {
  const PaymentBar({
    required this.dueNow,
    required this.buttonLabel,
    required this.onPay,
    this.loading = false,
    super.key,
  });

  final int dueNow;
  final String buttonLabel;

  /// Null menonaktifkan tombol (mis. data belum siap atau sedang mengirim).
  final VoidCallback? onPay;
  final bool loading;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'JUMLAH YANG HARUS DITRANSFER',
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
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onPay,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(loading ? 'Mengirim...' : buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
