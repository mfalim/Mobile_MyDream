import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/features/vendors/domain/entities/vendor_filter.dart';

/// Mengembalikan filter baru, atau null bila lembar ditutup tanpa Terapkan.
Future<VendorFilter?> showVendorFilterSheet(
  BuildContext context, {
  required VendorFilter initial,
  required List<String> categories,
}) {
  return showModalBottomSheet<VendorFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _FilterSheet(initial: initial, categories: categories),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.categories});

  final VendorFilter initial;
  final List<String> categories;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _category = widget.initial.category;
  late String? _city = widget.initial.city;
  late String? _budget = widget.initial.budget?.label;

  VendorFilter get _result {
    final label = _budget;
    return VendorFilter(
      category: _category,
      city: _city,
      budget: label == null
          ? null
          : kBudgetRanges.firstWhere((b) => b.label == label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter Vendor', style: AppTypography.heading(22)),
                    const SizedBox(height: 16),
                    _ChipSection(
                      title: 'Kategori',
                      options: widget.categories,
                      selected: _category,
                      onChanged: (v) => setState(() => _category = v),
                    ),
                    _ChipSection(
                      title: 'Lokasi',
                      options: kCities,
                      selected: _city,
                      onChanged: (v) => setState(() => _city = v),
                    ),
                    _ChipSection(
                      title: 'Estimasi Budget',
                      options: [for (final b in kBudgetRanges) b.label],
                      selected: _budget,
                      onChanged: (v) => setState(() => _budget = v),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _category = null;
                      _city = null;
                      _budget = null;
                    }),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_result),
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(o),
                selected: o == selected,
                onSelected: (on) => onChanged(on ? o : null),
                selectedColor: AppColors.coral.withValues(alpha: 0.3),
                backgroundColor: AppColors.surfaceTint,
                side: BorderSide.none,
                shape: const StadiumBorder(),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
