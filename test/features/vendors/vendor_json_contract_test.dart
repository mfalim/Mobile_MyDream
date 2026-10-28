import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/vendors/data/models/featured_vendor_model.dart';
import 'package:w51/features/vendors/data/models/vendor_detail_model.dart';

Map<String, dynamic> _minimal({Map<String, dynamic>? extra}) => {
      'id': 1,
      'name': 'X',
      'category': 'Venue',
      'price': 1000,
      ...?extra,
    };

void main() {
  group('detail vendor dari kolom database saja', () {
    final json = <String, dynamic>{
      'id': 2,
      'name': 'Katering Jember',
      'slug': 'katering-jember',
      'category': {'id': 2, 'name': 'katering'},
      'price': '100000000.00',
      'phone': '081200000001',
      'city': null,
      'address': 'Jl. Contoh No. 1, Jember',
      'description': '',
      'instagram': null,
      'photos': [
        {'photo': 'https://example.com/a.jpg', 'is_cover': 1, 'sort_order': 0},
        {'photo': 'https://example.com/b.jpg', 'is_cover': 0, 'sort_order': 1},
      ],
    };

    test('data minimal terbaca dan bagian opsional kosong', () {
      final d = VendorDetailModel.fromJson(json);
      expect(d.id, '2');
      expect(d.category, 'katering');
      expect(d.price, 100000000);
      expect(d.location, 'Jl. Contoh No. 1, Jember');
      expect(d.phone, '081200000001');
      expect(d.description, isNull);
      expect(d.instagram, isNull);
      expect(d.originalPrice, isNull);
      expect(d.savings, 0);
      expect(d.savePercent, isNull);
      expect(d.savingsBadge, isNull);
      expect(d.validUntil, isNull);
      expect(d.photoUrls.length, 2);
      expect(d.photoCount, 2);
      expect(d.facts, isEmpty);
      expect(d.sections, isEmpty);
      expect(d.provider, isNull);
      expect(d.cashback, isNull);
      expect(d.installment, isNull);
      expect(d.guarantee, isNull);
    });
  });

  test('harga kosong menjadi 0 (harga menyusul)', () {
    expect(
        VendorDetailModel.fromJson(_minimal(extra: {'price': null})).price, 0);
  });

  test('foto boleh berupa teks biasa, dan photo_count bisa lebih besar', () {
    final a = VendorDetailModel.fromJson(
      _minimal(extra: {
        'photos': ['https://a/1.jpg', 'https://a/2.jpg']
      }),
    );
    expect(a.photoUrls, ['https://a/1.jpg', 'https://a/2.jpg']);

    final b = VendorDetailModel.fromJson(
      _minimal(extra: {'photo_count': 12, 'photos': <Object>[]}),
    );
    expect(b.photoUrls, isEmpty);
    expect(b.photoCount, 12);
  });

  test('hemat dihitung dari harga coret, tanpa hemat bila tidak lebih murah',
      () {
    final a = VendorDetailModel.fromJson(
      _minimal(extra: {'price': 247459800, 'original_price': '260484000.00'}),
    );
    expect(a.savings, 13024200);
    expect(a.savePercent, 5);
    expect(a.savingsBadge, 'Hemat 13 Jt');

    final small = VendorDetailModel.fromJson(
      _minimal(extra: {'price': 1000000, 'original_price': 1500000}),
    );
    expect(small.savingsBadge, 'Hemat Rp 500.000');
    expect(small.savePercent, 33);

    final none = VendorDetailModel.fromJson(
      _minimal(extra: {'price': 100, 'original_price': 90}),
    );
    expect(none.savings, 0);
    expect(none.savingsBadge, isNull);
  });

  test('valid_until: tanggal ISO diformat, teks lain dipakai apa adanya', () {
    expect(
      VendorDetailModel.fromJson(_minimal(extra: {'valid_until': '2026-12-31'}))
          .validUntil,
      'Valid s/d 31 Des 2026',
    );
    expect(
      VendorDetailModel.fromJson(
          _minimal(extra: {'valid_until': 'Valid s/d Des 2026'})).validUntil,
      'Valid s/d Des 2026',
    );
  });

  test('poin cashback dan cicilan: dihitung atau dipakai bila dikirim', () {
    final d = VendorDetailModel.fromJson(
      _minimal(extra: {
        'price': 247459800,
        'cashback_percent': 2.5,
        'installment_months': 24,
      }),
    );
    expect(d.cashback?.points, 61865);
    expect(d.installment?.perMonth, 10310825);

    final explicit = VendorDetailModel.fromJson(
      _minimal(extra: {
        'price': 1000000,
        'cashback_percent': 2.5,
        'cashback_points': 100,
        'installment_months': 6,
        'installment_per_month': 170000,
      }),
    );
    expect(explicit.cashback?.points, 100);
    expect(explicit.installment?.perMonth, 170000);

    final off = VendorDetailModel.fromJson(
      _minimal(extra: {'cashback_percent': 0, 'installment_months': 0}),
    );
    expect(off.cashback, isNull);
    expect(off.installment, isNull);
  });

  test('bagian yang tidak lengkap atau salah bentuk dilewati', () {
    final d = VendorDetailModel.fromJson(
      _minimal(extra: {
        'provider': {'name': 'P'},
        'guarantee': {'title': 'T'},
        'facts': [
          {'icon': 'camera', 'text': '8 jam'},
          {'text': ''},
          'bukan-objek',
        ],
        'sections': [
          {'title': 'A', 'inclusions': <String>[]},
          {
            'title': 'B',
            'inclusions': ['x']
          },
          'bukan-objek',
        ],
      }),
    );
    expect(d.provider, isNull);
    expect(d.guarantee, isNull);
    expect(d.facts.length, 1);
    expect(d.sections.map((s) => s.title), ['B']);
  });

  group('daftar vendor', () {
    test('dari kolom database saja', () {
      final v = FeaturedVendorModel.fromJson({
        'id': 2,
        'name': 'Katering Jember',
        'category': {'id': 2, 'name': 'katering'},
        'price': '100000000.00',
        'city': null,
        'phone': '081200000001',
      });
      expect(v.id, '2');
      expect(v.category, 'katering');
      expect(v.categoryLabel, 'katering');
      expect(v.cities, isEmpty);
      expect(v.price, 100000000);
      expect(v.startingBudget, 100000000);
      expect(v.rating, isNull);
      expect(v.reviewCount, isNull);
      expect(v.priceLabel, isNull);
      expect(v.promoBadge, isNull);
      expect(v.originalPrice, isNull);
      expect(v.photoUrl, isNull);
    });

    test('kota tunggal dan daftar kota membentuk label kategori', () {
      final single = FeaturedVendorModel.fromJson(
        {
          'id': 1,
          'name': 'A',
          'category': 'Photography',
          'price': 1,
          'city': 'Bali'
        },
      );
      expect(single.cities, ['Bali']);
      expect(single.categoryLabel, 'Photography • Bali');

      final many = FeaturedVendorModel.fromJson({
        'id': 1,
        'name': 'A',
        'category': 'Photography',
        'price': 1,
        'cities': ['Bali', 'Jakarta'],
      });
      expect(many.categoryLabel, 'Photography • Bali & Jakarta');
    });

    test('semua field opsional terbaca', () {
      final v = FeaturedVendorModel.fromJson({
        'id': 4,
        'name': 'Sora',
        'category': 'Photography',
        'price': 18500000,
        'original_price': 22000000,
        'rating': 4.9,
        'review_count': '142',
        'badge': 'Top 1%',
        'promo_badge': 'Fast RSVP',
        'price_label': 'Paket D-Day',
        'photo': 'https://example.com/cover.jpg',
        'description': 'Fotografi',
      });
      expect(v.rating, 4.9);
      expect(v.reviewCount, 142);
      expect(v.originalPrice, 22000000);
      expect(v.badge, 'Top 1%');
      expect(v.promoBadge, 'Fast RSVP');
      expect(v.priceLabel, 'Paket D-Day');
      expect(v.photoUrl, 'https://example.com/cover.jpg');
      expect(v.description, 'Fotografi');
    });
  });
}
