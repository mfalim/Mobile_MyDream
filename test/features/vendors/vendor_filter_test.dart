import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';
import 'package:w51/features/vendors/domain/entities/vendor_filter.dart';

FeaturedVendor _vendor({
  String category = 'Venue',
  List<String> cities = const ['Bali'],
  int budget = 50000000,
}) =>
    FeaturedVendor(
      id: 'v',
      name: 'Vendor',
      category: category,
      cities: cities,
      categoryLabel: '$category • ${cities.join(' & ')}',
      tag: 'Tag',
      tagIcon: Icons.star,
      rating: 4.9,
      reviewCount: 10,
      description: 'Deskripsi',
      priceLabel: 'Mulai dari',
      price: budget,
      startingBudget: budget,
      promoBadge: 'Promo',
      promoNote: 'Catatan',
    );

void main() {
  test('tanpa filter semua vendor cocok dan filter tidak aktif', () {
    const filter = VendorFilter();
    expect(filter.isActive, isFalse);
    expect(filter.matches(_vendor()), isTrue);
  });

  test('filter kategori', () {
    const filter = VendorFilter(category: 'Venue');
    expect(filter.isActive, isTrue);
    expect(filter.matches(_vendor(category: 'Venue')), isTrue);
    expect(filter.matches(_vendor(category: 'Catering')), isFalse);
  });

  test('filter lokasi cocok bila salah satu kota vendor sama', () {
    const filter = VendorFilter(city: 'Jakarta');
    expect(filter.matches(_vendor(cities: ['Jakarta', 'Bali'])), isTrue);
    expect(filter.matches(_vendor(cities: ['Bali'])), isFalse);
  });

  test('batas budget: batas bawah termasuk, batas atas tidak', () {
    final mid = kBudgetRanges[1]; // 40 – 70 jt
    expect(mid.contains(40000000), isTrue);
    expect(mid.contains(69999999), isTrue);
    expect(mid.contains(70000000), isFalse);
    expect(kBudgetRanges[0].contains(39999999), isTrue);
    expect(kBudgetRanges[2].contains(70000000), isTrue);
  });

  test('semua filter digabung (AND)', () {
    final filter = VendorFilter(
      category: 'Venue',
      city: 'Bali',
      budget: kBudgetRanges[2],
    );
    expect(filter.matches(_vendor(budget: 85000000)), isTrue);
    expect(filter.matches(_vendor(budget: 30000000)), isFalse);
    expect(filter.matches(_vendor(category: 'Catering', budget: 85000000)),
        isFalse);
  });
}
