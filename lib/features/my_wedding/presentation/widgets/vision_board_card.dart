import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';

class VisionBoardCard extends StatelessWidget {
  const VisionBoardCard({
    required this.boards,
    required this.newCollections,
    required this.lastUpdateLabel,
    required this.onOpen,
    required this.onCreate,
    required this.onOpenAll,
    super.key,
  });

  final List<VisionBoard> boards;
  final int newCollections;
  final String lastUpdateLabel;
  final ValueChanged<VisionBoard> onOpen;
  final VoidCallback onCreate;
  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Papan Visi Pernikahan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              BadgePill('$newCollections Koleksi Baru'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ide konsep resepsi, palet dekorasi mawar dusty, dan referensi '
            'gaun pengantin impian Anda.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final board in boards) ...[
                Expanded(
                  child: _BoardThumb(board: board, onTap: () => onOpen(board)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(child: _CreateTile(onTap: onCreate)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pembaruan terakhir: $lastUpdateLabel',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Buka Semua'),
                    Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoardThumb extends StatelessWidget {
  const _BoardThumb({required this.board, required this.onTap});

  final VisionBoard board;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ImagePlaceholder(icon: Icons.photo_outlined),
            Positioned(
              left: 6,
              bottom: 6,
              child: BadgePill(
                board.label,
                background: Colors.black54,
                foreground: Colors.white,
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTile extends StatelessWidget {
  const _CreateTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75,
      child: Material(
        color: AppColors.outline.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary),
              SizedBox(height: 4),
              Text(
                'Buat\nBoard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
