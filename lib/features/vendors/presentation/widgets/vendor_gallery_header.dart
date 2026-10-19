import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';

class VendorGalleryHeader extends StatefulWidget {
  const VendorGalleryHeader({
    required this.photoCount,
    required this.onVirtualTour,
    super.key,
  });

  final int photoCount;
  final VoidCallback onVirtualTour;

  @override
  State<VendorGalleryHeader> createState() => _VendorGalleryHeaderState();
}

class _VendorGalleryHeaderState extends State<VendorGalleryHeader> {
  // Disimpan hanya di memori (prototype).
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.card,
      child: SizedBox(
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ImagePlaceholder(icon: Icons.photo_outlined),
            Positioned(
              left: 12,
              bottom: 12,
              child: Row(
                children: [
                  BadgePill(
                    '1/${widget.photoCount}',
                    icon: Icons.photo_camera_outlined,
                    background: Colors.black54,
                    foreground: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onVirtualTour,
                    borderRadius: AppRadius.chip,
                    child: const BadgePill(
                      'Virtual Tour',
                      icon: Icons.vrpano_outlined,
                      background: Colors.black54,
                      foreground: Colors.white,
                    ),
                  ),
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
