import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/packages/data/models/wedding_package_model.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/presentation/providers/packages_provider.dart';
import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';

void main() {
  group('model', () {
    test('menerima angka berbentuk teks dan tinyint, seperti keluaran Laravel',
        () {
      final p = WeddingPackageModel.fromJson({
        'id': 7,
        'slug': 's',
        'name': 'N',
        'description': null,
        'availability_date': '2027-03-31',
        'duration': '8.00',
        'event_period': null,
        'guest_capacity': 100,
        'is_featured': 1,
        'price': '95000000.00',
        'vendors': [
          {
            'id': 1,
            'name': 'A',
            'category': 'Venue',
            'city': null,
            'price': '1000000.00',
          },
        ],
      });
      expect(p.id, '7');
      expect(p.price, 95000000);
      expect(p.isFeatured, isTrue);
      expect(p.durationHours, 8.0);
      expect(p.availabilityDate, DateTime(2027, 3, 31));
      expect(p.guestCapacity, 100);
      expect(p.vendors.single.price, 1000000);
      expect(p.vendors.single.id, '1');
    });

    test('data kosong tidak membuat pemetaan gagal', () {
      final p = WeddingPackageModel.fromJson({
        'id': 1,
        'slug': 's',
        'name': 'N',
        'is_featured': 0,
        'price': null,
      });
      expect(p.price, 0);
      expect(p.vendors, isEmpty);
      expect(p.isFeatured, isFalse);
      expect(p.guestCapacity, isNull);
      expect(p.availabilityDate, isNull);
    });
  });

  group('harga dan hemat', () {
    PackageVendor v(int? price) =>
        PackageVendor(id: 'x', name: 'X', category: 'Venue', price: price);

    WeddingPackage pkg(int price, List<PackageVendor> vendors) =>
        WeddingPackage(
          id: 'p',
          slug: 'p',
          name: 'P',
          price: price,
          vendors: vendors,
        );

    test('hemat = jumlah harga vendor dikurangi harga paket', () {
      final p = pkg(90, [v(60), v(40)]);
      expect(p.vendorsTotal, 100);
      expect(p.savings, 10);
    });

    test('tanpa hemat bila paket tidak lebih murah', () {
      expect(pkg(100, [v(60), v(40)]).savings, 0);
      expect(pkg(120, [v(60), v(40)]).savings, 0);
    });

    test('ada vendor tanpa harga: total tidak diketahui, tanpa hemat', () {
      final p = pkg(90, [v(60), v(null)]);
      expect(p.vendorsTotal, isNull);
      expect(p.savings, 0);
    });

    test('harga paket belum ditetapkan: tanpa hemat', () {
      expect(pkg(0, [v(60), v(40)]).savings, 0);
    });
  });

  group('data contoh', () {
    test('pilihan editor di atas, lalu urut nama', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final list = await container.read(packagesProvider.future);

      final featuredCount = list.where((p) => p.isFeatured).length;
      expect(featuredCount, greaterThan(0));
      expect(list.take(featuredCount).every((p) => p.isFeatured), isTrue);
      expect(list.skip(featuredCount).any((p) => p.isFeatured), isFalse);

      final featured = list.take(featuredCount).map((p) => p.name).toList();
      expect(featured, [...featured]..sort());
    });

    test('vendor di dalam paket cocok dengan daftar vendor', () async {
      final vendors = (await VendorsMockDatasource().fetch()).featured;
      final packages = await PackagesMockDatasource().fetchAll();

      for (final p in packages) {
        expect(p.vendors, isNotEmpty, reason: p.id);
        for (final pv in p.vendors) {
          final matches = vendors.where((v) => v.id == pv.id).toList();
          expect(matches, hasLength(1), reason: '${p.id}: ${pv.id} tidak ada');
          final v = matches.single;
          expect(pv.name, v.name, reason: '${p.id}/${pv.id}: nama');
          expect(pv.category, v.category, reason: '${p.id}/${pv.id}: kategori');
          expect(pv.price, v.price, reason: '${p.id}/${pv.id}: harga');
        }
      }
    });

    test('semua paket punya harga dan id unik', () async {
      final packages = await PackagesMockDatasource().fetchAll();
      expect(packages.map((p) => p.id).toSet().length, packages.length);
      for (final p in packages) {
        expect(p.price, greaterThan(0), reason: p.id);
      }
    });

    test('id yang tidak dikenal melempar NotFoundException', () {
      expect(
        PackagesMockDatasource().fetch('tidak-ada'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('CartItem.fromPackage', () {
    test('memetakan paket ke item keranjang', () async {
      final p = await PackagesMockDatasource().fetch('pkg-intimate-bali');
      final item = CartItem.fromPackage(p);

      expect(item.vendorId, 'pkg-intimate-bali');
      expect(item.isCustom, isFalse);
      expect(item.packageTitle, 'Paket Intimate Bali');
      expect(item.price, 95000000);
      expect(item.originalPrice, 102000000);
      expect(item.savingsBadge, 'Hemat Rp 7.000.000');
      expect(item.providerSubtitle, '4 vendor • hingga 100 tamu');
      expect(item.paxIncluded, 0);
      expect(item.cashbackPoints, 0);
      expect(item.inclusionSummary, contains('Sora Visual Stories'));
    });

    test('tanpa kapasitas dan tanpa hemat bila tidak ada selisih', () {
      const p = WeddingPackage(
        id: 'p',
        slug: 'p',
        name: 'P',
        price: 100,
        vendors: [
          PackageVendor(id: 'a', name: 'A', category: 'Venue', price: 100),
        ],
      );
      final item = CartItem.fromPackage(p);
      expect(item.providerSubtitle, '1 vendor');
      expect(item.savingsBadge, isEmpty);
      expect(item.originalPrice, item.price);
    });
  });
}
