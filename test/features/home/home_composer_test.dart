import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/home/data/datasources/home_mock_datasource.dart';
import 'package:w51/features/home/data/home_composer.dart';
import 'package:w51/features/home/data/repositories/home_repository_impl.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/inspirations/data/datasources/inspirations_mock_datasource.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/domain/repositories/inspirations_repository.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/domain/repositories/packages_repository.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';
import 'package:w51/features/vendors/domain/repositories/vendors_repository.dart';

class _Vendors implements VendorsRepository {
  _Vendors({this.fail = false});

  final bool fail;

  @override
  Future<VendorsData> load() async {
    if (fail) throw Exception('vendor gagal');
    return VendorsMockDatasource().fetch();
  }

  @override
  Future<VendorDetail> loadDetail(String id) =>
      VendorDetailMockDatasource().fetch(id);
}

class _Packages implements PackagesRepository {
  _Packages({this.fail = false});

  final bool fail;

  @override
  Future<List<WeddingPackage>> loadAll() async {
    if (fail) throw Exception('paket gagal');
    return PackagesMockDatasource().fetchAll();
  }

  @override
  Future<WeddingPackage> load(String id) => PackagesMockDatasource().fetch(id);
}

class _Inspirations implements InspirationsRepository {
  _Inspirations({this.fail = false});

  final bool fail;

  @override
  Future<InspirationsData> load() async {
    if (fail) throw Exception('artikel gagal');
    return InspirationsMockDatasource().fetch();
  }
}

Future<HomeData> _home({
  bool failVendors = false,
  bool failPackages = false,
  bool failInspirations = false,
}) =>
    HomeRepositoryImpl(
      vendors: _Vendors(fail: failVendors),
      packages: _Packages(fail: failPackages),
      inspirations: _Inspirations(fail: failInspirations),
      progress: const HomeMockDatasource(),
    ).load();

void main() {
  test('ikon layanan: All-In Package, enam kategori, dan Lainnya', () async {
    final home = await _home();
    expect(home.services.length, 8);
    expect(home.services.first.label, 'All-In Package');
    expect(home.services.first.route, '/packages');
    expect(home.services.last.label, 'Lainnya');
    expect(home.services.last.vendorCategory, isNull);
    for (final s in home.services.skip(1).take(6)) {
      expect(s.vendorCategory, s.label);
    }
  });

  test('deals berasal dari paket: pilihan editor dulu, lalu hemat terbesar',
      () async {
    final home = await _home();
    expect(
      home.deals.map((d) => d.id),
      [
        'pkg-grand-uluwatu',
        'pkg-intimate-bali',
        'pkg-garden-jakarta',
        'pkg-photo-glam',
      ],
    );
    for (final d in home.deals) {
      expect(d.price, greaterThan(0), reason: d.id);
      expect(d.voucherCode, isNull, reason: d.id);
    }

    final intimate = home.deals.firstWhere((d) => d.id == 'pkg-intimate-bali');
    expect(intimate.badge, 'Hemat Rp 7.000.000');
    expect(intimate.isDiscount, isTrue);
    expect(intimate.originalPrice, 102000000);
    expect(intimate.price, 95000000);
    expect(intimate.detail, 'Hingga 100 tamu');
    expect(intimate.tag, 'Pilihan Editor');
  });

  test('harga deal sama dengan harga paket', () async {
    final home = await _home();
    final packages = await PackagesMockDatasource().fetchAll();
    for (final d in home.deals) {
      final p = packages.firstWhere((p) => p.id == d.id);
      expect(d.title, p.name, reason: d.id);
      expect(d.price, p.price, reason: d.id);
    }
  });

  test('vendor pilihan: rating tertinggi, tanpa rating di urutan akhir',
      () async {
    final home = await _home();
    expect(
      home.vendors.map((v) => v.id),
      [
        'vendor-maison',
        'vendor-mattana',
        'vendor-sora',
        'vendor-glasshouse',
        'vendor-vivaldi',
        'vendor-ethereal',
      ],
    );
    expect(home.vendors.any((v) => v.id.startsWith('vendor-db-')), isFalse);

    final vendors = (await VendorsMockDatasource().fetch()).featured;
    for (final cv in home.vendors) {
      final v = vendors.firstWhere((v) => v.id == cv.id);
      expect(cv.name, v.name, reason: cv.id);
      expect(cv.startingPrice, v.price, reason: cv.id);
      expect(cv.rating, v.rating, reason: cv.id);
    }
  });

  test('chip kategori: "semua" lalu kategori dari vendor yang tampil',
      () async {
    final home = await _home();
    expect(home.vendorCategories.first, HomeComposer.allCategoriesLabel);
    expect(home.vendorCategories.length, lessThanOrEqualTo(5));
    final shown = home.vendors.map((v) => v.category).toSet();
    for (final c in home.vendorCategories.skip(1)) {
      expect(shown, contains(c));
    }
  });

  test('artikel: cerita utama dulu, maksimal empat', () async {
    final home = await _home();
    expect(home.articles.first.category, 'Real Weddings');
    expect(home.articles.length, lessThanOrEqualTo(4));
  });

  test('kemajuan persiapan diteruskan, dan boleh kosong', () async {
    final home = await _home();
    expect(home.countdown?.readiness, 0.62);

    final vendors = await VendorsMockDatasource().fetch();
    final composed = HomeComposer.compose(vendors: vendors, packages: const []);
    expect(composed.countdown, isNull);
    expect(composed.deals, isEmpty);
    expect(composed.articles, isEmpty);
  });

  test('paket tanpa harga tidak masuk deals', () {
    const priceless = WeddingPackage(
      id: 'p',
      slug: 'p',
      name: 'Tanpa Harga',
      price: 0,
      vendors: [],
    );
    final composed = HomeComposer.compose(
      vendors: const VendorsData(
        popularSearches: [],
        categories: [],
        quickCategories: [],
        featured: [],
      ),
      packages: const [priceless],
    );
    expect(composed.deals, isEmpty);
    expect(composed.vendors, isEmpty);
    expect(composed.vendorCategories, [HomeComposer.allCategoriesLabel]);
  });

  test('paket atau artikel gagal: bagian itu kosong, Home tetap jadi',
      () async {
    final noPackages = await _home(failPackages: true);
    expect(noPackages.deals, isEmpty);
    expect(noPackages.vendors, isNotEmpty);

    final noArticles = await _home(failInspirations: true);
    expect(noArticles.articles, isEmpty);
    expect(noArticles.deals, isNotEmpty);
  });

  test('vendor gagal: Home gagal dimuat', () async {
    await expectLater(_home(failVendors: true), throwsA(isA<Exception>()));
  });
}
