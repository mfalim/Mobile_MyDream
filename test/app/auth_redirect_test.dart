import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/router/auth_redirect.dart';

void main() {
  group('tamu (belum login)', () {
    test('boleh membuka halaman publik', () {
      for (final path in [
        '/home',
        '/vendors',
        '/inspirations',
        '/vendor/abc'
      ]) {
        expect(
          authRedirect(loggedIn: false, uri: Uri.parse(path)),
          isNull,
          reason: path,
        );
      }
    });

    test('dialihkan ke Login untuk halaman yang butuh login', () {
      for (final path in ['/cart', '/checkout', '/payment', '/my-wedding']) {
        final result = authRedirect(loggedIn: false, uri: Uri.parse(path));
        expect(result, isNotNull, reason: path);
        final parsed = Uri.parse(result!);
        expect(parsed.path, '/login', reason: path);
        expect(parsed.queryParameters['from'], path, reason: path);
      }
    });
  });

  group('pengguna sudah login', () {
    test('tidak dialihkan dari halaman yang butuh login', () {
      expect(authRedirect(loggedIn: true, uri: Uri.parse('/cart')), isNull);
    });

    test('dari Login kembali ke tujuan semula', () {
      final uri = Uri.parse('/login?from=%2Fcart');
      expect(authRedirect(loggedIn: true, uri: uri), '/cart');
    });

    test('dari Login tanpa tujuan kembali ke Home', () {
      expect(authRedirect(loggedIn: true, uri: Uri.parse('/login')), '/home');
    });

    test('menolak tujuan eksternal', () {
      for (final from in ['https://evil.example', '//evil.example', 'evil']) {
        final uri = Uri(path: '/login', queryParameters: {'from': from});
        expect(
          authRedirect(loggedIn: true, uri: uri),
          '/home',
          reason: from,
        );
      }
    });
  });
}
