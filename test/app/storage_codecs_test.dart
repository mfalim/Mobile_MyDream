import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/auth/data/user_codec.dart';
import 'package:w51/features/auth/domain/entities/app_user.dart';
import 'package:w51/features/cart/data/cart_codec.dart';
import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/my_wedding/data/couple_codec.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';

/// Seperti penyimpanan sungguhan: lewat teks JSON, bukan objek langsung.
Map<String, dynamic> _roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  group('UserCodec', () {
    test('bolak-balik tanpa kehilangan data', () {
      const user = AppUser(
        id: 'u1',
        name: 'Dewi',
        email: 'dewi@mail.com',
        hasPassword: false,
        avatarUrl: 'https://example.com/a.jpg',
      );
      final back = UserCodec.decode(_roundTrip(UserCodec.encode(user)))!;
      expect(back.id, 'u1');
      expect(back.name, 'Dewi');
      expect(back.email, 'dewi@mail.com');
      expect(back.hasPassword, isFalse);
      expect(back.avatarUrl, 'https://example.com/a.jpg');
    });

    test('versi lama, tidak lengkap, atau kosong menjadi null', () {
      expect(UserCodec.decode(null), isNull);
      expect(UserCodec.decode({'v': 99, 'id': 'u', 'name': 'x', 'email': 'e'}),
          isNull);
      expect(UserCodec.decode({'v': 1, 'id': 'u', 'name': 'x'}), isNull);
    });
  });

  group('CoupleCodec', () {
    test('bolak-balik; tanggal hanya hari (tanpa jam)', () {
      final couple = CoupleProfile(
        brideName: 'Dewi Mayang',
        groomName: 'Dimas Arkan',
        weddingDate: DateTime(2030, 5, 7),
      );
      final back = CoupleCodec.decode(_roundTrip(CoupleCodec.encode(couple)))!;
      expect(back.brideName, 'Dewi Mayang');
      expect(back.groomName, 'Dimas Arkan');
      expect(back.weddingDate, DateTime(2030, 5, 7));
      expect(CoupleCodec.encode(couple)['wedding_date'], '2030-05-07');
    });

    test('tanggal rusak atau nama kosong menjadi null', () {
      expect(
          CoupleCodec.decode({
            'v': 1,
            'bride_name': 'A',
            'groom_name': 'B',
            'wedding_date': 'bukan-tanggal'
          }),
          isNull);
      expect(
          CoupleCodec.decode({
            'v': 1,
            'bride_name': '',
            'groom_name': 'B',
            'wedding_date': '2030-01-01'
          }),
          isNull);
    });
  });

  group('CartCodec', () {
    Future<CartState> fullState() async {
      final package = CartItem.fromPackage(
        await PackagesMockDatasource().fetch('pkg-intimate-bali'),
      ).copyWith(selected: false);
      final voucher = (await VoucherMockDatasource().fetch()).firstWhere(
        (v) => v.code == 'BRIDALEXPO',
      );
      return CartState(
        items: [package],
        customVendors: const [
          CustomVendorItem(
            vendorId: 'vendor-sora',
            name: 'Sora Visual Stories',
            category: 'Photography',
            location: 'Bali',
            price: 18500000,
          ),
        ],
        voucher: voucher,
      );
    }

    test('bolak-balik: item, vendor custom, voucher, dan centang', () async {
      final original = await fullState();
      final back = CartCodec.decode(_roundTrip(CartCodec.encode(original)));

      final item = back.items.single;
      expect(item.vendorId, 'pkg-intimate-bali');
      expect(item.selected, isFalse);
      expect(item.packageTitle, 'Paket Intimate Bali');
      expect(item.price, 95000000);
      expect(item.originalPrice, 102000000);
      expect(item.savingsBadge, 'Hemat Rp 7.000.000');
      expect(item.guestCapacity, 100);
      expect(item.kind, CartItemKind.package);

      expect(back.customVendors.single.vendorId, 'vendor-sora');
      expect(back.customVendors.single.price, 18500000);

      final voucher = back.voucher!;
      expect(voucher.code, 'BRIDALEXPO');
      expect(voucher.type.name, 'percent');
      expect(voucher.maxDiscount, 15000000);
      expect(voucher.minSpend, 300000000);

      expect(back.orderCount, original.orderCount);
    });

    test('keranjang kosong menghasilkan keranjang kosong', () {
      final back =
          CartCodec.decode(_roundTrip(CartCodec.encode(const CartState())));
      expect(back.isEmpty, isTrue);
    });

    test('data rusak dilewati satu per satu, bukan seluruhnya', () {
      final back = CartCodec.decode({
        'v': 1,
        'items': [
          {'vendor_id': 'ok', 'package_title': 'Paket OK', 'price': 100},
          {'vendor_id': 'tanpa-harga', 'package_title': 'X'},
          'bukan-objek',
        ],
        'custom_vendors': [
          {'vendor_id': 'v1', 'name': 'V1', 'price': 5},
          {'name': 'tanpa id', 'price': 5},
        ],
        'voucher': {
          'code': 'X',
          'title': 'Y',
          'value': 5,
          'type': 'tidak-dikenal'
        },
      });
      expect(back.items.map((i) => i.vendorId), ['ok']);
      expect(back.items.single.selected, isTrue); // bawaan
      expect(back.customVendors.map((v) => v.vendorId), ['v1']);
      expect(back.voucher, isNull);
    });

    test('versi lama atau kosong menjadi keranjang kosong', () {
      expect(CartCodec.decode(null).isEmpty, isTrue);
      expect(
          CartCodec.decode({
            'v': 99,
            'items': [
              {'vendor_id': 'a'}
            ]
          }).isEmpty,
          isTrue);
    });
  });
}
