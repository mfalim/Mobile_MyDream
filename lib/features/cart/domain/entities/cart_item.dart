import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

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
    this.selected = true,
  });

  /// Satu vendor = satu paket di keranjang, jadi id vendor dipakai sebagai id item.
  factory CartItem.fromVendorDetail(VendorDetail d) => CartItem(
        vendorId: d.id,
        providerName: d.provider.name,
        providerSubtitle: 'Official Partner • ${d.location}',
        location: d.location,
        packageTitle: '${d.name} - ${d.packageLabel}',
        paxIncluded: d.paxIncluded,
        price: d.price,
        originalPrice: d.originalPrice,
        savingsBadge: d.savingsBadge,
        inclusionSummary: d.sections.map((s) => s.title).join(', '),
        cashbackPoints: d.cashbackPoints,
        cashbackPercent: d.cashbackPercent,
        installmentMonths: d.installmentMonths,
      );

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
  final bool selected;

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
        selected: selected ?? this.selected,
      );
}
