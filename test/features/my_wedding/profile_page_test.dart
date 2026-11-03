import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/domain/repositories/profile_repository.dart';
import 'package:w51/features/my_wedding/presentation/pages/profile_page.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/my_wedding/presentation/providers/profile_provider.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';

import '../../helpers/test_app.dart';

class _FakeProfile implements ProfileRepository {
  _FakeProfile(this._load);

  final Future<ProfileData> Function() _load;

  @override
  Future<ProfileData> load() => _load();
}

void main() {
  setUpAll(useTestFonts);

  Future<ProviderContainer> pumpProfile(
    WidgetTester tester, {
    ProfileRepository? profile,
    bool withCouple = true,
  }) async {
    final container = ProviderContainer(
      overrides: [
        if (profile != null)
          profileRepositoryProvider.overrideWithValue(profile),
      ],
    );
    addTearDown(container.dispose);

    container.read(authProvider.notifier).signInDemo(email: 'dewi@mail.com');
    if (withCouple) {
      final now = DateTime.now();
      container.read(coupleProvider.notifier).save(
            CoupleProfile(
              brideName: 'Dewi Mayang',
              groomName: 'Dimas Arkan',
              weddingDate: DateTime(now.year, now.month, now.day + 60),
            ),
          );
    }

    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/my-wedding',
      routes: [
        GoRoute(
          path: '/my-wedding',
          builder: (context, state) => const Scaffold(body: ProfilePage()),
        ),
        markerRoute('/home', 'HALAMAN HOME'),
        markerRoute('/cart', 'HALAMAN KERANJANG'),
        markerRoute('/account', 'HALAMAN AKUN'),
        markerRoute('/report-issue', 'HALAMAN LAPOR'),
        markerRoute('/notification-settings', 'HALAMAN PREFERENSI'),
        markerRoute('/couple-setup', 'HALAMAN DATA PASANGAN'),
        GoRoute(
          path: '/info/:slug',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('INFO ${state.pathParameters['slug']}')),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('data lengkap: semua bagian tampil', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Dewi Mayang & Dimas'), findsOneWidget);
    expect(find.text('Hari Bahagia:'), findsOneWidget);
    expect(find.text('Akun Terverifikasi'), findsOneWidget);
    expect(find.text('Inspirasi Board'), findsOneWidget);
    expect(find.text('Vendor Dihubungi'), findsOneWidget);
    expect(find.text('Keranjang Aktif'), findsOneWidget);
    expect(find.text('Papan Visi Pernikahan'), findsOneWidget);
    expect(find.text('Versi ${AppConfig.appVersion}'), findsOneWidget);
  });

  testWidgets('tanpa data tambahan: bagian yang kosong tidak tampil',
      (tester) async {
    await pumpProfile(
      tester,
      profile: _FakeProfile(() async => const ProfileData()),
    );

    expect(find.text('Papan Visi Pernikahan'), findsNothing);
    expect(find.text('Akun Terverifikasi'), findsNothing);
    expect(find.text('Inspirasi Board'), findsNothing);
    expect(find.text('Vendor Dihubungi'), findsNothing);
    // Yang nyata tetap ada.
    expect(find.text('Keranjang Aktif'), findsOneWidget);
    expect(find.text('Dewi Mayang & Dimas'), findsOneWidget);
    expect(find.text('Versi ${AppConfig.appVersion}'), findsOneWidget);
  });

  testWidgets('data tambahan gagal dimuat: Profil tetap tampil',
      (tester) async {
    // Bungkus dengan runAsync agar timer async nyata diizinkan selesai
    await tester.runAsync(() async {
      await pumpProfile(
        tester,
        profile: _FakeProfile(() async => throw Exception('gagal')),
      );

      // Beri jeda agar retry terakhir sempat berjalan dan selesai
      await Future.delayed(const Duration(seconds: 2));
    });

    // Lakukan pump terakhir untuk memperbarui frame widget tree
    await tester.pump();

    expect(find.text('Profil gagal dimuat.'), findsNothing);
    expect(find.text('Keranjang Aktif'), findsOneWidget);
    expect(find.text('Papan Visi Pernikahan'), findsNothing);
    expect(find.text('Keluar dari Akun'), findsOneWidget);
  });
  testWidgets('tanpa data pasangan: nama dari akun dan ajakan mengatur tanggal',
      (tester) async {
    await pumpProfile(tester, withCouple: false);

    expect(find.text('dewi'), findsOneWidget);
    expect(find.text('Tanggal pernikahan belum diatur'), findsOneWidget);
    expect(find.text('Hari Bahagia:'), findsNothing);
  });

  const menu = {
    'Pengaturan Akun & Profil': 'HALAMAN AKUN',
    'Laporkan Kendala Teknis': 'HALAMAN LAPOR',
    'Preferensi Notifikasi': 'HALAMAN PREFERENSI',
    'Syarat & Ketentuan Layanan': 'INFO terms',
    'Kebijakan Privasi': 'INFO privacy',
    'Atur Tanggal': 'HALAMAN DATA PASANGAN',
    'Keranjang Aktif': 'HALAMAN KERANJANG',
  };

  for (final entry in menu.entries) {
    testWidgets('mengetuk "${entry.key}" membuka tujuannya', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('baris yang belum tersedia menampilkan "segera hadir"',
      (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('QR Code Tamu & E-Undangan'));
    await tester.pump();

    expect(find.text('QR code tamu segera hadir.'), findsOneWidget);
  });

  testWidgets('Support & Concierge membuka chat admin', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Support & Concierge Planner'));
    await tester.pumpAndSettle();

    expect(find.text('Chat Admin MyDream'), findsOneWidget);
  });

  testWidgets('keluar: Batal tidak mengeluarkan akun', (tester) async {
    final container = await pumpProfile(tester);

    await tester.tap(find.text('Keluar dari Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari Akun?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari Akun?'), findsNothing);
    expect(container.read(authProvider), isNotNull);
    expect(find.text('HALAMAN HOME'), findsNothing);
  });

  testWidgets('keluar: akun, keranjang, dan data pasangan dibersihkan',
      (tester) async {
    final container = await pumpProfile(tester);
    container.read(cartProvider.notifier).add(
          CartItem.fromPackage(
            await PackagesMockDatasource().fetch('pkg-intimate-bali'),
          ),
        );

    await tester.tap(find.text('Keluar dari Akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(container.read(authProvider), isNull);
    expect(container.read(coupleProvider), isNull);
    expect(container.read(cartProvider).items, isEmpty);
    expect(find.text('HALAMAN HOME'), findsOneWidget);
    expect(find.text('Kamu sudah keluar.'), findsOneWidget);
  });
}
