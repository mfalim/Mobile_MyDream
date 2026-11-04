import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/config/app_features.dart';

/// "Estimasi Waktu Pelaksanaan".
class EstimateCard extends StatelessWidget {
  const EstimateCard({required this.dateLabel, super.key});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event_available_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimasi Waktu Pelaksanaan: $dateLabel',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Slot tanggal telah dikunci sementara selama 24 jam untuk '
                  'reservasi Anda.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VoucherTile extends StatelessWidget {
  const VoucherTile({
    required this.subtitle,
    required this.onTap,
    this.subtitleColor = AppColors.primary,
    super.key,
  });

  final String subtitle;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voucher Pernikahan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class TrustTiles extends StatelessWidget {
  const TrustTiles({super.key});

  @override
  Widget build(BuildContext context) {
    // Klaim yang belum diputuskan owner hanya tampil bila AppFeatures.escrowClaims
    // menyala; selain itu teksnya apa adanya.
    const claims = AppFeatures.escrowClaims;
    // IntrinsicHeight: tinggi dua kotak disamakan tanpa meminta tinggi tak terhingga.
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Tile(
              icon:
                  claims ? Icons.lock_outline : Icons.account_balance_outlined,
              title: claims ? '100% Escrow Protection' : 'Transfer Bank',
              note: claims
                  ? 'Dana cair setelah H+1'
                  : 'Bukti transfer diperiksa admin',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _Tile(
              icon: Icons.headset_mic_outlined,
              title: claims ? 'Wedding Concierge' : 'Bantuan WhatsApp',
              note: claims
                  ? 'Asistensi 24/7 personal'
                  : 'Tanya admin langsung lewat chat',
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.note});

  final IconData icon;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
