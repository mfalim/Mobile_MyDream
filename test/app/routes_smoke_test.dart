import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/router/app_router.dart';
import 'package:w51/app/theme/app_theme.dart';

import '../helpers/test_app.dart';

/// Membuka router sungguhan dan memastikan setiap alamat publik terdaftar.
/// Menangkap rute yang hilang atau salah tempat ("Page Not Found").
void main() {
  setUpAll(useTestFonts);

  const publicPaths = [
    '/home',
    '/vendors',
    '/inspirations',
    '/packages',
    '/package/pkg-intimate-bali',
    '/story/story-dewi-dimas',
    '/story/story-veil',
    '/vendor/vendor-sora',
    '/info/terms',
    '/login',
    '/register',
  ];

  Future<void> open(WidgetTester tester, String path) async {
    useTallViewport(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Font tes lebih lebar daripada font asli: overflow tata letak diabaikan,
    // error lain tetap menggagalkan tes.
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };

    try {
      final router = container.read(routerProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      router.go(path);
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = original;
    }
  }

  for (final path in publicPaths) {
    testWidgets('rute terdaftar: $path', (tester) async {
      await open(tester, path);
      expect(find.text('Page Not Found'), findsNothing, reason: path);
    });
  }

  testWidgets('kontrol: alamat yang tidak ada memang tidak ditemukan',
      (tester) async {
    await open(tester, '/tidak-ada-di-aplikasi');
    expect(find.text('Page Not Found'), findsOneWidget);
  });
}
