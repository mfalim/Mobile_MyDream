import 'package:flutter/widgets.dart';

/// Kemajuan persiapan pernikahan. Belum ada sumbernya di database, jadi
/// kedua isinya opsional dan disembunyikan di layar bila kosong.
class WeddingCountdown {
  const WeddingCountdown({this.readiness, this.nextTask});

  /// 0.0 sampai 1.0.
  final double? readiness;
  final String? nextTask;
}

class ServiceCategory {
  const ServiceCategory({
    required this.label,
    required this.icon,
    this.vendorCategory,
    this.route,
  });

  final String label;
  final IconData icon;

  /// Nama kategori di direktori Vendors. Null = tampilkan semua vendor.
  final String? vendorCategory;

  /// Bila ada, membuka halaman ini (bukan direktori Vendors).
  final String? route;
}

/// Penawaran di Home. Saat ini berasal dari paket: [id] adalah id paket.
class DealItem {
  const DealItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.detailIcon,
    required this.price,
    this.badge,
    this.isDiscount = false,
    this.tag,
    this.originalPrice,
    this.locationLabel,
    this.voucherCode,
    this.photoUrl,
  });

  final String id;
  final String title;
  final String detail;
  final IconData detailIcon;
  final int price;
  final String? badge;

  /// True = badge berwarna merah ("Hemat ..."), false = badge emas.
  final bool isDiscount;
  final String? tag;
  final int? originalPrice;
  final String? locationLabel;

  /// Bila ada, tombol deal memasang voucher ini. Bila kosong, tombolnya
  /// membuka detail.
  final String? voucherCode;
  final String? photoUrl;
}

class CuratedVendor {
  const CuratedVendor({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.startingPrice,
    this.rating,
    this.reviewCount,
    this.highlight,
    this.tag,
    this.isVerified = false,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String subtitle;
  final String category;

  /// Harga dasar. 0 berarti belum ditetapkan.
  final int startingPrice;
  final double? rating;
  final int? reviewCount;
  final String? highlight;
  final String? tag;
  final bool isVerified;
  final String? photoUrl;
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
    required this.services,
    required this.deals,
    required this.vendorCategories,
    required this.vendors,
    required this.articles,
    this.countdown,
  });

  final WeddingCountdown? countdown;
  final List<ServiceCategory> services;
  final List<DealItem> deals;

  /// Chip kategori; yang pertama berarti "semua".
  final List<String> vendorCategories;
  final List<CuratedVendor> vendors;
  final List<InspirationArticle> articles;
}
