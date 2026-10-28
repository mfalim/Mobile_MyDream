import 'package:flutter/widgets.dart';

// IconData dipakai langsung demi kesederhanaan prototype; saat API siap,
// ganti dengan kunci ikon dari server (lihat core/utils/icon_mapper.dart).

class VendorCategory {
  const VendorCategory({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;
}

class QuickCategory {
  const QuickCategory({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Vendor di daftar. Yang wajib hanya yang ada di database: id, nama,
/// kategori, dan harga. Sisanya opsional dan disembunyikan bila kosong.
class FeaturedVendor {
  const FeaturedVendor({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryLabel,
    required this.price,
    required this.startingBudget,
    this.cities = const [],
    this.tag,
    this.tagIcon,
    this.rating,
    this.reviewCount,
    this.badge,
    this.description,
    this.priceLabel,
    this.priceNote,
    this.originalPrice,
    this.promoBadge,
    this.promoNote,
    this.photoUrl,
  });

  final String id;
  final String name;

  /// Nama kategori, sama dengan label di daftar kategori (untuk filter).
  final String category;
  final List<String> cities;
  final String categoryLabel;

  /// Harga dasar. 0 berarti belum ditetapkan.
  final int price;

  /// Perkiraan total biaya termurah, dipakai untuk filter budget.
  final int startingBudget;
  final String? tag;
  final IconData? tagIcon;
  final double? rating;
  final int? reviewCount;
  final String? badge;
  final String? description;
  final String? priceLabel;
  final String? priceNote;
  final int? originalPrice;
  final String? promoBadge;
  final String? promoNote;
  final String? photoUrl;
}

class VendorsData {
  const VendorsData({
    required this.popularSearches,
    required this.categories,
    required this.quickCategories,
    required this.featured,
  });

  final List<String> popularSearches;
  final List<VendorCategory> categories;
  final List<QuickCategory> quickCategories;
  final List<FeaturedVendor> featured;
}
