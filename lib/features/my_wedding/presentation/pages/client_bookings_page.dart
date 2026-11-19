import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

class ClientBookingsPage extends ConsumerStatefulWidget {
  const ClientBookingsPage({super.key});

  @override
  ConsumerState<ClientBookingsPage> createState() => _ClientBookingsPageState();
}

class _ClientBookingsPageState extends ConsumerState<ClientBookingsPage> {
  String _filter = 'all'; // all, unpaid, paid
  int? _payingBookingId;

  Future<void> _refresh() async {
    ref.invalidate(clientBookingsProvider);
    await ref.read(clientBookingsProvider.future);
  }

  Future<void> _payBooking(ClientBookingSummary b) async {
    if (_payingBookingId != null) return;
    setState(() => _payingBookingId = b.id);

    final scheme = b.isDpPaid ? 'remaining' : 'dp';
    final repo = ref.read(paymentsRepositoryProvider);

    try {
      final session = await repo.initiateMidtransForBooking(
        bookingId: b.id,
        scheme: scheme,
      );
      final uri = Uri.parse(session.redirectUrl);
      var launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (mounted) {
        await _refresh();
      }
    } on ValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyiapkan pembayaran Midtrans.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _payingBookingId = null);
    }
  }

  void _showTransactionsSheet(ClientBookingSummary booking) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BookingTransactionsSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(clientBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pembelian', style: AppTypography.heading(20)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: 'Gagal memuat riwayat pembelian.',
          onRetry: _refresh,
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const EmptyState(
                      message: 'Belum ada riwayat pembelian paket atau vendor.',
                      icon: Icons.receipt_long_outlined,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.packages),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(220, 48),
                      ),
                      child: const Text('Jelajahi Paket Pernikahan'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filtered = bookings.where((b) {
            return switch (_filter) {
              'unpaid' => b.needsPayment,
              'paid' => b.isPaid,
              _ => true,
            };
          }).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FilterTab(
                        label: 'Semua (${bookings.length})',
                        selected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterTab(
                        label:
                            'Belum Lunas (${bookings.where((b) => b.needsPayment).length})',
                        selected: _filter == 'unpaid',
                        onTap: () => setState(() => _filter = 'unpaid'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterTab(
                        label:
                            'Lunas (${bookings.where((b) => b.isPaid).length})',
                        selected: _filter == 'paid',
                        onTap: () => setState(() => _filter = 'paid'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: EmptyState(
                      message: 'Tidak ada pesanan pada kategori ini.',
                      icon: Icons.receipt_outlined,
                    ),
                  )
                else
                  for (final booking in filtered) ...[
                    _SimpleBookingCard(
                      booking: booking,
                      paying: _payingBookingId == booking.id,
                      onPay: () => _payBooking(booking),
                      onOpenRundown: () =>
                          context.push(AppRoutes.clientRundown),
                      onShowHistory: () => _showTransactionsSheet(booking),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleBookingCard extends StatelessWidget {
  const _SimpleBookingCard({
    required this.booking,
    required this.paying,
    required this.onPay,
    required this.onOpenRundown,
    required this.onShowHistory,
  });

  final ClientBookingSummary booking;
  final bool paying;
  final VoidCallback onPay;
  final VoidCallback onOpenRundown;
  final VoidCallback onShowHistory;

  @override
  Widget build(BuildContext context) {
    final isPaid = booking.isPaid;
    final isDpPaid = booking.isDpPaid;

    final badgeLabel = isPaid
        ? 'Lunas'
        : (isDpPaid ? 'DP Terbayar (${booking.percentPaid}%)' : 'Belum Bayar');
    final badgeColor = (isPaid || isDpPaid)
        ? const Color(0xFF1E7E5A)
        : AppColors.primary;

    final venueText = [
      if (booking.venueName != null && booking.venueName!.isNotEmpty)
        booking.venueName!,
      if (booking.venueCity != null && booking.venueCity!.isNotEmpty)
        booking.venueCity!,
    ].join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Judul & 1 Badge Status (Bebas Overflow)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: AppTypography.heading(18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.invoiceNumber ?? 'Reservasi #${booking.id}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Info Singkat Lokasi & Tanggal
          if (venueText.isNotEmpty || booking.eventDate != null)
            Text(
              [
                if (booking.eventDate != null) formatDateId(booking.eventDate!),
                if (venueText.isNotEmpty) venueText,
              ].join(' · '),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),

          const SizedBox(height: 12),

          // 3. Ringkasan Angka (Bersih 2 Kolom)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembelian',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatRupiah(booking.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isPaid ? 'Terbayar Lunas' : 'Sisa Tagihan',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatRupiah(isPaid ? booking.paid : booking.remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: isPaid
                              ? const Color(0xFF1E7E5A)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Tombol Aksi Sederhana
          if (booking.needsPayment) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: paying ? null : onPay,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                ),
                icon: paying
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
                  isDpPaid
                      ? 'Lunasi Sisa (${formatRupiah(booking.remaining)})'
                      : 'Bayar DP (${formatRupiah(booking.dpAmount)})',
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenRundown,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: const Icon(Icons.event_note_outlined, size: 16),
                  label: const Text(
                    'Jadwal & Vendor',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ),
              if (booking.payments.isNotEmpty) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onShowHistory,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Bukti Bayar',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingTransactionsSheet extends StatelessWidget {
  const _BookingTransactionsSheet({required this.booking});

  final ClientBookingSummary booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Pembayaran',
            style: AppTypography.heading(20),
          ),
          Text(
            '${booking.title} · ${booking.invoiceNumber ?? '#${booking.id}'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 16),
          for (final p in booking.payments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF1E7E5A),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.typeLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Midtrans${p.createdAt != null ? ' · ${formatDateShortId(p.createdAt!)}' : ''}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatRupiah(p.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: Color(0xFF1E7E5A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
