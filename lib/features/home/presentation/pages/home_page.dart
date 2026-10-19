import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEDDING PLANNER',
                        style: TextStyle(
                            color: AppColors.coralDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                    SizedBox(height: 5),
                    Text('MyDream',
                        style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                tooltip: 'Notifikasi',
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hari istimewamu dimulai di sini',
                    style: TextStyle(
                        fontSize: 20,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
                SizedBox(height: 8),
                Text(
                    'Temukan inspirasi dan vendor untuk merancang hari terbaikmu.',
                    style: TextStyle(color: AppColors.muted, height: 1.4)),
                SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.favorite_rounded,
                        size: 18, color: AppColors.coralDark),
                    SizedBox(width: 7),
                    Text('Mulai rencanakan',
                        style: TextStyle(
                            color: AppColors.coralDark,
                            fontWeight: FontWeight.w700)),
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: AppColors.coralDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _HomeSectionTitle(
              title: 'Rencanakan pernikahan', action: 'Lihat semua'),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                  child: _QuickAction(
                      icon: Icons.storefront_outlined,
                      title: 'Cari vendor',
                      subtitle: 'Vendor tepercaya')),
              SizedBox(width: 12),
              Expanded(
                  child: _QuickAction(
                      icon: Icons.checklist_rounded,
                      title: 'Checklist',
                      subtitle: 'Persiapanmu')),
            ],
          ),
          const SizedBox(height: 27),
          const _HomeSectionTitle(
              title: 'Inspirasi pilihan', action: 'Jelajahi'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=85',
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 190, color: AppColors.blush),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Perayaan hangat dengan sentuhan taman',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Inspirasi dekorasi • 24 ide',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _HomeSectionTitle extends StatelessWidget {
  const _HomeSectionTitle({required this.title, required this.action});
  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        Text(action,
            style: const TextStyle(
                color: AppColors.coralDark, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.coralDark),
          const SizedBox(height: 13),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(subtitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
