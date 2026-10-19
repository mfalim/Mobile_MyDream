import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/widgets/search_field.dart';

class VendorsSearchSection extends StatelessWidget {
  const VendorsSearchSection({
    required this.controller,
    required this.popular,
    required this.filters,
    required this.onFilterTap,
    super.key,
  });

  final TextEditingController controller;
  final List<String> popular;
  final List<String> filters;
  final ValueChanged<String> onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          controller: controller,
          hint: 'Cari vendor, ballroom, atau tema...',
          trailingIcon:
              controller.text.isEmpty ? Icons.tune : Icons.close_rounded,
          onTrailingTap: controller.text.isEmpty
              ? () => onFilterTap('Filter')
              : controller.clear,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'POPULER:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              for (final term in popular)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Chip(
                    label: term,
                    background: AppColors.surfaceTint,
                    foreground: AppColors.textPrimary,
                    onTap: () => controller.text = term,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < filters.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Chip(
                    label: filters[i],
                    selected: i == 0,
                    background: i == 0 ? AppColors.primary : AppColors.surface,
                    foreground: i == 0 ? Colors.white : AppColors.textPrimary,
                    leading: i == 1 ? Icons.place_outlined : null,
                    trailing: i <= 1 ? Icons.keyboard_arrow_down : null,
                    outlined: i != 0,
                    onTap: () => onFilterTap(filters[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.selected = false,
    this.outlined = false,
    this.leading,
    this.trailing,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool selected;
  final bool outlined;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: StadiumBorder(
        side: outlined
            ? const BorderSide(color: AppColors.outline)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  Icon(leading, size: 16, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  Icon(trailing, size: 18, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
