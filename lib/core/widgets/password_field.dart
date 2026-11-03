import 'package:flutter/material.dart';
import 'package:w51/core/widgets/app_text_field.dart';

/// Kolom kata sandi dengan tombol tampil/sembunyi.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      helperText: widget.helperText,
      validator: widget.validator,
      obscureText: _hidden,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    );
  }
}
