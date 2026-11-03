import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/badge_pill.dart';

/// Galeri foto vendor yang bisa digeser. Tanpa foto, tampil placeholder.
/// Tombol Virtual Tour hanya muncul bila [onVirtualTour] diberikan.
class VendorGalleryHeader extends StatefulWidget {
  const VendorGalleryHeader({
    required this.photoUrls,
    required this.photoCount,
    this.onVirtualTour,
    super.key,
  });

  final List<String> photoUrls;
  final int photoCount;
  final VoidCallback? onVirtualTour;

  @override
  State<VendorGalleryHeader> createState() => _VendorGalleryHeaderState();
}

class _VendorGalleryHeaderState extends State<VendorGalleryHeader> {
  // Disimpan hanya di memori (prototype).
  bool _liked = false;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = widget.photoUrls.isEmpty ? <String?>[null] : widget.photoUrls;
    final total = widget.photoCount;
    final virtualTour = widget.onVirtualTour;

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: SizedBox(
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => AppImage(url: pages[i]),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Row(
                children: [
                  if (total > 0)
                    BadgePill(
                      '${_index + 1}/$total',
                      icon: Icons.photo_camera_outlined,
                      background: Colors.black54,
                      foreground: Colors.white,
                    ),
                  if (virtualTour != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: virtualTour,
                      borderRadius: AppRadius.chip,
                      child: const BadgePill(
                        'Virtual Tour',
                        icon: Icons.vrpano_outlined,
                        background: Colors.black54,
                        foreground: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: IconButton.filled(
                tooltip: _liked ? 'Batal suka' : 'Suka',
                onPressed: () => setState(() => _liked = !_liked),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                ),
                icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
