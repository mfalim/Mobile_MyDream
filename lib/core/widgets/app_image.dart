import 'package:flutter/material.dart';
import 'package:w51/core/widgets/image_placeholder.dart';

/// Gambar dari URL. Memakai placeholder bila URL kosong, sedang dimuat,
/// atau gagal dimuat. Nanti boleh diganti dengan cached_network_image tanpa
/// mengubah pemakainya.
class AppImage extends StatelessWidget {
  const AppImage({
    this.url,
    this.icon = Icons.photo_outlined,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? url;
  final IconData icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return ImagePlaceholder(icon: icon);
    return Image.network(
      u,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : ImagePlaceholder(icon: icon),
      errorBuilder: (context, error, stack) => ImagePlaceholder(icon: icon),
    );
  }
}
