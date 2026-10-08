import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: [
          const Text('PROFILE',
              style: TextStyle(
                  color: AppColors.coralDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 7),
          const Text('Akun saya',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded,
                      size: 32, color: AppColors.coralDark),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calon Pengantin',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Lengkapi profil pernikahanmu',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const _ProfileGroup(
            title: 'PERNIKAHAN',
            items: [
              _ProfileItem(Icons.event_outlined, 'Tanggal pernikahan'),
              _ProfileItem(Icons.checklist_rounded, 'Checklist persiapan'),
              _ProfileItem(Icons.bookmark_border_rounded, 'Vendor tersimpan'),
            ],
          ),
          const SizedBox(height: 23),
          const _ProfileGroup(
            title: 'AKUN',
            items: [
              _ProfileItem(Icons.person_outline_rounded, 'Edit profil'),
              _ProfileItem(Icons.notifications_none_rounded, 'Notifikasi'),
              _ProfileItem(Icons.help_outline_rounded, 'Bantuan'),
              _ProfileItem(Icons.logout_rounded, 'Keluar'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.title, required this.items});
  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(item.icon, color: AppColors.ink, size: 21),
            title: Text(item.label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.muted),
            onTap: () {},
          ),
      ],
    );
  }
}

class _ProfileItem {
  const _ProfileItem(this.icon, this.label);
  final IconData icon;
  final String label;
}
