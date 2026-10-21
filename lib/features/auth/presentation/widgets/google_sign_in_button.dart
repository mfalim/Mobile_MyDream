import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final String label;

  /// Null menonaktifkan tombol (mis. saat permintaan lain sedang berjalan).
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/google_g.svg',
                  width: 20,
                  height: 20,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 12),
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
    );
  }
}
