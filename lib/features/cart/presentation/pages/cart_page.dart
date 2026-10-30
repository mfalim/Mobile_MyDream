import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/cart/presentation/providers/voucher_provider.dart';
import 'package:w51/features/cart/presentation/widgets/cart_checkout_bar.dart';
import 'package:w51/features/cart/presentation/widgets/cart_info_blocks.dart';
import 'package:w51/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:w51/features/cart/presentation/widgets/cart_summary_card.dart';
import 'package:w51/features/cart/presentation/widgets/cart_tab_switcher.dart';
import 'package:w51/features/cart/presentation/widgets/custom_order_section.dart';
import 'package:w51/features/cart/presentation/widgets/voucher_sheet.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({this.claimCode, this.initialTab = 0, super.key});

  /// Kode voucher yang langsung dipasang (dari tombol "Klaim Voucher").
  final String? claimCode;

  /// 0 = Paket Pernikahan, 1 = Custom Order.
  final int initialTab;

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  static const _filters = ['Semua', 'Menunggu Review', 'Tawaran Negosiasi'];

  late int _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    final code = widget.claimCode;
    if (code != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _claim(code));
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _soon(String feature) => _snack('$feature segera hadir.');

  Future<void> _claim(String code) async {
    final vouchers = await ref.read(vouchersProvider.future);
    if (!mounted) return;
    final voucher = vouchers.where((v) => v.code == code).firstOrNull;
    if (voucher == null) {
      _snack('Voucher tidak ditemukan.');
      return;
    }
    ref.read(cartProvider.notifier).selectVoucher(voucher);
    final cart = ref.read(cartProvider);
    final hasItems = cart.items.isNotEmpty || cart.customVendors.isNotEmpty;
    _snack(
      hasItems
          ? 'Voucher ${voucher.code} dipasang.'
          : 'Voucher ${voucher.code} siap dipakai. Pilih paket atau vendor '
              'untuk menggunakannya.',
    );
  }

  Future<void> _pickVoucher() async {
    final vouchers = await ref.read(vouchersProvider.future);
    if (!mounted) return;
    final cart = ref.read(cartProvider);
    final code = await showVoucherSheet(
      context,
      vouchers: vouchers,
      selectedCode: cart.voucher?.code,
      amount: _tab == 1 ? cart.customSubtotal : cart.subtotal,
    );
    if (code == null || !mounted) return;
    ref.read(cartProvider.notifier).selectVoucher(
          code.isEmpty ? null : vouchers.firstWhere((v) => v.code == code),
        );
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final controller = ref.read(cartProvider.notifier);
    final couple = ref.watch(coupleProvider);
    final isCustomTab = _tab == 1;
    final showBar =
        isCustomTab ? cart.customVendors.isNotEmpty : cart.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('MyDream Cart', style: AppTypography.heading(20)),
        actions: [
          IconButton(
            tooltip: 'Menu',
            onPressed: () => _soon('Menu keranjang'),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.lg,
        ),
        children: [
          CartTabSwitcher(
            selected: _tab,
            packageCount: cart.items.length,
            customCount: cart.customVendors.length,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 12),
          if (isCustomTab)
            ..._customContent(cart, controller, couple)
          else
            ..._packageContent(cart, controller, couple),
        ],
      ),
      bottomNavigationBar: !showBar
          ? null
          : isCustomTab
              ? CartCheckoutBar(
                  total: cart.customTotal,
                  deposit: kDownPayment,
                  canContinue: cart.customReady,
                  continueLabel: cart.customReady
                      ? 'Lanjut ke Validasi Data (${cart.customVendors.length} Vendor)'
                      : 'Pilih ${kMinCustomVendors - cart.customVendors.length} '
                          'vendor lagi',
                  onHelp: () =>
                      contactAdmin(context, ref, topic: 'bantuan pesanan'),
                  onContinue: () =>
                      context.push(AppRoutes.checkoutPath(custom: true)),
                )
              : CartCheckoutBar(
                  total: cart.total,
                  deposit: kDownPayment,
                  canContinue: cart.selected.isNotEmpty,
                  continueLabel:
                      'Lanjut ke Validasi Data (${cart.selected.length} Item)',
                  onHelp: () =>
                      contactAdmin(context, ref, topic: 'bantuan pesanan'),
                  onContinue: () => context.push(AppRoutes.checkoutPath()),
                ),
    );
  }

  Widget _voucherTile(CartState cart, {required bool custom}) {
    final v = cart.voucher;
    final notEligible =
        custom ? cart.customVoucherNotEligible : cart.voucherNotEligible;
    final discount = custom ? cart.customDiscount : cart.discount;
    final subtitle = v == null
        ? 'Pilih voucher untuk hemat lebih banyak'
        : notEligible
            ? 'Kupon ${v.code}: belanja minimal ${formatRupiah(v.minSpend)} '
                'belum terpenuhi'
            : "Kupon '${v.code}' dipasang (hemat ${formatRupiah(discount)})";
    return VoucherTile(
      subtitle: subtitle,
      subtitleColor: notEligible ? AppColors.error : AppColors.primary,
      onTap: _pickVoucher,
    );
  }

  List<Widget> _packageContent(
    CartState cart,
    CartController controller,
    CoupleProfile? couple,
  ) {
    if (cart.items.isEmpty) {
      return [
        _EmptyCart(
          message:
              'Belum ada paket pernikahan di keranjang.\nPilih paket lengkap, '
              'atau susun sendiri lewat Custom Order.',
          buttonLabel: 'Lihat Paket Pernikahan',
          onPressed: () => context.push(AppRoutes.packages),
          secondaryLabel: 'Buat Custom Order',
          onSecondary: () => setState(() => _tab = 1),
        ),
      ];
    }
    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in _filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: f == _filters.first,
                  onSelected: (_) {
                    if (f != _filters.first) _soon('Filter "$f"');
                  },
                  selectedColor: AppColors.coral.withValues(alpha: 0.3),
                  backgroundColor: AppColors.surfaceTint,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      for (final item in cart.items)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CartItemCard(
            item: item,
            onToggle: () => controller.toggle(item.vendorId),
            onRemove: () => controller.remove(item.vendorId),
            onChat: () => contactAdmin(context, ref, topic: item.packageTitle),
            onOpenPackage: () =>
                context.push(AppRoutes.packageDetailPath(item.vendorId)),
          ),
        ),
      if (couple != null) ...[
        EstimateCard(dateLabel: formatDateId(couple.weddingDate)),
        const SizedBox(height: 12),
      ],
      _voucherTile(cart, custom: false),
      const SizedBox(height: 12),
      CartSummaryCard(
        subtotal: cart.subtotal,
        discount: cart.discount,
        total: cart.total,
        deposit: kDownPayment,
        onTerms: () => context.push(AppRoutes.infoPath('guarantee')),
      ),
      const SizedBox(height: 12),
      const TrustTiles(),
    ];
  }

  List<Widget> _customContent(
    CartState cart,
    CartController controller,
    CoupleProfile? couple,
  ) {
    final count = cart.customVendors.length;
    if (count == 0) {
      return [
        _EmptyCart(
          message:
              'Custom Order masih kosong.\nPilih minimal $kMinCustomVendors '
              'vendor untuk memesan.',
          buttonLabel: 'Pilih Vendor',
          onPressed: () => context.go(AppRoutes.vendors),
        ),
      ];
    }
    return [
      CustomOrderProgress(count: count, min: kMinCustomVendors),
      const SizedBox(height: 12),
      for (final v in cart.customVendors)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomVendorTile(
            item: v,
            onOpen: () => context.push(AppRoutes.vendorDetailPath(v.vendorId)),
            onRemove: () => controller.removeCustomVendor(v.vendorId),
          ),
        ),
      OutlinedButton.icon(
        onPressed: () => context.go(AppRoutes.vendors),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Vendor'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
      ),
      const SizedBox(height: 12),
      if (couple != null) ...[
        EstimateCard(dateLabel: formatDateId(couple.weddingDate)),
        const SizedBox(height: 12),
      ],
      _voucherTile(cart, custom: true),
      const SizedBox(height: 12),
      CartSummaryCard(
        subtotal: cart.customSubtotal,
        discount: cart.customDiscount,
        total: cart.customTotal,
        deposit: kDownPayment,
        onTerms: () => context.push(AppRoutes.infoPath('guarantee')),
      ),
      const SizedBox(height: 12),
      const TrustTiles(),
    ];
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final secondary = secondaryLabel;
    final onSecond = onSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          EmptyState(message: message, icon: Icons.shopping_bag_outlined),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(minimumSize: const Size(220, 48)),
            child: Text(buttonLabel),
          ),
          if (secondary != null && onSecond != null)
            TextButton(onPressed: onSecond, child: Text(secondary)),
        ],
      ),
    );
  }
}
