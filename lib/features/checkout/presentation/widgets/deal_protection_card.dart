import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/core/config/app_features.dart';

class DealProtectionCard extends StatelessWidget {
  const DealProtectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Klaim rekening bersama hanya tampil bila AppFeatures.escrowClaims
    // menyala (menunggu keputusan owner).
    const claims = AppFeatures.escrowClaims;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            claims ? Icons.verified_user : Icons.fact_check_outlined,
            color: AppColors.onGold,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claims
                      ? 'Jaminan MyDream Deal Protection'
                      : 'Pembayaran Diverifikasi Admin',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  claims
                      ? 'Seluruh pembayaran dilindungi rekening bersama. Dana '
                          'baru dicairkan ke vendor sesuai milestone '
                          'penyelesaian kontrak acara.'
                      : 'Pesananmu diperiksa admin MyDream. Pembayaran '
                          'dinyatakan sah setelah bukti transfer '
                          'diverifikasi.',
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
