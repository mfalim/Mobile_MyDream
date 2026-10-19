import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/step_progress_header.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/payment/domain/entities/payment_summary.dart';
import 'package:w51/features/payment/presentation/widgets/escrow_guarantee_card.dart';
import 'package:w51/features/payment/presentation/widgets/payment_bar.dart';
import 'package:w51/features/payment/presentation/widgets/payment_method_section.dart';
import 'package:w51/features/payment/presentation/widgets/payment_order_card.dart';
import 'package:w51/features/payment/presentation/widgets/payment_total_card.dart';
import 'package:w51/features/payment/presentation/widgets/scheme_card.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  static const _allMethods = [...kVirtualAccounts, kQrisMethod, kCardMethod];

  PaymentScheme _scheme = PaymentScheme.downPayment;
  String _methodId = kVirtualAccounts.first.id;

  String get _methodLabel =>
      _allMethods.firstWhere((m) => m.id == _methodId).label;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.checkout);
    }
  }

  Future<void> _pay(PaymentSummary summary, String vendorId) async {
    final due = summary.dueNow(_scheme);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Ini prototype, belum ada pembayaran sungguhan.\n\n'
          'Simulasikan pembayaran ${formatRupiah(due)} via $_methodLabel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Simulasikan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final cart = ref.read(cartProvider.notifier);
    final checkout = ref.read(checkoutProvider.notifier);
    context.go(AppRoutes.home);
    cart.remove(vendorId);
    checkout.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Pembayaran simulasi berhasil. Pesanan belum tersimpan di server.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider);
    final item = details == null
        ? null
        : cart.items.where((i) => i.vendorId == details.vendorId).firstOrNull;

    final appBar = AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: _back,
        icon: const Icon(Icons.arrow_back),
      ),
      centerTitle: true,
      title: Text('Payment Options', style: AppTypography.heading(20)),
    );

    if (details == null || item == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyState(
                message: 'Data checkout belum diisi.',
                icon: Icons.assignment_outlined,
              ),
              FilledButton(
                onPressed: () => context.go(AppRoutes.cart),
                style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                child: const Text('Kembali ke Keranjang'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = PaymentSummary(
      packagePrice: item.price + details.guestExtraCost,
      originalPrice: item.originalPrice + details.guestExtraCost,
      couponDiscount: cart.couponValue,
      deposit: kDownPayment,
    );
    final isDp = _scheme == PaymentScheme.downPayment;
    final due = summary.dueNow(_scheme);

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          const StepProgressHeader(
            step: 2,
            total: 2,
            caption: 'Pengikatan Tanggal & Escrow Aman',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              children: [
                PaymentOrderCard(
                  providerName: item.providerName,
                  packageTitle: item.packageTitle,
                  dateLabel: formatDateId(details.eventDate),
                  guests: details.guestCount,
                  packagePrice: summary.packagePrice,
                  originalPrice: summary.originalPrice,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Pilih Skema Pembayaran',
                    style: AppTypography.heading(22)),
                const SizedBox(height: 4),
                const Text(
                  'Pilih fleksibilitas booking sesuai preferensi finansial '
                  'Anda',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                SchemeCard(
                  title: 'Uang Muka / Booking Fee',
                  badge: 'Paling Diminati',
                  badgeBackground: AppColors.coral.withValues(alpha: 0.3),
                  badgeForeground: AppColors.primary,
                  price: formatRupiah(summary.deposit),
                  description:
                      'Kunci tanggal dan kunci harga promo sekarang juga. '
                      'Slot tanggal aman 100% di kalender vendor.',
                  selected: isDp,
                  onTap: () =>
                      setState(() => _scheme = PaymentScheme.downPayment),
                  footer: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 13, height: 1.4),
                            children: [
                              const TextSpan(text: 'Sisa pelunasan ('),
                              TextSpan(
                                text:
                                    formatRupiah(summary.remainingAfterDeposit),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                text: ') dibayarkan H-30 acara atau cicilan '
                                    'berkala.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SchemeCard(
                  title: 'Pelunasan Penuh (Full Payment)',
                  badge: 'Ekstra Hemat',
                  badgeBackground: AppColors.gold,
                  badgeForeground: AppColors.onGold,
                  price: formatRupiah(summary.fullPaymentTotal),
                  strikePrice: formatRupiah(summary.contractTotal),
                  description:
                      'Bayar tuntas di awal tanpa beban pikiran. Nikmati '
                      'potongan langsung & bonus eksklusif.',
                  selected: !isDp,
                  onTap: () =>
                      setState(() => _scheme = PaymentScheme.fullPayment),
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.stars_outlined,
                            size: 18,
                            color: AppColors.onGold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bonus Cashback Potongan '
                              '${formatRupiah(kFullPaymentDiscount)} Terpasang',
                              style: const TextStyle(
                                color: AppColors.onGold,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.redeem_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dapatkan +${formatNumber(item.cashbackPoints)} '
                              'Wedding Points siap redeem honeymoon',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const EscrowGuaranteeCard(),
                const SizedBox(height: AppSpacing.lg),
                PaymentMethodSection(
                  selectedId: _methodId,
                  onChanged: (id) => setState(() => _methodId = id),
                ),
                const SizedBox(height: AppSpacing.md),
                PaymentTotalCard(
                  guests: details.guestCount,
                  packagePrice: summary.packagePrice,
                  couponDiscount: summary.couponDiscount,
                  fullPaymentDiscount: isDp ? 0 : kFullPaymentDiscount,
                  dueLabel: isDp
                      ? 'Total Bayar Sekarang (DP)'
                      : 'Total Bayar Sekarang (Lunas)',
                  dueNow: due,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: PaymentBar(
        dueNow: due,
        buttonLabel: isDp
            ? 'Bayar Sekarang (DP ${formatRupiah(due, prefix: 'Rp')})'
            : 'Bayar Sekarang (Lunas ${formatRupiah(due, prefix: 'Rp')})',
        onPay: () => _pay(summary, item.vendorId),
      ),
    );
  }
}
