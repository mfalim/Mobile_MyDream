import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/step_progress_header.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/payment/domain/entities/payment_summary.dart';
import 'package:w51/features/payment/domain/proof_rules.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';
import 'package:w51/features/payment/presentation/widgets/midtrans_gateway_card.dart';
import 'package:w51/features/payment/presentation/widgets/payment_bar.dart';
import 'package:w51/features/payment/presentation/widgets/payment_order_card.dart';
import 'package:w51/features/payment/presentation/widgets/payment_total_card.dart';
import 'package:w51/features/payment/presentation/widgets/proof_upload_card.dart';
import 'package:w51/features/payment/presentation/widgets/scheme_option.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _picker = ImagePicker();
  final _proofKey = GlobalKey();

  PaymentScheme _scheme = PaymentScheme.downPayment;
  MidtransSnapSession? _midtransSession;
  XFile? _proof;
  bool _proofError = false;
  bool _busy = false;
  bool _openingMidtrans = false;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.checkout);
    }
  }

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    _snack('$label disalin.');
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final name = file.name.contains('.') ? file.name : file.path;
      final bytes = await file.length();
      if (!mounted) return;
      final error = validateProofFile(name: name, bytes: bytes);
      if (error != null) {
        _snack(error);
        return;
      }
      setState(() {
        _proof = file;
        _proofError = false;
      });
    } on PlatformException {
      if (!mounted) return;
      _snack(
        'Tidak bisa membuka '
        '${source == ImageSource.camera ? 'kamera' : 'galeri'}. '
        'Periksa izin aplikasi.',
      );
    }
  }

  OrderSubmission _buildSubmission({
    required CartItem item,
    required CheckoutDetails details,
    required PaymentSummary summary,
    String proofName = '',
    String proofPath = '',
  }) {
    final discount = ref.read(cartProvider).discountFor(item.price);
    final voucherCode =
        discount > 0 ? ref.read(cartProvider).voucher?.code : null;

    return OrderSubmission(
      itemId: item.vendorId,
      itemTitle: item.packageTitle,
      isCustom: item.isCustom,
      totalAmount: summary.contractTotal,
      scheme: _scheme,
      payAmount: summary.dueNow(_scheme),
      bankAccountId: 'midtrans',
      proofName: proofName,
      proofPath: proofPath,
      vendorIds: item.isCustom
          ? ref
              .read(cartProvider)
              .customVendors
              .map((vendor) => vendor.vendorId)
              .toList()
          : const [],
      voucherCode: voucherCode,
      checkout: details,
      bookingId: _midtransSession?.bookingId,
    );
  }

  Future<void> _openMidtrans({
    required CartItem item,
    required CheckoutDetails details,
    required PaymentSummary summary,
  }) async {
    if (_openingMidtrans || _busy) return;
    setState(() => _openingMidtrans = true);

    final repository = ref.read(paymentsRepositoryProvider);
    try {
      final session = await repository.initiateMidtrans(
        _buildSubmission(
          item: item,
          details: details,
          summary: summary,
        ),
      );
      if (!mounted) return;
      setState(() => _midtransSession = session);

      final uri = Uri.parse(session.redirectUrl);
      var launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      if (!launched && mounted) {
        _snack('Tidak dapat membuka halaman pembayaran Midtrans.');
      }
    } on ValidationException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } on ServerException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      _snack(
        'Gagal menyiapkan pembayaran Midtrans. Periksa koneksi lalu coba lagi.',
      );
    } finally {
      if (mounted) setState(() => _openingMidtrans = false);
    }
  }

  Future<void> _submit({
    required CartItem item,
    required CheckoutDetails details,
    required PaymentSummary summary,
  }) async {
    if (_busy || _openingMidtrans) return;
    final proof = _proof;
    if (_midtransSession == null && proof == null) {
      _snack('Klik Bayar via Midtrans terlebih dahulu untuk melanjutkan.');
      return;
    }

    setState(() => _busy = true);

    final cart = ref.read(cartProvider.notifier);
    final checkout = ref.read(checkoutProvider.notifier);
    final receipts = ref.read(receiptProvider.notifier);
    final repository = ref.read(paymentsRepositoryProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final receipt = await repository.submit(
        _buildSubmission(
          item: item,
          details: details,
          summary: summary,
          proofName: proof?.name ?? '',
          proofPath: proof?.path ?? '',
        ),
      );
      ref.invalidate(clientBookingsProvider);
      receipts.save(receipt);
      router.go(AppRoutes.orderSubmitted);
      cart.remove(details.vendorId);
      cart.selectVoucher(null);
      checkout.clear();
    } on ValidationException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content:
                Text('Pesanan gagal dikirim. Periksa koneksi lalu coba lagi.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider);
    final item = details == null ? null : cart.orderItemFor(details.vendorId);

    final appBar = AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: _back,
        icon: const Icon(Icons.arrow_back),
      ),
      centerTitle: true,
      title: Text('Pembayaran', style: AppTypography.heading(20)),
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

    final base = item.price;
    final discount = cart.discountFor(base);
    final contractTotal = base - discount;
    final dpAmount = AppConfig.useMockData
        ? kDownPayment
        : (contractTotal * 0.10).ceil();
    final summary = PaymentSummary(
      packagePrice: base,
      originalPrice: item.originalPrice,
      couponDiscount: discount,
      deposit: dpAmount,
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
            caption: 'Midtrans & Bukti Pembayaran',
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
                const SizedBox(height: 12),
                SchemeOption(
                  title: 'Uang Muka (DP)',
                  amount: formatRupiah(summary.effectiveDeposit),
                  description: 'Kunci tanggal acara lebih dulu.',
                  note: 'Sisa ${formatRupiah(summary.remainingAfterDeposit)} '
                      'dibayar setelahnya.',
                  selected: isDp,
                  onTap: () =>
                      setState(() => _scheme = PaymentScheme.downPayment),
                ),
                const SizedBox(height: 12),
                SchemeOption(
                  title: 'Pelunasan Penuh',
                  amount: formatRupiah(summary.contractTotal),
                  description: 'Bayar tuntas sekaligus.',
                  selected: !isDp,
                  onTap: () =>
                      setState(() => _scheme = PaymentScheme.fullPayment),
                ),
                const SizedBox(height: AppSpacing.lg),
                MidtransGatewayCard(
                  amount: due,
                  loading: _openingMidtrans,
                  orderId: _midtransSession?.orderId,
                  onCopy: _copy,
                  onOpenMidtrans: () => _openMidtrans(
                    item: item,
                    details: details,
                    summary: summary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                KeyedSubtree(
                  key: _proofKey,
                  child: ProofUploadCard(
                    file: _proof,
                    hasError: _proofError,
                    onGallery: () => _pick(ImageSource.gallery),
                    onCamera: () => _pick(ImageSource.camera),
                    onRemove: () => setState(() => _proof = null),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PaymentTotalCard(
                  guests: details.guestCount,
                  packagePrice: summary.packagePrice,
                  couponDiscount: summary.couponDiscount,
                  dueLabel: isDp
                      ? 'Total Pembayaran Sekarang (DP)'
                      : 'Total Pembayaran Sekarang (Lunas)',
                  dueNow: due,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selesaikan pembayaran melalui Midtrans Payment Gateway '
                  '(status diverifikasi otomatis), lalu tekan Konfirmasi Pembayaran. '
                  'Unggah foto bukti bersifat opsional.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: PaymentBar(
        dueNow: due,
        buttonLabel: 'Konfirmasi Pembayaran',
        loading: _busy,
        onPay: (_busy || _openingMidtrans)
            ? null
            : () => _submit(
                  item: item,
                  details: details,
                  summary: summary,
                ),
      ),
    );
  }
}
