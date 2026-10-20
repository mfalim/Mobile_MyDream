import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';

/// Hasil: kode voucher terpilih, '' berarti "tanpa voucher", null berarti
/// lembar ditutup tanpa memilih.
Future<String?> showVoucherSheet(
  BuildContext context, {
  required List<Voucher> vouchers,
  required String? selectedCode,
  required int amount,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _VoucherSheet(
      vouchers: vouchers,
      selectedCode: selectedCode,
      amount: amount,
    ),
  );
}

class _VoucherSheet extends StatefulWidget {
  const _VoucherSheet({
    required this.vouchers,
    required this.selectedCode,
    required this.amount,
  });

  final List<Voucher> vouchers;
  final String? selectedCode;
  final int amount;

  @override
  State<_VoucherSheet> createState() => _VoucherSheetState();
}

class _VoucherSheetState extends State<_VoucherSheet> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  String _shortfall(Voucher v) => 'Belanja minimal ${formatRupiah(v.minSpend)} '
      '(kurang ${formatRupiah(v.minSpend - widget.amount)})';

  void _applyTyped() {
    final typed = _code.text.trim().toUpperCase();
    if (typed.isEmpty) {
      setState(() => _error = 'Masukkan kode voucher.');
      return;
    }
    final match = widget.vouchers.where((v) => v.code == typed).firstOrNull;
    if (match == null) {
      setState(() => _error = 'Kode voucher tidak ditemukan.');
      return;
    }
    if (!match.isEligible(widget.amount)) {
      setState(() => _error = _shortfall(match));
      return;
    }
    Navigator.of(context).pop(match.code);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Voucher', style: AppTypography.heading(22)),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: (_) => _applyTyped(),
                      decoration: InputDecoration(
                        hintText: 'Masukkan kode voucher',
                        errorText: _error,
                        errorMaxLines: 2,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _applyTyped,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('Pasang'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final v in widget.vouchers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _VoucherCard(
                    voucher: v,
                    selected: v.code == widget.selectedCode,
                    eligible: v.isEligible(widget.amount),
                    shortfall: _shortfall(v),
                    onTap: () => Navigator.of(context).pop(v.code),
                  ),
                ),
              if (widget.selectedCode != null)
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('Lepas voucher (tanpa voucher)'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.voucher,
    required this.selected,
    required this.eligible,
    required this.shortfall,
    required this.onTap,
  });

  final Voucher voucher;
  final bool selected;
  final bool eligible;
  final String shortfall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: eligible ? 1 : 0.6,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: eligible ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        voucher.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          BadgePill(voucher.code),
                          Text(
                            'Berlaku s/d ${voucher.validUntilLabel}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (!eligible) ...[
                        const SizedBox(height: 6),
                        Text(
                          shortfall,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
