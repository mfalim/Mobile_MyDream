import 'package:flutter/widgets.dart';

// Catatan: IconData dipakai langsung di entity demi kesederhanaan prototype.
// Saat API siap, ganti dengan kode/string ikon dari server.

class WeddingCountdown {
  const WeddingCountdown({
    required this.readiness,
    required this.nextTask,
  });

  final double readiness; // 0.0 - 1.0
  final String nextTask;
}

class ServiceCategory {
  const ServiceCategory({
    required this.label,
    required this.icon,
    this.vendorCategory,
  });

  final String label;
  final IconData icon;

  /// Nama kategori di direktori Vendors. Null = tampilkan semua vendor.
  final String? vendorCategory;
}

class DealItem {
  const DealItem({
    required this.id,
    required this.voucherCode,
    required this.title,
    required this.badge,
    required this.isDiscount,
    required this.tag,
    required this.detail,
    required this.detailIcon,
    required this.price,
    this.locationLabel,
    this.originalPrice,
  });

  final String id;
  final String voucherCode;
  final String title;
  final String badge;
  final bool isDiscount; // true = badge merah "Hemat", false = badge emas
  final String tag;
  final String detail;
  final IconData detailIcon;
  final int price;
  final int? originalPrice;
  final String? locationLabel;
}

class CuratedVendor {
  const CuratedVendor({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.highlight,
    required this.startingPrice,
    required this.tag,
    this.isVerified = true,
  });

  final String id;
  final String name;
  final String subtitle;
  final String category;
  final double rating;
  final int reviewCount;
  final String highlight;
  final int startingPrice;
  final String tag;
  final bool isVerified;
}

class InspirationArticle {
  const InspirationArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.excerpt,
  });

  final String id;
  final String category;
  final String title;
  final String excerpt;
}

class HomeData {
  const HomeData({
    required this.countdown,
    required this.services,
    required this.deals,
    required this.vendorCategories,
    required this.vendors,
    required this.articles,
  });

  final WeddingCountdown countdown;
  final List<ServiceCategory> services;
  final List<DealItem> deals;
  final List<String> vendorCategories;
  final List<CuratedVendor> vendors;
  final List<InspirationArticle> articles;
}
