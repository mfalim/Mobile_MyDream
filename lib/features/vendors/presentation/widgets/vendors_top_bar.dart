import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

class VendorsTopBar extends StatelessWidget {
  const VendorsTopBar({
    required this.onNotifications,
    required this.onChat,
    required this.onProfile,
    this.unreadCount = 0,
    super.key,
  });

  final VoidCallback onNotifications;
  final VoidCallback onChat;
  final VoidCallback onProfile;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Vendors', style: AppTypography.heading(26))),
        IconButton(
          tooltip: unreadCount > 0
              ? 'Notifikasi, $unreadCount belum dibaca'
              : 'Notifikasi',
          onPressed: onNotifications,
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
        IconButton(
          tooltip: 'Pesan',
          onPressed: onChat,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
        ),
        IconButton(
          tooltip: 'Profil',
          onPressed: onProfile,
          padding: EdgeInsets.zero,
          icon: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceTint,
            child: Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }
}
