import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';

/// MOCK: DP tetap untuk prototype. Nanti dihitung/diambil dari server.
const kDownPayment = 1000000;

class CartState {
  const CartState({
    this.items = const [],
    this.couponCode = 'DREAMWEDDING',
    this.couponValue = 5000000, // MOCK
  });

  final List<CartItem> items;
  final String couponCode;
  final int couponValue;

  List<CartItem> get selected => items.where((i) => i.selected).toList();
  int get subtotal => selected.fold(0, (sum, i) => sum + i.price);
  int get discount => selected.isEmpty ? 0 : couponValue;
  int get total => subtotal - discount;

  CartState copyWith({List<CartItem>? items}) => CartState(
        items: items ?? this.items,
        couponCode: couponCode,
        couponValue: couponValue,
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

  void clear() => state = state.copyWith(items: const []);
}
