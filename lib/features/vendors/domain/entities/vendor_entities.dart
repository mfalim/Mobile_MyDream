import 'package:flutter/widgets.dart';

// IconData dipakai langsung demi kesederhanaan prototype; saat API siap,
// ganti dengan kode ikon dari server.

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

class FeaturedVendor {
  const FeaturedVendor({
    required this.id,
    required this.name,
    required this.category,
    required this.cities,
    required this.categoryLabel,
    required this.tag,
    required this.tagIcon,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.priceLabel,
    required this.price,
    required this.startingBudget,
    required this.promoBadge,
    required this.promoNote,
    this.badge,
    this.priceUnit,
    this.originalPrice,
  });

  final String id;
  final String name;

  /// Nama kategori, sama dengan label di daftar kategori (untuk filter).
  final String category;
  final List<String> cities;
  final String categoryLabel;
  final String tag;
  final IconData tagIcon;
  final double rating;
  final int reviewCount;
  final String? badge;
  final String description;
  final String priceLabel;
  final int price;
  final String? priceUnit;
  final int? originalPrice;

  /// Perkiraan total biaya termurah, dipakai untuk filter budget (MOCK).
  final int startingBudget;
  final String promoBadge;
  final String promoNote;
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
