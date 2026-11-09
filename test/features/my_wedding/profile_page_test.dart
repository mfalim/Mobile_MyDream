import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/config/app_features.dart';
import 'package:w51/core/media/photo_picker.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/domain/entities/profile_data.dart';
import 'package:w51/features/my_wedding/domain/repositories/avatar_repository.dart';
import 'package:w51/features/my_wedding/domain/repositories/profile_repository.dart';
import 'package:w51/features/my_wedding/presentation/pages/profile_page.dart';
import 'package:w51/features/my_wedding/presentation/providers/avatar_provider.dart';
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

class _FakePicker implements PhotoPicker {
  _FakePicker(this._handler);

  final Future<PickedPhoto?> Function(PhotoSource source) _handler;
  PhotoSource? lastSource;

  @override
  Future<PickedPhoto?> pick(PhotoSource source) {
    lastSource = source;
    return _handler(source);
  }
}

class _FakeAvatarRepo implements AvatarRepository {
  final removed = <String?>[];

  @override
  Future<String> save(String sourcePath) async => sourcePath;

  @override
  Future<void> remove(String? storedPath) async => removed.add(storedPath);
}

/// Tampil bila fitur menyala, tersembunyi bila dimatikan di AppFeatures.
Matcher _shown(bool on) => on ? findsOneWidget : findsNothing;

