import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

Future<void> _showFrame(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.heading(22)),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}

/// Simulasi cicilan 0% (hanya hitungan, bukan persetujuan).
Future<void> showInstallmentSheet(
  BuildContext context, {
  required int price,
  required int maxMonths,
}) =>
    _showFrame(
      context,
      title: 'Simulasi Cicilan 0%',
      child: _InstallmentBody(price: price, maxMonths: maxMonths),
    );

Future<void> showPointsSheet(
  BuildContext context, {
  required int price,
  required double percent,
  required int points,
}) =>
    _showFrame(
      context,
      title: 'MyDream Points',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Panel(
            children: [
              _Row('Nilai paket', formatRupiah(price)),
              _Row('Cashback $percent%', formatRupiah(points * 100)),
              const Divider(height: 20, color: AppColors.outline),
              _Row('MyDream Points yang didapat', formatNumber(points),
                  bold: true),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Contoh prototype: 1 poin = Rp 100. Aturan resmi penukaran poin '
            'mengikuti kebijakan MyDream Pay.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

Future<void> showAllInclusionsSheet(
  BuildContext context, {
  required List<PackageSection> sections,
}) =>
    _showFrame(
      context,
      title: 'Semua yang Termasuk',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in sections) ...[
            Text(s.title, style: AppTypography.heading(18)),
            const SizedBox(height: 2),
            Text(
              s.subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in s.inclusions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item, style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );

class _InstallmentBody extends StatefulWidget {
  const _InstallmentBody({required this.price, required this.maxMonths});

  final int price;
  final int maxMonths;

  @override
  State<_InstallmentBody> createState() => _InstallmentBodyState();
}

class _InstallmentBodyState extends State<_InstallmentBody> {
  late final List<int> _tenors = () {
    final list = [3, 6, 12, 24].where((m) => m <= widget.maxMonths).toList();
    return list.isEmpty ? [widget.maxMonths] : list;
  }();
  late int _months = _tenors.last;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih tenor',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in _tenors)
              ChoiceChip(
                label: Text('$m bulan'),
                selected: m == _months,
                onSelected: (_) => setState(() => _months = m),
                selectedColor: AppColors.coral.withValues(alpha: 0.3),
                backgroundColor: AppColors.surfaceTint,
                side: BorderSide.none,
                shape: const StadiumBorder(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Panel(
          children: [
            _Row(
              'Cicilan per bulan',
              formatRupiah(widget.price ~/ _months),
              bold: true,
            ),
            const SizedBox(height: 6),
            _Row('Total pembayaran', formatRupiah(widget.price)),
            const SizedBox(height: 6),
            const _Row('Bunga', '0%'),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Simulasi saja. Persetujuan cicilan mengikuti kebijakan penyedia '
          'cicilan, dan nominal dibulatkan ke bawah.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: bold ? 17 : 14,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
