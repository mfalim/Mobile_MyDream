import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

class OrderSubmittedPage extends ConsumerWidget {
  const OrderSubmittedPage({super.key});

  void _done(BuildContext context, WidgetRef ref) {
    ref.read(receiptProvider.notifier).clear();
    context.go(AppRoutes.home);
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(receiptProvider);

    // Tombol kembali sistem tidak boleh keluar dari app: arahkan ke Home.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _done(context, ref);
      },
      child: Scaffold(
        body: SafeArea(
          child: receipt == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const EmptyState(
                        message: 'Belum ada pesanan yang baru dikirim.',
                        icon: Icons.receipt_long_outlined,
                      ),
                      FilledButton(
                        onPressed: () => _done(context, ref),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(220, 48),
                        ),
                        child: const Text('Kembali ke Beranda'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pesanan Terkirim',
                        textAlign: TextAlign.center,
                        style: AppTypography.heading(30),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Terima kasih. Admin akan memeriksa pesanan dan bukti '
                        'transfermu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.card,
                        ),
                        child: Column(
                          children: [
                            _Row(
                              'Nomor Invoice',
                              receipt.invoiceNumber,
                              bold: true,
                              trailing: IconButton(
                                tooltip: 'Salin nomor invoice',
                                visualDensity: VisualDensity.compact,
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: receipt.invoiceNumber),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text('Nomor invoice disalin.'),
                                      ),
                                    );
                                },
                                icon: const Icon(Icons.copy_outlined, size: 18),
                              ),
                            ),
                            _Row('Pesanan', receipt.title),
                            _Row(
                              'Tanggal Acara',
                              formatDateId(receipt.eventDate),
                            ),
                            _Row(
                              'Skema',
                              receipt.scheme == PaymentScheme.downPayment
                                  ? 'Uang Muka (DP)'
                                  : 'Pelunasan Penuh',
                            ),
                            _Row(
                              'Jumlah Transfer',
                              formatRupiah(receipt.payAmount),
                              bold: true,
                            ),
                            _Row('Bank Tujuan', receipt.bankName),
                            _Row(
                              'Dikirim',
                              '${formatDateShortId(receipt.submittedAt)} '
                                  '• ${_time(receipt.submittedAt)}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTint,
                          borderRadius: AppRadius.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatusRow(
                              label: 'Status pesanan',
                              status: reviewStatusLabel(
                                receipt.bookingStatus,
                                payment: false,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _StatusRow(
                              label: 'Status pembayaran',
                              status: reviewStatusLabel(
                                receipt.paymentStatus,
                                payment: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Status pesanan dan pembayaran dapat dipantau '
                              'di dashboard pesananmu.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () => _done(context, ref),
                        child: const Text('Kembali ke Beranda'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false, this.trailing});

  final String label;
  final String value;
  final bool bold;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final end = trailing;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          if (end != null) end,
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        BadgePill(status, icon: Icons.schedule),
      ],
    );
  }
}
