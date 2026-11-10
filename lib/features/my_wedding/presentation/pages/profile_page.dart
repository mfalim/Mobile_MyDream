import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/my_wedding/presentation/providers/profile_provider.dart';
import 'package:w51/features/my_wedding/presentation/widgets/profile_footer.dart';
import 'package:w51/features/my_wedding/presentation/widgets/profile_header_card.dart';
import 'package:w51/features/my_wedding/presentation/widgets/settings_section.dart';
import 'package:w51/features/my_wedding/presentation/widgets/vision_board_card.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Keranjang dan isian checkout yang belum selesai akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Ambil dulu semua yang dibutuhkan: halaman ini akan hilang setelah go().
    final auth = ref.read(authProvider.notifier);
    final cart = ref.read(cartProvider.notifier);
    final checkout = ref.read(checkoutProvider.notifier);
    final couple = ref.read(coupleProvider.notifier);
    final receipts = ref.read(receiptProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    context.go(AppRoutes.home);
    auth.signOut();
    cart.clear();
    checkout.clear();
    couple.clear();
    receipts.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu sudah keluar.')));
  }

  @override
  Widget build(BuildContext context) {
    // Data tambahan (papan visi, statistik) hanya pelengkap: bila lambat atau
    // gagal dimuat, Profil tetap tampil tanpa bagian itu.
    final extras = ref.watch(profileDataProvider).value ?? const ProfileData();
    return SafeArea(bottom: false, child: _buildContent(extras));
  }

  Widget _buildContent(ProfileData p) {
    const gap = SizedBox(height: AppSpacing.lg);
    final cartCount = ref.watch(cartProvider).orderCount;
    final couple = ref.watch(coupleProvider);
    final user = ref.watch(authProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        if (user?.role == 'member') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workspace Kru WO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Call Sign: ${user!.callSign ?? '-'} • Tugas Lapangan',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.memberDashboard),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.onGold,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Buka'),
                ),
              ],
            ),
          ),
          gap,
        ],
        ProfileHeaderCard(
          profile: p,
          coupleNames: couple?.profileNames ?? user?.name ?? 'Calon Pengantin',
          weddingDateLabel:
              couple == null ? null : formatDateShortId(couple.weddingDate),
          daysLeft: couple == null ? null : daysUntil(couple.weddingDate),
          cartCount: cartCount,
          avatarUrl: user?.avatarUrl,
          onEditPhoto: () => _soon('Ganti foto profil'),
          onSetDate: () => context.push(AppRoutes.coupleSetup),
          onStat: (stat) {
            switch (stat) {
              case ProfileStat.cart:
                context.push(AppRoutes.cart);
              case ProfileStat.boards:
                _soon('Inspirasi board');
              case ProfileStat.vendors:
                _soon('Riwayat vendor');
            }
          },
        ),
        if (p.boards.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          VisionBoardCard(
            boards: p.boards,
            newCollections: p.newCollections,
            lastUpdateLabel: p.lastUpdateLabel,
            onOpen: (b) => _soon('Board ${b.label}'),
            onCreate: () => _soon('Buat board'),
            onOpenAll: () => _soon('Semua board'),
          ),
        ],
        gap,
        SettingsSection(
          title: 'Akun & Transaksi',
          children: [
            SettingsTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Pengaturan Akun & Profil',
              subtitle: 'Nama dan kata sandi',
              onTap: () => context.push(AppRoutes.account),
            ),
            SettingsTile(
              icon: Icons.shopping_bag_outlined,
              iconBackground: AppColors.gold,
              title: 'MyDream Pay & Cicilan 0%',
              badge: 'Promo',
              subtitle: 'Rekap DP, escrow aman, tenor s.d 24 bulan',
              onTap: () => _soon('MyDream Pay'),
            ),
            SettingsTile(
              icon: Icons.qr_code_2,
              title: 'QR Code Tamu & E-Undangan',
              subtitle: 'Check-in resepsi, sinkronisasi buku tamu',
              onTap: () => _soon('QR code tamu'),
            ),
          ],
        ),
        gap,
        SettingsSection(
          title: 'Preferensi Aplikasi',
          children: [
            SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Preferensi Notifikasi',
              subtitle: 'Jadwal konsultasi vendor, diskon eksklusif',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            SettingsTile(
              icon: Icons.language,
              title: 'Bahasa Tampilan',
              subtitle: 'Bahasa Indonesia / English',
              trailing: PopupMenuButton<String>(
                tooltip: 'Pilih bahasa',
                onSelected: (value) {
                  if (value == 'en') _soon('Bahasa English');
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'id', child: Text('ID (Indonesia)')),
                  PopupMenuItem(value: 'en', child: Text('EN (English)')),
                ],
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ID (Indonesia)',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        gap,
        SettingsSection(
          title: 'Layanan & Bantuan',
          children: [
            SettingsTile(
              icon: Icons.headset_mic_outlined,
              iconBackground: AppColors.coral.withValues(alpha: 0.3),
              title: 'Support & Concierge Planner',
              subtitle:
                  'Bantuan kurasi vendor & penawaran harga lewat WhatsApp',
              onTap: () =>
                  contactAdmin(context, ref, topic: 'concierge planner'),
            ),
            SettingsTile(
              icon: Icons.star_outline,
              title: 'Beri Ulasan di Play Store / App Store',
              subtitle: 'Dukung kami mendampingi lebih banyak pasangan',
              onTap: () => _soon('Ulasan toko aplikasi'),
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Syarat & Ketentuan Layanan',
              subtitle: 'Perlindungan konsumen, kebijakan garansi DP',
              onTap: () => context.push(AppRoutes.infoPath('terms')),
            ),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Kebijakan Privasi',
              subtitle: 'Data yang dikumpulkan dan cara melindunginya',
              onTap: () => context.push(AppRoutes.infoPath('privacy')),
            ),
            SettingsTile(
              icon: Icons.help_outline,
              title: 'Laporkan Kendala Teknis',
              subtitle: 'Kirimkan masukan atau bug aplikasi',
              onTap: () => context.push(AppRoutes.reportIssue),
            ),
          ],
        ),
        gap,
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.power_settings_new, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        gap,
        ProfileFooter(version: AppConfig.appVersion),
      ],
    );
  }
}
