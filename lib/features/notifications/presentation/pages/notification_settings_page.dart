import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/features/notifications/presentation/providers/notification_prefs_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final c = ref.read(notificationPrefsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.myWedding);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Preferensi Notifikasi', style: AppTypography.heading(18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Material(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  value: prefs.orders,
                  onChanged: c.setOrders,
                  title: const Text('Pesanan & pembayaran'),
                  subtitle:
                      const Text('Konfirmasi pesanan dan status pembayaran'),
                ),
                const Divider(height: 1, color: AppColors.outline),
                SwitchListTile(
                  value: prefs.reminders,
                  onChanged: c.setReminders,
                  title: const Text('Pengingat jadwal'),
                  subtitle: const Text('Konsultasi vendor dan tanggal penting'),
                ),
                const Divider(height: 1, color: AppColors.outline),
                SwitchListTile(
                  value: prefs.promos,
                  onChanged: c.setPromos,
                  title: const Text('Promo & diskon'),
                  subtitle: const Text('Voucher dan penawaran eksklusif'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pengaturan ini baru tersimpan di aplikasi dan akan hilang saat '
            'aplikasi ditutup. Nanti disimpan di akunmu.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
