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
}
