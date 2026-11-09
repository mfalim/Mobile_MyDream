import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/vendors/presentation/pages/saved_vendors_page.dart';
import 'package:w51/features/vendors/presentation/providers/saved_vendors_provider.dart';

import '../../helpers/test_app.dart';

void main() {
  setUpAll(useTestFonts);

  Future<ProviderContainer> pumpSaved(
    WidgetTester tester, {
    List<String> saved = const [],
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    for (final id in saved) {
      container.read(savedVendorsProvider.notifier).toggle(id);
    }
    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/saved',
      routes: [
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedVendorsPage(),
        ),
        markerRoute('/vendors', 'HALAMAN VENDORS'),
        GoRoute(
          path: '/vendor/:id',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('VENDOR ${state.pathParameters['id']}')),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('kosong: ajakan menjelajah vendor', (tester) async {
    await pumpSaved(tester);

    expect(find.textContaining('Belum ada vendor tersimpan'), findsOneWidget);
    await tester.tap(find.text('Jelajahi Vendor'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN VENDORS'), findsOneWidget);
  });

  testWidgets('menampilkan hanya vendor yang disimpan', (tester) async {
    await pumpSaved(tester, saved: ['vendor-sora', 'vendor-maison']);

    expect(find.text('2 vendor tersimpan'), findsOneWidget);
    expect(find.text('Sora Visual Stories'), findsOneWidget);
    expect(find.text('Glasshouse'), findsNothing);
  });

  testWidgets('id yang sudah tidak ada di direktori diabaikan', (tester) async {
    await pumpSaved(tester, saved: ['vendor-sora', 'vendor-tidak-ada']);

    expect(find.text('1 vendor tersimpan'), findsOneWidget);
  });

  testWidgets('menghapus simpanan membuat kartunya hilang', (tester) async {
    final container = await pumpSaved(tester, saved: ['vendor-sora']);

    await tester.tap(find.byTooltip('Hapus dari simpanan'));
    await tester.pumpAndSettle();

    expect(container.read(savedVendorsProvider), isEmpty);
    expect(find.textContaining('Belum ada vendor tersimpan'), findsOneWidget);
  });

  testWidgets('mengetuk kartu membuka detail vendor', (tester) async {
    await pumpSaved(tester, saved: ['vendor-sora']);

    await tester.tap(find.text('Sora Visual Stories'));
    await tester.pumpAndSettle();

    expect(find.text('VENDOR vendor-sora'), findsOneWidget);
  });
}
