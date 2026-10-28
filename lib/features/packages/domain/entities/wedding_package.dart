class PackageVendor {
  const PackageVendor({
    required this.id,
    required this.name,
    required this.category,
    this.city,
    this.price,
  });

  final String id;
  final String name;
  final String category;
  final String? city;
  final int? price;
}

/// Paket pernikahan: gabungan satu atau lebih vendor.
class WeddingPackage {
  const WeddingPackage({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    required this.vendors,
    this.description,
    this.availabilityDate,
    this.durationHours,
    this.eventPeriod,
    this.guestCapacity,
    this.isFeatured = false,
    this.photoUrl,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final DateTime? availabilityDate;

  /// Satuan kolom `duration` di database belum dipastikan (diasumsikan jam).
  final double? durationHours;
  final String? eventPeriod;
  final int? guestCapacity;
  final bool isFeatured;
  final String? photoUrl;

  /// Harga paket. Di database belum ada kolomnya; nilainya nanti dari API
  /// (diatur admin). 0 berarti belum ditetapkan.
  final int price;
  final List<PackageVendor> vendors;

  /// Jumlah harga vendor bila dibeli terpisah; null bila ada vendor tanpa
  /// harga atau paket tanpa vendor.
  int? get vendorsTotal {
    if (vendors.isEmpty || vendors.any((v) => v.price == null)) return null;
    return vendors.fold<int>(0, (sum, v) => sum + (v.price ?? 0));
  }

  /// Penghematan dibanding membeli vendor terpisah; 0 bila tidak ada.
  int get savings {
    final total = vendorsTotal;
    if (total == null || price <= 0 || total <= price) return 0;
    return total - price;
  }
}
