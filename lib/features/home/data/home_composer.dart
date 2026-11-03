import 'package:flutter/material.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

/// Merakit data Home dari sumber yang sudah ada (vendor, paket, artikel),
/// sehingga Home tidak punya salinan data sendiri.
abstract final class HomeComposer {
  static const maxCategoryServices = 6;
  static const maxDeals = 4;
  static const maxCuratedVendors = 6;
  static const maxArticles = 4;
  static const allCategoriesLabel = 'Semua Kategori';

  static HomeData compose({
    required VendorsData vendors,
    required List<WeddingPackage> packages,
    InspirationsData? inspirations,
    WeddingCountdown? progress,
  }) {
    final curated = _curatedParts(vendors);
    return HomeData(
      countdown: progress,
      services: _services(vendors),
      deals: _deals(packages),
      vendorCategories: curated.vendorCategories,
      vendors: curated.vendors,
      articles: _articles(inspirations),
    );
  }

  static List<ServiceCategory> _services(VendorsData vendors) {
    final categories = <ServiceCategory>[
      for (final c in vendors.categories)
        ServiceCategory(label: c.label, icon: c.icon, vendorCategory: c.label),
      for (final q in vendors.quickCategories)
        ServiceCategory(label: q.label, icon: q.icon, vendorCategory: q.label),
    ];
    return [
      const ServiceCategory(
        label: 'All-In Package',
        icon: Icons.celebration,
        route: AppRoutes.packages,
      ),
      ...categories.take(maxCategoryServices),
      const ServiceCategory(label: 'Lainnya', icon: Icons.apps),
    ];
  }

  /// Paket pilihan editor dulu, lalu penghematan terbesar, lalu nama.
  static List<DealItem> _deals(List<WeddingPackage> packages) {
    final sorted = packages.where((p) => p.price > 0).toList()
      ..sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        final bySavings = b.savings.compareTo(a.savings);
        return bySavings != 0 ? bySavings : a.name.compareTo(b.name);
      });
    return sorted.take(maxDeals).map(_deal).toList();
  }

  static DealItem _deal(WeddingPackage p) {
    final savings = p.savings;
    final capacity = p.guestCapacity;
    final cities = p.vendors.map((v) => v.city).whereType<String>().toSet();
    return DealItem(
      id: p.id,
      title: p.name,
      badge:
          savings > 0 ? 'Hemat ${formatRupiah(savings, prefix: 'Rp')}' : null,
      isDiscount: savings > 0,
      tag: p.isFeatured ? 'Pilihan Editor' : p.eventPeriod,
      detail: capacity != null
          ? 'Hingga $capacity tamu'
          : '${p.vendors.length} vendor',
      detailIcon:
          capacity != null ? Icons.groups_outlined : Icons.storefront_outlined,
      price: p.price,
      originalPrice: savings > 0 ? p.vendorsTotal : null,
      locationLabel: cities.length == 1 ? cities.first : null,
      photoUrl: p.photoUrl,
    );
  }

  /// Vendor dengan rating tertinggi (tanpa rating di urutan terakhir).
  static ({List<CuratedVendor> vendors, List<String> vendorCategories})
      _curatedParts(VendorsData data) {
    final sorted = [...data.featured]..sort((a, b) {
        final byRating = (b.rating ?? -1).compareTo(a.rating ?? -1);
        return byRating != 0 ? byRating : a.name.compareTo(b.name);
      });
    final vendors = sorted
        .take(maxCuratedVendors)
        .map(
          (v) => CuratedVendor(
            id: v.id,
            name: v.name,
            subtitle: v.categoryLabel,
            category: v.category,
            startingPrice: v.price,
            rating: v.rating,
            reviewCount: v.reviewCount,
            highlight: v.promoBadge,
            tag: v.tag ?? v.badge,
            photoUrl: v.photoUrl,
          ),
        )
        .toList();
    return (
      vendors: vendors,
      vendorCategories: [
        allCategoriesLabel,
        ...vendors.map((v) => v.category).toSet().take(4),
      ],
    );
  }

  static List<InspirationArticle> _articles(InspirationsData? data) {
    if (data == null) return const [];
    final story = data.story;
    return [
      if (story != null)
        InspirationArticle(
          id: story.id,
          category: story.category ?? 'Real Weddings',
          title: story.title,
          excerpt: story.excerpt ?? '',
        ),
      for (final t in data.more)
        InspirationArticle(
          id: t.id,
          category: t.category,
          title: t.title,
          excerpt: t.dateLabel ?? '',
        ),
    ].take(maxArticles).toList();
  }
}
