import 'dart:io';

import 'package:flutter/material.dart';
import 'package:w51/core/widgets/app_image.dart';

/// Foto profil: dari file di perangkat bila ada, selain itu dari URL, selain
/// itu ikon orang.
class AvatarImage extends StatelessWidget {
  const AvatarImage({this.path, this.url, super.key});

  final String? path;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null) return AppImage(url: url, icon: Icons.person);
    return Image.file(
      File(p),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
          AppImage(url: url, icon: Icons.person),
    );
  }
}
