import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';

class BankAccountsCard extends StatelessWidget {
  const BankAccountsCard({
    required this.accounts,
    required this.selectedId,
    required this.amount,
    required this.onSelect,
    required this.onCopy,
    super.key,
  });

  final List<BankAccount> accounts;
  final String selectedId;
  final int amount;
  final ValueChanged<String> onSelect;
  final void Function(String label, String value) onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Transfer ke Rekening',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jumlah transfer',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        formatRupiah(amount),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Salin jumlah transfer',
                  onPressed: () => onCopy('Jumlah transfer', '$amount'),
                  icon: const Icon(Icons.copy_outlined, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final a in accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AccountTile(
                account: a,
                selected: a.id == selectedId,
                onSelect: () => onSelect(a.id),
                onCopy: () => onCopy('Nomor rekening', a.accountNumber),
              ),
            ),
          const SizedBox(height: 4),
          const Text(
            'Transfer tepat sesuai jumlah, lalu unggah bukti transfer di bawah.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.selected,
    required this.onSelect,
    required this.onCopy,
  });

  final BankAccount account;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Rekening ${account.bankName}',
      child: Material(
        color: selected
            ? AppColors.coral.withValues(alpha: 0.15)
            : AppColors.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.bankName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        account.accountNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'a.n. ${account.accountHolder}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Salin nomor rekening',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_outlined, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
