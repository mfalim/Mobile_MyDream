import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/proof_rules.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

class DpReminderCard extends ConsumerStatefulWidget {
  const DpReminderCard({
    required this.booking,
    super.key,
  });

  final ClientBookingSummary booking;

  @override
  ConsumerState<DpReminderCard> createState() => _DpReminderCardState();
}

class _DpReminderCardState extends ConsumerState<DpReminderCard> {
  bool _paying = false;
  bool _uploadingProof = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _payViaMidtrans() async {
    if (_paying || _uploadingProof) return;
    setState(() => _paying = true);

    final b = widget.booking;
    final scheme = b.isDpPaid ? 'remaining' : 'dp';

    try {
      final session =
          await ref.read(paymentsRepositoryProvider).initiateMidtransForBooking(
                bookingId: b.id,
                scheme: scheme,
              );
      final uri = Uri.parse(session.redirectUrl);
      var launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        _snack('Tidak dapat membuka halaman pembayaran Midtrans.');
      }
      ref.invalidate(clientBookingsProvider);
    } catch (_) {
      _snack('Gagal menyiapkan pembayaran Midtrans. Coba lagi.');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _attachOptionalProof() async {
    if (_paying || _uploadingProof) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final name = file.name.contains('.') ? file.name : file.path;
    final bytes = await file.length();
    final err = validateProofFile(name: name, bytes: bytes);
    if (err != null) {
      _snack(err);
      return;
    }

    setState(() => _uploadingProof = true);
    try {
      final b = widget.booking;
      await ref.read(paymentsRepositoryProvider).attachOptionalProof(
            bookingId: b.id,
            scheme: b.isDpPaid ? 'remaining' : 'dp',
            proofPath: file.path,
            proofName: name,
          );
      ref.invalidate(clientBookingsProvider);
      _snack('Foto bukti berhasil dilampirkan.');
    } catch (_) {
      _snack('Gagal mengunggah foto bukti.');
    } finally {
      if (mounted) setState(() => _uploadingProof = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final isWarning = b.isOverdue || b.isUrgent;
    final accentColor = b.isOverdue
        ? AppColors.error
        : (b.isUrgent
            ? const Color(0xFFD97706)
            : (b.isDpPaid ? AppColors.primary : AppColors.gold));

    final statusText = b.isOverdue
        ? 'Melewati Tenggat Pembayaran'
        : b.isDpPaid
            ? (b.isUrgent
                ? 'Segera Jatuh Tempo H-14 (${b.percentPaid}% Terbayar)'
                : 'Sedang Masa DP (${b.percentPaid}% Terbayar)')
            : (b.paymentStatus == 'awaiting_verification'
                ? 'Menunggu Verifikasi'
                : 'Menunggu Pembayaran DP (${b.dpPercent}%)');

    String? deadlineLabel;
    if (b.deadline != null) {
      final dateStr = formatDateShortId(b.deadline!);
      if (b.isOverdue) {
        deadlineLabel = 'Melewati tenggat ($dateStr) — segera selesaikan';
      } else if (b.daysToDeadline == 0) {
        deadlineLabel = 'Jatuh tempo hari ini ($dateStr)';
      } else if (b.daysToDeadline != null) {
        final prefix =
            b.deadlineType == 'dp' ? 'Batas DP' : 'Tenggat lunas (H-14)';
        deadlineLabel = '$prefix: $dateStr (${b.daysToDeadline} hari lagi)';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: b.isOverdue
              ? AppColors.error.withValues(alpha: 0.45)
              : accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Perbarui status pembayaran',
                onPressed: () => ref.invalidate(clientBookingsProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            b.title,
            style: AppTypography.heading(18),
          ),
          if (b.invoiceNumber != null) ...[
            const SizedBox(height: 2),
            Text(
              'Invoice ${b.invoiceNumber}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (b.percentPaid / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.textSecondary.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terbayar: ${formatRupiah(b.paid)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Sisa: ${formatRupiah(b.remaining)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (deadlineLabel != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isWarning ? accentColor : AppColors.gold)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isWarning
                        ? Icons.warning_amber_rounded
                        : Icons.event_available_outlined,
                    size: 15,
                    color: isWarning ? accentColor : AppColors.gold,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      deadlineLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: b.isOverdue
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: (_paying || _uploadingProof) ? null : _payViaMidtrans,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  icon: _paying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.payment_rounded, size: 18),
                  label: Text(
                    b.isDpPaid
                        ? 'Lunasi Sekarang'
                        : 'Bayar DP (${formatRupiah(b.dpAmount)})',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed:
                    (_paying || _uploadingProof) ? null : _attachOptionalProof,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: _uploadingProof
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Bukti (Opsional)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
