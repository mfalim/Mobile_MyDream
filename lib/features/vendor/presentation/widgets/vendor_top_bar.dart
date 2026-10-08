import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class VendorTopBar extends StatelessWidget {
  const VendorTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.ink),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Cari vendor',
                style: TextStyle(color: AppColors.muted, fontSize: 15)),
          ),
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Pesan',
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
    );
  }
}
