import 'package:flutter/material.dart';
import 'package:w51/core/config/app_config.dart';
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

  static String? resolveUrl(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed.startsWith('data:')) {
      return null;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final rel = trimmed.replaceFirst(RegExp(r'^/+'), '');
    if (rel.startsWith('storage/') || rel.startsWith('images/')) {
      return '$base/$rel';
    }
    return '$base/storage/$rel';
  }

  @override
  Widget build(BuildContext context) {
    final u = resolveUrl(url);
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
