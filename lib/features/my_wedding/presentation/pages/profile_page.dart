import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/presentation/providers/profile_provider.dart';
import 'package:w51/features/my_wedding/presentation/widgets/profile_footer.dart';
import 'package:w51/features/my_wedding/presentation/widgets/profile_header_card.dart';
import 'package:w51/features/my_wedding/presentation/widgets/settings_section.dart';
import 'package:w51/features/my_wedding/presentation/widgets/vision_board_card.dart';
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/my_wedding/presentation/providers/wedding_date_provider.dart';

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

  Future<void> _pickWeddingDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = ref.read(weddingDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
      helpText: 'Pilih tanggal pernikahan',
    );
    if (picked == null || !mounted) return;
    ref.read(weddingDateProvider.notifier).setDate(picked);
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
    final messenger = ScaffoldMessenger.of(context);
    context.go(AppRoutes.home);
    auth.signOut();
    cart.clear();
    checkout.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu sudah keluar.')));
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(profileDataProvider);
    return SafeArea(
      bottom: false,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: 'Profil gagal dimuat.',
          onRetry: () => ref.invalidate(profileDataProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(ProfileData p) {
    const gap = SizedBox(height: AppSpacing.lg);
    final weddingDate = ref.watch(weddingDateProvider);
    final cartCount = ref.watch(cartProvider).items.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        ProfileHeaderCard(
          profile: p,
          weddingDateLabel: formatDateShortId(weddingDate),
          daysLeft: daysUntil(weddingDate),
          cartCount: cartCount,
          onEditPhoto: () => _soon('Ganti foto profil'),
          onSetDate: _pickWeddingDate,
          onStat: (i) {
            if (i == 2) {
              context.push(AppRoutes.cart);
            } else {
              _soon(i == 0 ? 'Inspirasi board' : 'Riwayat vendor');
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        VisionBoardCard(
          boards: p.boards,
          newCollections: p.newCollections,
          lastUpdateLabel: p.lastUpdateLabel,
          onOpen: (b) => _soon('Board ${b.label}'),
          onCreate: () => _soon('Buat board'),
          onOpenAll: () => _soon('Semua board'),
        ),
        gap,
        SettingsSection(
          title: 'Akun & Transaksi',
          children: [
            SettingsTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Pengaturan Akun & Profil',
              subtitle: 'Email, nomor WhatsApp, kata sandi',
              onTap: () => _soon('Pengaturan akun'),
            ),
            SettingsTile(
              icon: Icons.shopping_bag_outlined,
              iconBackground: AppColors.gold,
              title: 'Aura Pay & Cicilan 0%',
              badge: 'Promo',
              subtitle: 'Rekap DP, escrow aman, tenor s.d 24 bulan',
              onTap: () => _soon('Aura Pay'),
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
              onTap: () => _soon('Preferensi notifikasi'),
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
              badge: '24/7 VIP',
              subtitle: 'Bantuan kurasi vendor & penawaran harga',
              onTap: () => _soon('Concierge planner'),
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
              onTap: () => _soon('Syarat & ketentuan'),
            ),
            SettingsTile(
              icon: Icons.help_outline,
              title: 'Laporkan Kendala Teknis',
              subtitle: 'Kirimkan masukan atau bug aplikasi',
              onTap: () => _soon('Laporan kendala'),
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
        ProfileFooter(version: p.appVersion),
      ],
    );
  }
}
