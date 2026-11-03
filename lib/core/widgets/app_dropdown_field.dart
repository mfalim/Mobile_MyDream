import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/app_text_field.dart';

/// Pilihan satu dari daftar, dengan label di atas seperti [AppTextField].
class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.required = false,
    this.validator,
    super.key,
  });

  final String label;
  final List<String> items;
  final String? value;
  final String? hint;
  final bool required;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide(color: color, width: width),
        );
    final hintText = hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          menuMaxHeight: 360,
          hint: hintText == null ? null : Text(hintText),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            focusedBorder: border(AppColors.primary, 1.5),
            errorBorder: border(AppColors.error),
            focusedErrorBorder: border(AppColors.error, 1.5),
          ),
        ),
      ],
    );
  }
}
