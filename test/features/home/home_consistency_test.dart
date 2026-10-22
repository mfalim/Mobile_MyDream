import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/home/data/datasources/home_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

void main() {
  test('deal dan vendor pilihan di Home cocok dengan daftar vendor', () async {
    final home = await HomeMockDatasource().fetch();
    final vendors = (await VendorsMockDatasource().fetch()).featured;

    FeaturedVendor vendorFor(String id) {
      final matches = vendors.where((v) => v.id == id).toList();
      expect(matches, hasLength(1),
          reason: 'id "$id" tidak ada di daftar vendor');
      return matches.single;
    }

    for (final deal in home.deals) {
      final v = vendorFor(deal.id);
      expect(deal.title, v.name, reason: '${deal.id}: nama');
      expect(deal.price, v.price, reason: '${deal.id}: harga');
      expect(deal.originalPrice, v.originalPrice,
          reason: '${deal.id}: harga coret');
    }

    for (final cv in home.vendors) {
      final v = vendorFor(cv.id);
      expect(cv.name, v.name, reason: '${cv.id}: nama');
      expect(cv.startingPrice, v.price, reason: '${cv.id}: harga');
      expect(cv.rating, v.rating, reason: '${cv.id}: rating');
      expect(cv.reviewCount, v.reviewCount, reason: '${cv.id}: ulasan');
    }
  });
}
