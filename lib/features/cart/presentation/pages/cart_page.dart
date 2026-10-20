import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/cart/presentation/widgets/cart_checkout_bar.dart';
import 'package:w51/features/cart/presentation/widgets/cart_info_blocks.dart';
import 'package:w51/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:w51/features/cart/presentation/widgets/cart_summary_card.dart';
import 'package:w51/features/cart/presentation/widgets/cart_tab_switcher.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/my_wedding/presentation/providers/wedding_date_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  static const _filters = ['Semua', 'Menunggu Review', 'Tawaran Negosiasi'];

  int _tab = 0;

  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
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
    final weddingDate = ref.watch(weddingDateProvider);
    final showBar = _tab == 0 && cart.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Aura Wedding Cart', style: AppTypography.heading(20)),
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
            customCount: 0,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 12),
          if (_tab == 1)
            const EmptyState(
              message: 'Belum ada custom order.',
              icon: Icons.palette_outlined,
            )
          else if (cart.items.isEmpty)
            _EmptyCart(onBrowse: () => context.go(AppRoutes.vendors))
          else ...[
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
                  onChat: () => _soon('Chat vendor'),
                  onOpenPackage: () =>
                      context.push(AppRoutes.vendorDetailPath(item.vendorId)),
                ),
              ),
            EstimateCard(dateLabel: formatDateId(weddingDate)),
            const SizedBox(height: 12),
            VoucherTile(
              code: cart.couponCode,
              discount: cart.couponValue,
              onTap: () => _soon('Pilih voucher'),
            ),
            const SizedBox(height: 12),
            CartSummaryCard(
              subtotal: cart.subtotal,
              discount: cart.discount,
              total: cart.total,
              deposit: kDownPayment,
              onTerms: () => _soon('Ketentuan garansi'),
            ),
            const SizedBox(height: 12),
            const TrustTiles(),
          ],
        ],
      ),
      bottomNavigationBar: showBar
          ? CartCheckoutBar(
              total: cart.total,
              deposit: kDownPayment,
              selectedCount: cart.selected.length,
              onHelp: () => _soon('Bantuan'),
              onContinue: () => context.push(AppRoutes.checkout),
            )
          : null,
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const EmptyState(
            message: 'Keranjangmu masih kosong.\nPilih paket vendor impianmu.',
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onBrowse,
            style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
            child: const Text('Jelajahi Vendor'),
          ),
        ],
      ),
    );
  }
}
