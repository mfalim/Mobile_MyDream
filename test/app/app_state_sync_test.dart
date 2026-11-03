import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/providers/app_state_sync.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_mock_datasource.dart';

/// Satu "peluncuran aplikasi": container baru yang membaca [storage] yang sama.
ProviderContainer _launch(LocalStorage storage) {
  final container = ProviderContainer(
    overrides: [localStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  container.read(appStateSyncProvider);
  return container;
}

Future<CartItem> _package() async => CartItem.fromPackage(
      await PackagesMockDatasource().fetch('pkg-intimate-bali'),
    );

Future<List<CustomVendorItem>> _threeVendors() async {
  final datasource = VendorDetailMockDatasource();
  return [
    for (final id in ['vendor-lumiere', 'vendor-santap', 'vendor-sora'])
      CustomVendorItem.fromVendorDetail(await datasource.fetch(id)),
  ];
}

void main() {
  test('perubahan tersimpan dan dipulihkan di peluncuran berikutnya', () async {
    final storage = MemoryLocalStorage();
    final first = _launch(storage);

    first.read(authProvider.notifier).signInDemo(email: 'dewi@mail.com');
    first.read(authProvider.notifier).updateName('Dewi Putri');
    first.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: 'Dewi Mayang',
            groomName: 'Dimas Arkan',
            weddingDate: DateTime(2030, 5, 17, 14, 30),
          ),
        );
    final cart = first.read(cartProvider.notifier);
    cart.add(await _package());
    for (final v in await _threeVendors()) {
      cart.addCustomVendor(v);
    }
    cart.selectVoucher(
      (await VoucherMockDatasource().fetch()).firstWhere(
        (v) => v.code == 'DREAMWEDDING',
      ),
    );
    cart.toggle('pkg-intimate-bali');

    final second = _launch(storage);

    final user = second.read(authProvider)!;
    expect(user.name, 'Dewi Putri');
    expect(user.email, 'dewi@mail.com');
    expect(user.hasPassword, isTrue);

    final couple = second.read(coupleProvider)!;
    expect(couple.brideName, 'Dewi Mayang');
    expect(couple.weddingDate, DateTime(2030, 5, 17));

    final restored = second.read(cartProvider);
    expect(restored.items.single.vendorId, 'pkg-intimate-bali');
    expect(restored.items.single.selected, isFalse);
    expect(restored.customVendors.length, 3);
    expect(restored.customSubtotal, 51000000);
    expect(restored.voucher?.code, 'DREAMWEDDING');
    expect(restored.orderCount, 2);
  });

  test('keranjang tamu tetap tersimpan tanpa login', () async {
    final storage = MemoryLocalStorage();
    final first = _launch(storage);
    first
        .read(cartProvider.notifier)
        .addCustomVendor((await _threeVendors()).first);

    final second = _launch(storage);
    expect(second.read(authProvider), isNull);
    expect(second.read(cartProvider).customVendors.length, 1);
  });

  test('keluar membersihkan semuanya, juga di penyimpanan', () async {
    final storage = MemoryLocalStorage();
    final first = _launch(storage);
    first.read(authProvider.notifier).signInDemo(email: 'dewi@mail.com');
    first.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: 'Dewi',
            groomName: 'Dimas',
            weddingDate: DateTime(2030, 1, 1),
          ),
        );
    first.read(cartProvider.notifier).add(await _package());
    first.read(checkoutProvider.notifier).save(
          CheckoutDetails(
            vendorId: 'pkg-intimate-bali',
            brideName: 'Dewi',
            groomName: 'Dimas',
            eventDate: DateTime(2030, 1, 1),
            ceremonyMinutes: 930,
            receptionMinutes: 1110,
            venueName: 'Gedung',
            venueAddress: 'Jalan Raya No. 1',
            venueCity: 'Badung',
            venueProvince: 'Bali',
            guestCount: 80,
            concept: 'Modern Romantic',
            picName: 'Dewi',
            whatsapp: '+6281298743210',
            notes: '',
          ),
        );
    expect(storage.getString(kStorageUser), isNotNull);
    expect(storage.getString(kStorageCart), isNotNull);

    // Hanya status masuk yang diubah: pembersihan dilakukan otomatis, seperti
    // saat server menolak token.
    first.read(authProvider.notifier).signOut();

    expect(first.read(cartProvider).isEmpty, isTrue);
    expect(first.read(coupleProvider), isNull);
    expect(first.read(checkoutProvider), isNull);
    expect(storage.getString(kStorageUser), isNull);
    expect(storage.getString(kStorageCouple), isNull);
    expect(storage.getString(kStorageCart), isNull);

    final second = _launch(storage);
    expect(second.read(authProvider), isNull);
    expect(second.read(cartProvider).isEmpty, isTrue);
  });

  test('mengosongkan keranjang menghapus kuncinya', () async {
    final storage = MemoryLocalStorage();
    final container = _launch(storage);
    container.read(cartProvider.notifier).add(await _package());
    expect(storage.getString(kStorageCart), isNotNull);

    container.read(cartProvider.notifier).clear();
    expect(storage.getString(kStorageCart), isNull);
  });

  test('data rusak atau berformat lama diabaikan, aplikasi tetap terbuka', () {
    final storage = MemoryLocalStorage();
    storage.setString(kStorageCart, '{bukan json');
    storage.setString(kStorageUser,
        jsonEncode({'v': 99, 'id': 'u', 'name': 'x', 'email': 'e'}));
    storage.setString(kStorageCouple, '[]');

    final container = _launch(storage);
    expect(container.read(authProvider), isNull);
    expect(container.read(coupleProvider), isNull);
    expect(container.read(cartProvider).isEmpty, isTrue);
  });
}
