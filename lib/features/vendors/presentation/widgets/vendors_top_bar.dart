import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

class VendorsTopBar extends StatelessWidget {
  const VendorsTopBar({
    required this.onNotifications,
    required this.onChat,
    super.key,
  });

  final VoidCallback onNotifications;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Vendors', style: AppTypography.heading(26))),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Pesan',
          onPressed: onChat,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
        ),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.surfaceTint,
          child: Icon(Icons.person, color: AppColors.primary, size: 20),
        ),
      ],
    );
  }
}
