import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

class BudgetRange {
  const BudgetRange(this.label, {this.min, this.max});

  final String label;

  /// Batas bawah (termasuk) dan batas atas (tidak termasuk). Null = tanpa batas.
  final int? min;
  final int? max;

  bool contains(int value) {
    final lo = min;
    final hi = max;
    return (lo == null || value >= lo) && (hi == null || value < hi);
  }
}

const kBudgetRanges = [
  BudgetRange('Di bawah 40 jt', max: 40000000),
  BudgetRange('40 – 70 jt', min: 40000000, max: 70000000),
  BudgetRange('Di atas 70 jt', min: 70000000),
];

const kCities = ['Bali', 'Jakarta'];

class VendorFilter {
  const VendorFilter({this.category, this.city, this.budget});

  final String? category;
  final String? city;
  final BudgetRange? budget;

  bool get isActive => category != null || city != null || budget != null;

  bool matches(FeaturedVendor v) {
    final c = category;
    final ct = city;
    final b = budget;
    return (c == null || v.category == c) &&
        (ct == null || v.cities.contains(ct)) &&
        (b == null || b.contains(v.startingBudget));
  }
}
