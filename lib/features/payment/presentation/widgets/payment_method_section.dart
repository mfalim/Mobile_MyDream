import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final String selectedId;
  final ValueChanged<String> onChanged;

  Widget _vaRow(PaymentMethod a, PaymentMethod b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MethodChip(
                method: a,
                selected: selectedId == a.id,
                onTap: () => onChanged(a.id),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MethodChip(
                method: b,
                selected: selectedId == b.id,
                onTap: () => onChanged(b.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Metode Pembayaran',
                style: AppTypography.heading(22),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Aman & Terverifikasi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.eyebrow.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_outlined,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Virtual Account (Verifikasi Otomatis)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const BadgePill('Bebas Biaya'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _vaRow(kVirtualAccounts[0], kVirtualAccounts[1]),
                    _vaRow(kVirtualAccounts[2], kVirtualAccounts[3]),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _MethodTile(
                method: kQrisMethod,
                icon: Icons.qr_code_2,
                badge: 'Instan',
                subtitle: 'Konfirmasi instan realtime tanpa unggah struk',
                selected: selectedId == kQrisMethod.id,
                onTap: () => onChanged(kQrisMethod.id),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _MethodTile(
                method: kCardMethod,
                icon: Icons.credit_card,
                badge: 'Hingga 24 Bulan',
                subtitle: 'BCA, Mandiri, CIMB, BRI, Digibank dengan proteksi '
                    '3D-Secure',
                selected: selectedId == kCardMethod.id,
                onTap: () => onChanged(kCardMethod.id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: method.label,
      child: Material(
        color: selected
            ? AppColors.coral.withValues(alpha: 0.2)
            : AppColors.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    method.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.icon,
    required this.badge,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final IconData icon;
  final String badge;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: method.label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.12)
              : Colors.transparent,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          method.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        BadgePill(
                          badge,
                          background: AppColors.coral.withValues(alpha: 0.25),
                          foreground: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
