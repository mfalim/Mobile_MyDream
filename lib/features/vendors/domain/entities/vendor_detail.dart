import 'package:w51/core/utils/formatters.dart';

/// Satu poin ringkas di kartu harga, mis. "100 Pax Included".
class VendorFact {
  const VendorFact({required this.iconKey, required this.text});

  final String iconKey;
  final String text;
}

class PackageSection {
  const PackageSection({
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.inclusions,
  });

  final String title;
  final String subtitle;
  final String iconKey;
  final List<String> inclusions;
}

class VendorProviderInfo {
  const VendorProviderInfo({
    required this.name,
    required this.tagline,
    required this.rating,
    required this.reviewCount,
  });

  final String name;
  final String tagline;
  final double rating;
  final int reviewCount;
}

class VendorCashback {
  const VendorCashback({
    required this.points,
    required this.percent,
    this.note,
  });

  final int points;
  final double percent;
  final String? note;
}

class VendorInstallment {
  const VendorInstallment({required this.months, required this.perMonth});

  final int months;
  final int perMonth;
}

class VendorGuarantee {
  const VendorGuarantee({required this.title, required this.note});

  final String title;
  final String note;
}

/// Detail vendor. Yang wajib hanya yang ada di database: id, nama, kategori,
/// dan harga. Bagian lain opsional; layar menyembunyikannya bila kosong.
class VendorDetail {
  const VendorDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.price,
    this.packageLabel,
    this.originalPrice,
    this.validUntil,
    this.photoUrls = const [],
    this.photoCount = 0,
    this.paxIncluded = 0,
    this.facts = const [],
    this.description,
    this.instagram,
    this.cashback,
    this.installment,
    this.provider,
    this.sections = const [],
    this.guarantee,
    this.phone,
  });

  final String id;
  final String name;
  final String category;

  /// Teks lokasi; kosong bila tidak ada data.
  final String location;

  /// Harga dasar. 0 berarti belum ditetapkan ("Harga menyusul").
  final int price;
  final String? packageLabel;
  final int? originalPrice;
  final String? validUntil;
  final List<String> photoUrls;
  final int photoCount;
  final int paxIncluded;
  final List<VendorFact> facts;
  final String? description;
  final String? instagram;
  final VendorCashback? cashback;
  final VendorInstallment? installment;
  final VendorProviderInfo? provider;
  final List<PackageSection> sections;
  final VendorGuarantee? guarantee;
  final String? phone;

  /// Penghematan dibanding harga coret; 0 bila tidak ada.
  int get savings {
    final original = originalPrice;
    if (original == null || price <= 0 || original <= price) return 0;
    return original - price;
  }

  int? get savePercent {
    final original = originalPrice;
    if (savings == 0 || original == null) return null;
    return (savings * 100 / original).round();
  }

  String? get savingsBadge {
    final s = savings;
    if (s == 0) return null;
    return s >= 1000000
        ? 'Hemat ${(s / 1000000).round()} Jt'
        : 'Hemat ${formatRupiah(s, prefix: 'Rp')}';
  }
}
