import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';

void main() {
  test('awalnya tamu, lalu bisa masuk dan keluar', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authProvider), isNull);

    container.read(authProvider.notifier).signInDemo(email: 'a@b.com');
    expect(container.read(authProvider)?.email, 'a@b.com');

    container.read(authProvider.notifier).signOut();
    expect(container.read(authProvider), isNull);
  });
  test('daftar menyimpan nama yang diisi, dan keluar menghapusnya', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(authProvider.notifier)
        .register(name: 'Dewi', email: 'dewi@mail.com');
    expect(container.read(authProvider)?.name, 'Dewi');
    expect(container.read(authProvider)?.email, 'dewi@mail.com');

    container.read(authProvider.notifier).signOut();
    expect(container.read(authProvider), isNull);
  });

  test('nama default diambil dari bagian depan email', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(authProvider.notifier).signInDemo(email: 'rina@mail.com');
    expect(container.read(authProvider)?.name, 'rina');
  });
}
