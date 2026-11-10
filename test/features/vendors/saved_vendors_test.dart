import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/providers/app_state_sync.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/vendors/presentation/providers/saved_vendors_provider.dart';

ProviderContainer _launch(LocalStorage storage) {
  final container = ProviderContainer(
    overrides: [localStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  container.read(appStateSyncProvider);
  return container;
}

void main() {
  test('simpan dan hapus simpanan dengan toggle', () {
    final container = _launch(MemoryLocalStorage());
    final saved = container.read(savedVendorsProvider.notifier);

    saved.toggle('vendor-sora');
    saved.toggle('vendor-maison');
    expect(
        container.read(savedVendorsProvider), {'vendor-sora', 'vendor-maison'});

    saved.toggle('vendor-sora');
    expect(container.read(savedVendorsProvider), {'vendor-maison'});
  });

  test('tersimpan di perangkat dan dipulihkan di peluncuran berikutnya', () {
    final storage = MemoryLocalStorage();
    final first = _launch(storage);
    first.read(savedVendorsProvider.notifier).toggle('vendor-sora');
    first.read(savedVendorsProvider.notifier).toggle('vendor-glasshouse');

    final second = _launch(storage);
    expect(
      second.read(savedVendorsProvider),
      {'vendor-sora', 'vendor-glasshouse'},
    );
  });

  test('daftar kosong menghapus kuncinya', () {
    final storage = MemoryLocalStorage();
    final container = _launch(storage);
    container.read(savedVendorsProvider.notifier).toggle('vendor-sora');
    expect(storage.getString(kStorageSavedVendors), isNotNull);

    container.read(savedVendorsProvider.notifier).toggle('vendor-sora');
    expect(storage.getString(kStorageSavedVendors), isNull);
  });

  test('keluar akun menghapus vendor tersimpan', () {
    final storage = MemoryLocalStorage();
    final container = _launch(storage);
    container.read(authProvider.notifier).signInDemo(email: 'dewi@mail.com');
    container.read(savedVendorsProvider.notifier).toggle('vendor-sora');

    container.read(authProvider.notifier).signOut();

    expect(container.read(savedVendorsProvider), isEmpty);
    expect(storage.getString(kStorageSavedVendors), isNull);
  });

  test('data rusak atau versi lama diabaikan', () {
    final storage = MemoryLocalStorage();
    storage.setString(kStorageSavedVendors, '{bukan json');
    expect(_launch(storage).read(savedVendorsProvider), isEmpty);

    final other = MemoryLocalStorage();
    other.setString(kStorageSavedVendors, '{"v": 99, "ids": ["a"]}');
    expect(_launch(other).read(savedVendorsProvider), isEmpty);
  });
}
