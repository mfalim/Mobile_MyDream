import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';

class PaymentTotalCard extends StatelessWidget {
  const PaymentTotalCard({
    required this.guests,
    required this.packagePrice,
    required this.couponDiscount,
    required this.dueLabel,
    required this.dueNow,
    super.key,
  });

  final int guests;
  final int packagePrice;
  final int couponDiscount;
  final String dueLabel;
  final int dueNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          _Line(
            guests > 0 ? 'Harga Pesanan ($guests tamu)' : 'Harga Pesanan',
            formatRupiah(packagePrice),
          ),
          if (couponDiscount > 0)
            _Line(
              'Potongan Kupon Promo',
              '- ${formatRupiah(couponDiscount)}',
              valueColor: AppColors.primary,
            ),
          const Divider(height: 22, color: AppColors.outline),
          Row(
            children: [
              Expanded(
                child: Text(
                  dueLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatRupiah(dueNow),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
