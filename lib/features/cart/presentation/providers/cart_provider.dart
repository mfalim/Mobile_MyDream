import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';

/// MOCK: DP tetap untuk prototype. Nanti dihitung/diambil dari server.
const kDownPayment = 1000000;

/// Aturan owner WO: pesanan custom minimal 3 vendor.
const kMinCustomVendors = 3;

class CartState {
  const CartState({
    this.items = const [],
    this.customVendors = const [],
    this.voucher,
  });

  /// Paket pernikahan di keranjang.
  final List<CartItem> items;

  /// Vendor yang dipilih untuk Custom Order.
  final List<CustomVendorItem> customVendors;
  final Voucher? voucher;

  // ---- Paket ----
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

  /// Ada voucher terpasang, tapi belanja minimal paket belum terpenuhi.
  bool get voucherNotEligible {
    final v = voucher;
    return v != null && selected.isNotEmpty && !v.isEligible(subtotal);
  }

  // ---- Custom Order ----
  int get customSubtotal => customVendors.fold(0, (sum, v) => sum + v.price);
  bool get customReady => customVendors.length >= kMinCustomVendors;
  int get customDiscount =>
      customVendors.isEmpty ? 0 : discountFor(customSubtotal);
  int get customTotal => customSubtotal - customDiscount;

  bool get customVoucherNotEligible {
    final v = voucher;
    return v != null &&
        customVendors.isNotEmpty &&
        !v.isEligible(customSubtotal);
  }

  /// Custom Order sebagai satu "paket" untuk checkout; null bila belum
  /// memenuhi syarat minimal vendor.
  CartItem? get customOrderItem =>
      customReady ? CartItem.custom(customVendors) : null;

  /// Item untuk checkout/pembayaran berdasarkan id (paket atau custom).
  CartItem? orderItemFor(String id) => id == kCustomOrderId
      ? customOrderItem
      : items.where((i) => i.vendorId == id).firstOrNull;

  /// Jumlah pesanan aktif: tiap paket satu, ditambah satu bila ada vendor
  /// custom yang dipilih.
  int get orderCount => items.length + (customVendors.isEmpty ? 0 : 1);

  CartState copyWith({
    List<CartItem>? items,
    List<CustomVendorItem>? customVendors,
    Voucher? voucher,
    bool clearVoucher = false,
  }) =>
      CartState(
        items: items ?? this.items,
        customVendors: customVendors ?? this.customVendors,
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

  /// Menghapus paket; id [kCustomOrderId] mengosongkan Custom Order
  /// (dipakai setelah pembayaran).
  void remove(String vendorId) {
    if (vendorId == kCustomOrderId) {
      state = state.copyWith(customVendors: const []);
      return;
    }
    state = state.copyWith(
      items: state.items.where((i) => i.vendorId != vendorId).toList(),
    );
  }

  /// Vendor yang sama tidak ditambahkan dua kali.
  void addCustomVendor(CustomVendorItem vendor) {
    if (state.customVendors.any((v) => v.vendorId == vendor.vendorId)) return;
    state = state.copyWith(customVendors: [...state.customVendors, vendor]);
  }

  void removeCustomVendor(String vendorId) {
    state = state.copyWith(
      customVendors:
          state.customVendors.where((v) => v.vendorId != vendorId).toList(),
    );
  }

  /// Memasang voucher, atau melepasnya bila [voucher] null.
  void selectVoucher(Voucher? voucher) =>
      state = state.copyWith(voucher: voucher, clearVoucher: voucher == null);

  /// Mengosongkan keranjang, Custom Order, dan voucher (mis. saat keluar akun).
  void clear() => state = const CartState();
}
