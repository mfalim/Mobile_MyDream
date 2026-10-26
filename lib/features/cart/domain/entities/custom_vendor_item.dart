import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

/// Satu vendor yang dipilih untuk Custom Order.
class CustomVendorItem {
  const CustomVendorItem({
    required this.vendorId,
    required this.name,
    required this.category,
    required this.location,
    required this.price,
  });

  factory CustomVendorItem.fromVendorDetail(VendorDetail d) => CustomVendorItem(
        vendorId: d.id,
        name: d.name,
        category: d.category,
        location: d.location,
        price: d.price,
      );

  final String vendorId;
  final String name;
  final String category;
  final String location;
  final int price;
}
