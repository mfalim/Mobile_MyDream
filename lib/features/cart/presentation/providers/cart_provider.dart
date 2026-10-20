import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';

/// MOCK: DP tetap untuk prototype. Nanti dihitung/diambil dari server.
const kDownPayment = 1000000;

class CartState {
  const CartState({this.items = const [], this.voucher});

  final List<CartItem> items;
  final Voucher? voucher;

  List<CartItem> get selected => items.where((i) => i.selected).toList();
  int get subtotal => selected.fold(0, (sum, i) => sum + i.price);

  /// Potongan voucher untuk [amount]; 0 bila tanpa voucher atau syaratnya
  /// (belanja minimal) belum terpenuhi.
  int discountFor(int amount) {
    final v = voucher;
    if (v == null || !v.isEligible(amount)) return 0;
    return v.discountFor(amount);
  }

  int get discount => selected.isEmpty ? 0 : discountFor(subtotal);
  int get total => subtotal - discount;

  /// Ada voucher terpasang, tapi belanja minimalnya belum terpenuhi.
  bool get voucherNotEligible {
    final v = voucher;
    return v != null && selected.isNotEmpty && !v.isEligible(subtotal);
  }

  CartState copyWith({
    List<CartItem>? items,
    Voucher? voucher,
    bool clearVoucher = false,
  }) =>
      CartState(
        items: items ?? this.items,
        voucher: clearVoucher ? null : (voucher ?? this.voucher),
      );
}

final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// Paket yang sama tidak ditambahkan dua kali.
  void add(CartItem item) {
    if (state.items.any((i) => i.vendorId == item.vendorId)) return;
    state = state.copyWith(items: [...state.items, item]);
  }

  void toggle(String vendorId) {
    state = state.copyWith(
      items: [
        for (final i in state.items)
          i.vendorId == vendorId ? i.copyWith(selected: !i.selected) : i,
      ],
    );
  }

  void remove(String vendorId) {
    state = state.copyWith(
      items: state.items.where((i) => i.vendorId != vendorId).toList(),
    );
  }

  /// Memasang voucher, atau melepasnya bila [voucher] null.
  void selectVoucher(Voucher? voucher) =>
      state = state.copyWith(voucher: voucher, clearVoucher: voucher == null);

  /// Mengosongkan keranjang dan voucher (mis. saat keluar akun).
  void clear() => state = const CartState();
}
