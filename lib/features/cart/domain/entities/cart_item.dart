import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';

/// Id khusus untuk pesanan custom (gabungan vendor pilihan) di checkout.
const kCustomOrderId = 'custom-order';

enum CartItemKind { package, custom }

class CartItem {
  const CartItem({
    required this.vendorId,
    required this.providerName,
    required this.providerSubtitle,
    required this.location,
    required this.packageTitle,
    required this.paxIncluded,
    required this.price,
    required this.originalPrice,
    required this.savingsBadge,
    required this.inclusionSummary,
    required this.cashbackPoints,
    required this.cashbackPercent,
    required this.installmentMonths,
    this.kind = CartItemKind.package,
    this.selected = true,
  });

  /// Pesanan custom: gabungan vendor pilihan diperlakukan sebagai satu paket
  /// (di server kemungkinan berupa paket yang dibuat dari vendor terpilih).
  factory CartItem.custom(List<CustomVendorItem> vendors) {
    final total = vendors.fold<int>(0, (sum, v) => sum + v.price);
    final names = vendors.map((v) => v.name).toList();
    return CartItem(
      vendorId: kCustomOrderId,
      kind: CartItemKind.custom,
      providerName: 'Custom Order',
      providerSubtitle: names.join(' • '),
      location: 'Sesuai venue pilihanmu',
      packageTitle: 'Custom Order (${vendors.length} vendor)',
      paxIncluded: 0,
      price: total,
      originalPrice: total,
      savingsBadge: '',
      inclusionSummary: names.join(', '),
      cashbackPoints: 0,
      cashbackPercent: 0,
      installmentMonths: 0,
    );
  }

  /// Id paket (untuk item paket) atau [kCustomOrderId] (untuk custom).
  final String vendorId;
  final String providerName;
  final String providerSubtitle;
  final String location;
  final String packageTitle;
  final int paxIncluded;
  final int price;
  final int originalPrice;
  final String savingsBadge;
  final String inclusionSummary;
  final int cashbackPoints;
  final double cashbackPercent;
  final int installmentMonths;
  final CartItemKind kind;
  final bool selected;

  bool get isCustom => kind == CartItemKind.custom;

  CartItem copyWith({bool? selected}) => CartItem(
        vendorId: vendorId,
        providerName: providerName,
        providerSubtitle: providerSubtitle,
        location: location,
        packageTitle: packageTitle,
        paxIncluded: paxIncluded,
        price: price,
        originalPrice: originalPrice,
        savingsBadge: savingsBadge,
        inclusionSummary: inclusionSummary,
        cashbackPoints: cashbackPoints,
        cashbackPercent: cashbackPercent,
        installmentMonths: installmentMonths,
        kind: kind,
        selected: selected ?? this.selected,
      );
}
