import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/vendors/domain/entities/vendor_filter.dart';

/// Filter aktif di tab Vendors. Dipakai juga oleh Home untuk membuka
/// Vendors dengan kategori tertentu.
final vendorFilterProvider =
    NotifierProvider<VendorFilterController, VendorFilter>(
  VendorFilterController.new,
);

class VendorFilterController extends Notifier<VendorFilter> {
  @override
  VendorFilter build() => const VendorFilter();

  void apply(VendorFilter filter) => state = filter;

  void setCategory(String? category) => state = VendorFilter(
        category: category,
        city: state.city,
        budget: state.budget,
      );

  void reset() => state = const VendorFilter();
}
