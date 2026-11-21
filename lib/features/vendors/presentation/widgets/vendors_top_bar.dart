import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

class VendorsTopBar extends StatelessWidget {
  const VendorsTopBar({
    required this.onChat,
    required this.onProfile,
    super.key,
  });

  final VoidCallback onChat;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Vendors', style: AppTypography.heading(26))),
        IconButton(
          tooltip: 'Chat admin',
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
