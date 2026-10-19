import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';

/// Label di atas kolom isian, dengan tanda * untuk kolom wajib.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {this.required = false, super.key});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.required = false,
    this.maxLines = 1,
    this.prefixText,
    this.helperText,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool required;
  final int maxLines;
  final String? prefixText;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction:
              maxLines > 1 ? TextInputAction.newline : textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: maxLines > 1 ? 3 : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
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
