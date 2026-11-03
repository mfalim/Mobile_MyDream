import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/whatsapp.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';
import 'package:w51/features/vendors/data/models/vendor_detail_model.dart';

Map<String, dynamic> _sample() => {
      'id': 'x',
      'name': 'X',
      'category': 'Venue',
      'location': 'Bali',
      'package_label': 'Paket',
      'price': 247459800,
      'original_price': 260484000,
      'valid_until': 'Valid s/d Des 2026',
      'photo_count': 12,
      'pax_included': 100,
      'facts': [
        {'icon': 'groups', 'text': '100 Pax Included'},
      ],
      'cashback_percent': 2.5,
      'cashback_note': 'Catatan',
      'installment_months': 24,
      'provider': {'name': 'P', 'tagline': 'T', 'rating': 5, 'review_count': 6},
      'sections': [
        {
          'title': 'S',
          'subtitle': 'Sub',
          'icon': 'ceremony',
          'inclusions': ['a', 'b'],
        },
      ],
      'guarantee': {'title': 'G', 'note': 'N'},
    };

void main() {
  test('nilai turunan sesuai angka contoh dari Figma', () {
    final d = VendorDetailModel.fromJson(_sample());
    expect(d.cashback?.points, 61865);
    expect(d.installment?.perMonth, 10310825);
    expect(d.savePercent, 5);
    expect(d.savingsBadge, 'Hemat 13 Jt');
    expect(d.provider?.rating, 5.0);
    expect(d.sections.single.inclusions, ['a', 'b']);
    expect(d.facts.single.iconKey, 'groups');
  });

  test('setiap vendor di daftar cocok dengan detailnya', () async {
    final list = await VendorsMockDatasource().fetch();
    final datasource = VendorDetailMockDatasource();
    for (final v in list.featured) {
      final d = await datasource.fetch(v.id);
      expect(d.name, v.name, reason: '${v.id}: nama');
      expect(d.category, v.category, reason: '${v.id}: kategori');
      expect(d.price, v.price, reason: '${v.id}: harga kartu vs detail');
      expect(d.originalPrice, v.originalPrice, reason: '${v.id}: harga coret');
      expect(d.packageLabel, v.priceLabel, reason: '${v.id}: label paket');
      expect(d.provider?.rating, v.rating, reason: '${v.id}: rating');
      expect(d.provider?.reviewCount, v.reviewCount, reason: '${v.id}: ulasan');
      expect(v.startingBudget, v.price, reason: '${v.id}: budget filter');
    }
  });

  test('isi detail berbeda antar vendor yang punya isi lengkap', () async {
    final list = await VendorsMockDatasource().fetch();
    final datasource = VendorDetailMockDatasource();
    final details = [
      for (final v in list.featured) await datasource.fetch(v.id),
    ];

    expect(details.map((d) => d.price).toSet().length, details.length);

    final rich = details.where((d) => d.sections.isNotEmpty).toList();
    expect(rich.length, greaterThan(1));
    expect(
      rich.map((d) => d.sections.first.title).toSet().length,
      rich.length,
    );
    for (final d in rich) {
      expect(d.facts, isNotEmpty, reason: d.id);
      expect(d.savings, greaterThan(0), reason: d.id);
    }
  });

  test('vendor berbentuk database hanya punya data minimal', () async {
    final d = await VendorDetailMockDatasource().fetch('vendor-db-katering');
    expect(d.price, 100000000);
    expect(d.location, 'Jl. Contoh No. 1, Jember');
    expect(d.sections, isEmpty);
    expect(d.cashback, isNull);
    expect(d.provider, isNull);
    expect(d.savings, 0);
  });

  test('setiap vendor punya nomor WhatsApp yang valid', () async {
    final list = await VendorsMockDatasource().fetch();
    final datasource = VendorDetailMockDatasource();
    for (final v in list.featured) {
      final d = await datasource.fetch(v.id);
      expect(
        normalizeWhatsAppNumber(d.phone ?? ''),
        isNotNull,
        reason: '${v.id}: nomor telepon',
      );
    }
  });

  test('id yang tidak dikenal melempar NotFoundException', () {
    expect(
      VendorDetailMockDatasource().fetch('tidak-ada'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
