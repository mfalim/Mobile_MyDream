import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/router/auth_redirect.dart';
import 'package:w51/app/router/route_names.dart';

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
  test('tujuan dengan query tetap dipertahankan setelah login', () {
    final uri = Uri(
      path: '/login',
      queryParameters: {'from': '/cart?claim=BRIDALEXPO'},
    );
    expect(authRedirect(loggedIn: true, uri: uri), '/cart?claim=BRIDALEXPO');
  });

  test('tamu yang membuka keranjang dengan voucher: query ikut terbawa', () {
    final result = authRedirect(
      loggedIn: false,
      uri: Uri.parse('/cart?claim=BRIDALEXPO'),
    );
    expect(
      Uri.parse(result!).queryParameters['from'],
      '/cart?claim=BRIDALEXPO',
    );
  });

  test('tamu boleh membuka Login dan Register', () {
    expect(authRedirect(loggedIn: false, uri: Uri.parse('/login')), isNull);
    expect(authRedirect(loggedIn: false, uri: Uri.parse('/register')), isNull);
  });

  test('pengguna yang sudah login dialihkan dari Register', () {
    expect(authRedirect(loggedIn: true, uri: Uri.parse('/register')), '/home');
    final uri = Uri.parse('/register?from=%2Fcart');
    expect(authRedirect(loggedIn: true, uri: uri), '/cart');
  });

  test('loginPath dan registerPath meneruskan tujuan', () {
    expect(AppRoutes.loginPath(), '/login');
    expect(AppRoutes.loginPath(from: '/cart'), '/login?from=%2Fcart');
    expect(AppRoutes.registerPath(from: '/cart'), '/register?from=%2Fcart');
  });
}
