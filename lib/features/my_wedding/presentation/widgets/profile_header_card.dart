import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';

enum ProfileStat { boards, vendors, cart }

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.profile,
    required this.coupleNames,
    required this.cartCount,
    required this.onEditPhoto,
    required this.onSetDate,
    required this.onStat,
    this.weddingDateLabel,
    this.daysLeft,
    this.avatarUrl,
    super.key,
  });

  final ProfileData profile;
  final String coupleNames;

  /// Null bila tanggal pernikahan belum diatur.
  final String? weddingDateLabel;
  final int? daysLeft;
  final int cartCount;
  final String? avatarUrl;
  final VoidCallback onEditPhoto;
  final VoidCallback onSetDate;
  final ValueChanged<ProfileStat> onStat;

  @override
  Widget build(BuildContext context) {
    final dateLabel = weddingDateLabel;
    final days = daysLeft;
    final boards = profile.inspirationBoards;
    final vendors = profile.vendorsContacted;

    // Hanya statistik yang punya data; "Keranjang Aktif" selalu nyata.
    final stats = <(ProfileStat, int, String)>[
      if (boards != null) (ProfileStat.boards, boards, 'Inspirasi Board'),
      if (vendors != null) (ProfileStat.vendors, vendors, 'Vendor Dihubungi'),
      (ProfileStat.cart, cartCount, 'Keranjang Aktif'),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 164,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ImagePlaceholder(icon: Icons.photo_outlined),
                      if (profile.isVerified)
                        const Positioned(
                          top: 12,
                          right: 12,
                          child: BadgePill(
                            'Akun Terverifikasi',
                            icon: Icons.verified_outlined,
                            background: AppColors.surface,
                            foreground: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _Avatar(url: avatarUrl, onEdit: onEditPhoto),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                const BadgePill(
                  'CALON PENGANTIN',
                  icon: Icons.favorite_border,
                  background: AppColors.surfaceTint,
                  foreground: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  coupleNames,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading(26),
                ),
                if (dateLabel != null) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const Text(
                        'Hari Bahagia:',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        dateLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_bottom,
                          color: AppColors.onGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              days == null
                                  ? 'Tanggal pernikahan belum diatur'
                                  : 'Menuju Hari Akad & Resepsi',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              days == null
                                  ? 'Atur untuk mulai hitung mundur'
                                  : days > 0
                                      ? '$days Hari Tersisa'
                                      : days == 0
                                          ? 'Hari Ini!'
                                          : 'Sudah Terlaksana',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: days == null ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: onSetDate,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Atur Tanggal'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in stats)
                      Expanded(
                        child: InkWell(
                          onTap: () => onStat(s.$1),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Text(
                                  '${s.$2}',
                                  style: AppTypography.heading(26),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.$3,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.onEdit});

  final String? url;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: AppImage(url: url, icon: Icons.person),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.surface, width: 2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