void main() {
  setUpAll(useTestFonts);

  Future<ProviderContainer> pumpProfile(
    WidgetTester tester, {
    ProfileRepository? profile,
    bool withCouple = true,
    List overrides =
        const [], // <--- Ubah jadi seperti ini (tanpa ProviderOverride)
  }) async {
    final container = ProviderContainer(
      overrides: [
        if (profile != null)
          profileRepositoryProvider.overrideWithValue(profile),
        ...overrides,
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
        markerRoute('/saved', 'HALAMAN TERSIMPAN'),
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

  group('foto profil', () {
    late File photoFile;

    setUp(() {
      photoFile = File('${Directory.systemTemp.path}/mydream_profile_photo.jpg')
        ..writeAsBytesSync([1, 2, 3]);
    });

    tearDown(() {
      if (photoFile.existsSync()) photoFile.deleteSync();
    });

    Future<ProviderContainer> pumpWith(
      WidgetTester tester,
      Future<PickedPhoto?> Function(PhotoSource) handler,
    ) =>
        pumpProfile(
          tester,
          overrides: [
            photoPickerProvider.overrideWithValue(_FakePicker(handler)),
            avatarRepositoryProvider.overrideWithValue(_FakeAvatarRepo()),
          ],
        );

    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.photo_camera_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('pilihan galeri dan kamera; "Hapus foto" hanya bila ada foto',
        (tester) async {
      await pumpWith(tester, (_) async => null);

      await openSheet(tester);

      expect(find.text('Pilih dari galeri'), findsOneWidget);
      expect(find.text('Ambil foto'), findsOneWidget);
      expect(find.text('Hapus foto'), findsNothing);
    });

    testWidgets('galeri: foto tersimpan, lalu bisa dihapus', (tester) async {
      final container = await pumpWith(
        tester,
        (_) async =>
            PickedPhoto(path: photoFile.path, name: 'foto.jpg', bytes: 1000),
      );

      await openSheet(tester);
      await tester.tap(find.text('Pilih dari galeri'));
      await tester.pumpAndSettle();

      expect(container.read(avatarPathProvider), photoFile.path);
      expect(find.text('Foto profil diperbarui.'), findsOneWidget);

      await openSheet(tester);
      await tester.tap(find.text('Hapus foto'));
      await tester.pumpAndSettle();

      expect(container.read(avatarPathProvider), isNull);
    });

    testWidgets('kamera dipakai saat memilih "Ambil foto"', (tester) async {
      final picker = _FakePicker((_) async => null);
      await pumpProfile(
        tester,
        overrides: [
          photoPickerProvider.overrideWithValue(picker),
          avatarRepositoryProvider.overrideWithValue(_FakeAvatarRepo()),
        ],
      );

      await openSheet(tester);
      await tester.tap(find.text('Ambil foto'));
      await tester.pumpAndSettle();

      expect(picker.lastSource, PhotoSource.camera);
    });

    testWidgets('batal memilih: tidak ada perubahan dan tidak ada pesan',
        (tester) async {
      final container = await pumpWith(tester, (_) async => null);

      await openSheet(tester);
      await tester.tap(find.text('Pilih dari galeri'));
      await tester.pumpAndSettle();

      expect(container.read(avatarPathProvider), isNull);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('format tidak didukung ditolak', (tester) async {
      final container = await pumpWith(
        tester,
        (_) async =>
            PickedPhoto(path: photoFile.path, name: 'dokumen.pdf', bytes: 1000),
      );

      await openSheet(tester);
      await tester.tap(find.text('Pilih dari galeri'));
      await tester.pumpAndSettle();

      expect(
          find.text('Format file harus JPG, PNG, atau WEBP.'), findsOneWidget);
      expect(container.read(avatarPathProvider), isNull);
    });

    testWidgets('ukuran di atas 2 MB ditolak', (tester) async {
      final container = await pumpWith(
        tester,
        (_) async => PickedPhoto(
          path: photoFile.path,
          name: 'foto.jpg',
          bytes: 3 * 1024 * 1024,
        ),
      );

      await openSheet(tester);
      await tester.tap(find.text('Pilih dari galeri'));
      await tester.pumpAndSettle();

      expect(find.textContaining('maksimal 2 MB'), findsOneWidget);
      expect(container.read(avatarPathProvider), isNull);
    });

    testWidgets('izin ditolak: pesan jelas', (tester) async {
      await pumpWith(
        tester,
        (source) async => throw PhotoUnavailableException(source),
      );

      await openSheet(tester);
      await tester.tap(find.text('Ambil foto'));
      await tester.pumpAndSettle();

      expect(
        find.text('Tidak bisa membuka kamera. Periksa izin aplikasi.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('tampil dengan data pasangan dan statistik yang nyata',
      (tester) async {
    await pumpProfile(tester);

    expect(find.text('Dewi Mayang & Dimas'), findsOneWidget);
    expect(find.text('Hari Bahagia:'), findsOneWidget);
    expect(find.text('Vendor Disimpan'), findsOneWidget);
    expect(find.text('Keranjang Aktif'), findsOneWidget);
    expect(find.text('Versi ${AppConfig.appVersion}'), findsOneWidget);
    expect(find.text('Inspirasi Board'), findsNothing);
    expect(find.text('Vendor Dihubungi'), findsNothing);
    expect(find.text('Akun Terverifikasi'), findsNothing);
  });

  testWidgets('fitur yang belum siap mengikuti pengaturan AppFeatures',
      (tester) async {
    await pumpProfile(tester);

    expect(
      find.text('MyDream Pay & Cicilan 0%'),
      _shown(AppFeatures.payAndInstallments),
    );
    expect(
      find.text('QR Code Tamu & E-Undangan'),
      _shown(AppFeatures.guestQr),
    );
    expect(find.text('Bahasa Tampilan'), _shown(AppFeatures.languageSwitch));
    expect(
      find.text('Beri Ulasan di Play Store / App Store'),
      _shown(AppFeatures.storeReview),
    );
  });

  testWidgets('data tambahan dari server: lencana dan statistik tampil',
      (tester) async {
    await pumpProfile(
      tester,
      profile: _FakeProfile(
        () async => const ProfileData(
          isVerified: true,
          inspirationBoards: 3,
          vendorsContacted: 4,
        ),
      ),
    );

    expect(find.text('Akun Terverifikasi'), findsOneWidget);
    expect(find.text('Inspirasi Board'), findsOneWidget);
    expect(find.text('Vendor Dihubungi'), findsOneWidget);
    expect(find.text('Keranjang Aktif'), findsOneWidget);
  });

  testWidgets('data tambahan gagal dimuat: Profil tetap tampil',
      (tester) async {
    await tester.runAsync(() async {
      await pumpProfile(
        tester,
        profile: _FakeProfile(() async => throw Exception('gagal')),
      );
      await Future.delayed(const Duration(seconds: 2));
    });

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
    'Vendor Tersimpan': 'HALAMAN TERSIMPAN',
    'Vendor Disimpan': 'HALAMAN TERSIMPAN',
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
