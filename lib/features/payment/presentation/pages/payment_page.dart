import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/core/widgets/step_progress_header.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/payment/domain/entities/payment_summary.dart';
import 'package:w51/features/payment/domain/proof_rules.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';
import 'package:w51/features/payment/presentation/widgets/bank_accounts_card.dart';
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
  String? _bankId;
  XFile? _proof;
  bool _proofError = false;
  bool _busy = false;

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

  Future<void> _submit({
    required CartItem item,
    required CheckoutDetails details,
    required PaymentSummary summary,
    required List<BankAccount> banks,
  }) async {
    if (_busy) return;
    final proof = _proof;
    if (proof == null) {
      setState(() => _proofError = true);
      _snack('Unggah bukti transfer terlebih dahulu.');
      final target = _proofKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
      return;
    }

    setState(() => _busy = true);

    // Ambil dulu semua yang dibutuhkan: halaman ini hilang setelah go().
    final cart = ref.read(cartProvider.notifier);
    final checkout = ref.read(checkoutProvider.notifier);
    final receipts = ref.read(receiptProvider.notifier);
    final repository = ref.read(paymentsRepositoryProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final discount = ref.read(cartProvider).discountFor(item.price);
    final voucherCode =
        discount > 0 ? ref.read(cartProvider).voucher?.code : null;
    final bankId = _bankId ?? banks.first.id;

    try {
      final receipt = await repository.submit(
        OrderSubmission(
          itemId: item.vendorId,
          itemTitle: item.packageTitle,
          isCustom: item.isCustom,
          totalAmount: summary.contractTotal,
          scheme: _scheme,
          payAmount: summary.dueNow(_scheme),
          bankAccountId: bankId,
          proofName: proof.name,
          proofPath: proof.path,
          voucherCode: voucherCode,
          checkout: details,
        ),
      );
      receipts.save(receipt);
      router.go(AppRoutes.orderSubmitted);
      cart.remove(details.vendorId);
      cart.selectVoucher(null); // voucher habis dipakai
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
    final banks = ref.watch(bankAccountsProvider);
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
    final summary = PaymentSummary(
      packagePrice: base,
      originalPrice: item.originalPrice,
      couponDiscount: cart.discountFor(base),
      deposit: kDownPayment,
    );
    final isDp = _scheme == PaymentScheme.downPayment;
    final due = summary.dueNow(_scheme);
    final bankList = banks.value;

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          const StepProgressHeader(
            step: 2,
            total: 2,
            caption: 'Transfer & Bukti Pembayaran',
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
                if (banks.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (bankList == null || bankList.isEmpty)
                  ErrorState(
                    message: 'Rekening tujuan gagal dimuat.',
                    onRetry: () => ref.invalidate(bankAccountsProvider),
                  )
                else
                  BankAccountsCard(
                    accounts: bankList,
                    selectedId: _bankId ?? bankList.first.id,
                    amount: due,
                    onSelect: (id) => setState(() => _bankId = id),
                    onCopy: _copy,
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
                      ? 'Total Transfer Sekarang (DP)'
                      : 'Total Transfer Sekarang (Lunas)',
                  dueNow: due,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pesananmu akan diperiksa admin. Pembayaran dinyatakan '
                  'sah setelah bukti transfer diverifikasi.',
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
        buttonLabel: 'Kirim Pesanan',
        loading: _busy,
        onPay: (_busy || bankList == null || bankList.isEmpty)
            ? null
            : () => _submit(
                  item: item,
                  details: details,
                  summary: summary,
                  banks: bankList,
                ),
      ),
    );
  }
}
