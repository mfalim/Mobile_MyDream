import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/inspirations/presentation/pages/story_page.dart';

import '../../helpers/test_app.dart';

void main() {
  setUpAll(useTestFonts);

  Future<void> pumpStory(WidgetTester tester, String id) async {
    useTallViewport(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/story/$id',
      routes: [
        GoRoute(
          path: '/story/:id',
          builder: (context, state) =>
              StoryPage(storyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/package/:id',
          builder: (context, state) => Scaffold(
            body: Center(
                child: Text('HALAMAN PAKET ${state.pathParameters['id']}')),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cerita terstruktur menampilkan semua bagian', (tester) async {
    await pumpStory(tester, 'story-dewi-dimas');

    expect(find.text('Ocean Boho'), findsOneWidget);
    expect(find.text('Sorotan Visual Hari Bahagia'), findsOneWidget);
    expect(find.text('Vendor Pilihan Dewi & Dimas'), findsOneWidget);
    expect(find.text('Tips Khusus Menikah di Cuaca Tebing Pantai'),
        findsOneWidget);
    expect(find.textContaining('Terinspirasi'), findsOneWidget);
    expect(find.text('Paket terkait'), findsOneWidget);
  });

  testWidgets('cerita berbentuk database menyembunyikan bagian yang kosong',
      (tester) async {
    await pumpStory(tester, 'story-veil');

    expect(
      find.text(
          '8 Tips Memilih Wedding Veil yang Tepat untuk Menyempurnakan Siluet'),
      findsOneWidget,
    );
    expect(find.textContaining('Blusher menutupi wajah'), findsOneWidget);
    expect(find.text('Sorotan Visual Hari Bahagia'), findsNothing);
    expect(find.text('Terverifikasi MyDream'), findsNothing);
    expect(find.textContaining('Terinspirasi'), findsNothing);
    expect(find.text('Paket terkait'), findsNothing);
  });

  testWidgets('paket terkait membuka detail paket', (tester) async {
    await pumpStory(tester, 'story-pinus');

    expect(find.text('Paket terkait'), findsOneWidget);
    await tester.tap(find.text('Lihat Paket'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN PAKET pkg-garden-jakarta'), findsOneWidget);
  });

  testWidgets('id tidak dikenal: pesan tidak ditemukan', (tester) async {
    await pumpStory(tester, 'tidak-ada');

    expect(find.text('Cerita tidak ditemukan.'), findsOneWidget);
  });
}
