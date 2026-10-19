import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

/// Pengganti foto sementara. Ganti dengan Image.asset / CachedNetworkImage
/// saat gambar asli tersedia.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    this.icon = Icons.image_outlined,
    this.borderRadius,
    super.key,
  });

  final IconData icon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 36,
          color: AppColors.textSecondary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
