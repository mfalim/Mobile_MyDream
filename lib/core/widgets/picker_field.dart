import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/app_text_field.dart';

/// Kolom yang diketuk untuk memilih (tanggal, jam), atau terkunci bila
/// [onTap] kosong.
class PickerField extends StatelessWidget {
  const PickerField({
    required this.label,
    required this.value,
    required this.icon,
    this.required = false,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool required;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final end = trailing;
    final sub = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        const SizedBox(height: 8),
        Material(
          color: AppColors.surfaceTint,
          borderRadius: AppRadius.button,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.button,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (sub != null)
                          Text(
                            sub,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (end != null) ...[
                    const SizedBox(width: 8),
                    end
                  ] else if (onTap != null)
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
