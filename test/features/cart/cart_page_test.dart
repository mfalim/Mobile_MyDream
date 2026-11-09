import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';
import 'package:w51/features/cart/presentation/pages/cart_page.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_mock_datasource.dart';
import 'package:w51/core/config/app_features.dart';
import '../../helpers/test_app.dart';

/// Lumière 15.000.000 + Santap Rasa 17.500.000 + Sora 18.500.000 = 51.000.000
Future<List<CustomVendorItem>> _threeVendors() async {
  final datasource = VendorDetailMockDatasource();
  return [
    for (final id in ['vendor-lumiere', 'vendor-santap', 'vendor-sora'])
      CustomVendorItem.fromVendorDetail(await datasource.fetch(id)),
  ];
}

Future<CartItem> _intimatePackage() async => CartItem.fromPackage(
      await PackagesMockDatasource().fetch('pkg-intimate-bali'),
    );

Future<Voucher> _voucher(String code) async =>
    (await VoucherMockDatasource().fetch()).firstWhere((v) => v.code == code);

FilledButton _button(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(
      find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
    );

void main() {
  setUpAll(useTestFonts);

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  CartController controller() => container.read(cartProvider.notifier);
  CartState state() => container.read(cartProvider);

  Future<void> pumpCart(
    WidgetTester tester, {
    int initialTab = 0,
    String? claimCode,
  }) async {
    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/cart',
      routes: [
        GoRoute(
          path: '/cart',
          builder: (context, state) =>
              CartPage(initialTab: initialTab, claimCode: claimCode),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) =>
              Scaffold(body: Center(child: Text('CHECKOUT ${state.uri}'))),
        ),
        GoRoute(
          path: '/vendor/:id',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('VENDOR ${state.pathParameters['id']}')),
          ),
        ),
        GoRoute(
          path: '/package/:id',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('PAKET ${state.pathParameters['id']}')),
          ),
        ),
        markerRoute('/vendors', 'HALAMAN VENDORS'),
        markerRoute('/packages', 'HALAMAN PAKET'),
        markerRoute('/home', 'HALAMAN HOME'),
        GoRoute(
          path: '/info/:slug',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('INFO ${state.pathParameters['slug']}')),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  group('keranjang kosong', () {
    testWidgets('tab paket: ajakan melihat paket atau membuat custom order',
        (tester) async {
      await pumpCart(tester);

      expect(
        find.textContaining('Belum ada paket pernikahan di keranjang'),
        findsOneWidget,
      );
      expect(find.text('Lihat Paket Pernikahan'), findsOneWidget);
      expect(find.text('Buat Custom Order'), findsOneWidget);
      expect(find.textContaining('Lanjut ke Validasi Data'), findsNothing);

      await tester.tap(find.text('Buat Custom Order'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Custom Order masih kosong'), findsOneWidget);
    });

    testWidgets('"Lihat Paket Pernikahan" membuka daftar paket',
        (tester) async {
      await pumpCart(tester);

      await tester.tap(find.text('Lihat Paket Pernikahan'));
      await tester.pumpAndSettle();

      expect(find.text('HALAMAN PAKET'), findsOneWidget);
    });

    testWidgets('tab custom: "Pilih Vendor" membuka daftar vendor',
        (tester) async {
      await pumpCart(tester, initialTab: 1);

      expect(find.textContaining('Custom Order masih kosong'), findsOneWidget);
      await tester.tap(find.text('Pilih Vendor'));
      await tester.pumpAndSettle();

      expect(find.text('HALAMAN VENDORS'), findsOneWidget);
    });
  });

  group('custom order', () {
    testWidgets('dua vendor: syarat belum terpenuhi, tombol lanjut nonaktif',
        (tester) async {
      final vendors = await _threeVendors();
      controller().addCustomVendor(vendors[0]);
      controller().addCustomVendor(vendors[1]);
      await pumpCart(tester, initialTab: 1);

      expect(find.text('Pilih minimal 3 vendor'), findsOneWidget);
      expect(find.textContaining('2 dari minimal 3 vendor'), findsOneWidget);
      expect(find.text('Pilih 1 vendor lagi'), findsOneWidget);
      expect(_button(tester, 'Pilih 1 vendor lagi').onPressed, isNull);
      expect(find.text('IDR 32.500.000'), findsWidgets);
    });

    testWidgets('tiga vendor: syarat terpenuhi dan lanjut ke checkout custom',
        (tester) async {
      for (final v in await _threeVendors()) {
        controller().addCustomVendor(v);
      }
      await pumpCart(tester, initialTab: 1);

      expect(find.text('Syarat terpenuhi'), findsOneWidget);
      expect(find.text('IDR 51.000.000'), findsWidgets);
      const label = 'Lanjut ke Validasi Data (3 Vendor)';
      expect(_button(tester, label).onPressed, isNotNull);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(find.text('CHECKOUT /checkout?type=custom'), findsOneWidget);
    });

    testWidgets('menghapus vendor menurunkan lagi syarat minimal',
        (tester) async {
      for (final v in await _threeVendors()) {
        controller().addCustomVendor(v);
      }
      await pumpCart(tester, initialTab: 1);

      await tester.tap(find.byTooltip('Hapus dari Custom Order').first);
      await tester.pumpAndSettle();

      expect(state().customVendors.length, 2);
      expect(find.text('Pilih 1 vendor lagi'), findsOneWidget);
      expect(find.text('Syarat terpenuhi'), findsNothing);
    });

    testWidgets('mengetuk vendor membuka detailnya', (tester) async {
      for (final v in await _threeVendors()) {
        controller().addCustomVendor(v);
      }
      await pumpCart(tester, initialTab: 1);

      await tester.tap(find.text('Lumière Cinematic Films'));
      await tester.pumpAndSettle();

      expect(find.text('VENDOR vendor-lumiere'), findsOneWidget);
    });

    testWidgets('"Tambah Vendor" membuka daftar vendor', (tester) async {
      controller().addCustomVendor((await _threeVendors()).first);
      await pumpCart(tester, initialTab: 1);

      await tester.tap(find.text('Tambah Vendor'));
      await tester.pumpAndSettle();

      expect(find.text('HALAMAN VENDORS'), findsOneWidget);
    });
  });

  group('paket di keranjang', () {
    testWidgets('kartu paket, hemat, dan bar lanjut', (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester);

      expect(find.text('Paket Intimate Bali'), findsOneWidget);
      expect(find.text('Hemat Rp 7.000.000'), findsOneWidget);
      expect(find.text('Vendor dalam paket'), findsOneWidget);
      expect(find.text('IDR 95.000.000'), findsWidgets);
      expect(find.text('Lanjut ke Validasi Data (1 Item)'), findsOneWidget);
    });

    testWidgets('lanjut membuka checkout paket (bukan custom)', (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester);

      await tester.tap(find.text('Lanjut ke Validasi Data (1 Item)'));
      await tester.pumpAndSettle();

      expect(find.text('CHECKOUT /checkout'), findsOneWidget);
    });

    testWidgets('"Lihat Detail" membuka detail paket', (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester);

      await tester.tap(find.text('Lihat Detail'));
      await tester.pumpAndSettle();

      expect(find.text('PAKET pkg-intimate-bali'), findsOneWidget);
    });

    testWidgets('mencabut centang menonaktifkan tombol lanjut', (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(
        _button(tester, 'Lanjut ke Validasi Data (0 Item)').onPressed,
        isNull,
      );
    });

    testWidgets('menghapus paket mengembalikan keranjang kosong',
        (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester);

      await tester.tap(find.byTooltip('Hapus dari keranjang'));
      await tester.pumpAndSettle();

      expect(state().items, isEmpty);
      expect(
        find.textContaining('Belum ada paket pernikahan di keranjang'),
        findsOneWidget,
      );
    });

    testWidgets('berpindah tab menampilkan isi masing-masing', (tester) async {
      controller().add(await _intimatePackage());
      for (final v in await _threeVendors()) {
        controller().addCustomVendor(v);
      }
      await pumpCart(tester);

      expect(find.text('Paket Intimate Bali'), findsOneWidget);
      expect(find.text('Syarat terpenuhi'), findsNothing);

      await tester.tap(find.text('Custom Order'));
      await tester.pumpAndSettle();

      expect(find.text('Syarat terpenuhi'), findsOneWidget);
      expect(find.text('Paket Intimate Bali'), findsNothing);
    });
  });

  group('voucher', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.text('Voucher Pernikahan'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih Voucher'), findsOneWidget);
    }

    Future<void> typeCode(WidgetTester tester, String code) async {
      await tester.enterText(find.byType(TextField), code);
      await tester.tap(find.text('Pasang'));
      await tester.pumpAndSettle();
    }

    Future<void> threeVendorsInCart() async {
      for (final v in await _threeVendors()) {
        controller().addCustomVendor(v);
      }
    }

    testWidgets('tanpa voucher: ajakan memilih', (tester) async {
      await threeVendorsInCart();
      await pumpCart(tester, initialTab: 1);

      expect(
          find.text('Pilih voucher untuk hemat lebih banyak'), findsOneWidget);
    });

    testWidgets('mengetik kode yang memenuhi syarat memasang voucher',
        (tester) async {
      await threeVendorsInCart();
      await pumpCart(tester, initialTab: 1);

      await openSheet(tester);
      await typeCode(tester, 'dreamwedding');

      expect(state().voucher?.code, 'DREAMWEDDING');
      expect(find.text('Pilih Voucher'), findsNothing);
      expect(
        find.text("Kupon 'DREAMWEDDING' dipasang (hemat IDR 5.000.000)"),
        findsOneWidget,
      );
      expect(find.text('IDR 46.000.000'), findsWidgets);
    });

    testWidgets('persentase dengan batas: NEWCOUPLE 3% dari 51 juta',
        (tester) async {
      await threeVendorsInCart();
      await pumpCart(tester, initialTab: 1);

      await openSheet(tester);
      await typeCode(tester, 'NEWCOUPLE');

      expect(state().customDiscount, 1530000);
      expect(
        find.text("Kupon 'NEWCOUPLE' dipasang (hemat IDR 1.530.000)"),
        findsOneWidget,
      );
    });

    testWidgets('belanja minimal belum terpenuhi: ditolak dengan selisihnya',
        (tester) async {
      await threeVendorsInCart();
      await pumpCart(tester, initialTab: 1);

      await openSheet(tester);
      await typeCode(tester, 'BRIDALEXPO');

      expect(
        find.text('Belanja minimal IDR 300.000.000 (kurang IDR 249.000.000)'),
        findsNWidgets(2),
      );
      expect(find.text('Pilih Voucher'), findsOneWidget);
      expect(state().voucher, isNull);
    });

    testWidgets('kode tidak dikenal dan kode kosong', (tester) async {
      await threeVendorsInCart();
      await pumpCart(tester, initialTab: 1);

      await openSheet(tester);
      await typeCode(tester, 'TIDAKADA');
      expect(find.text('Kode voucher tidak ditemukan.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Pasang'));
      await tester.pumpAndSettle();
      expect(find.text('Masukkan kode voucher.'), findsOneWidget);
      expect(state().voucher, isNull);
    });

    testWidgets('melepas voucher yang terpasang', (tester) async {
      await threeVendorsInCart();
      controller().selectVoucher(await _voucher('DREAMWEDDING'));
      await pumpCart(tester, initialTab: 1);

      await openSheet(tester);
      await tester.tap(find.text('Lepas voucher (tanpa voucher)'));
      await tester.pumpAndSettle();

      expect(state().voucher, isNull);
      expect(
          find.text('Pilih voucher untuk hemat lebih banyak'), findsOneWidget);
    });

    testWidgets(
        'belanja turun di bawah minimal: voucher ditandai belum memenuhi',
        (tester) async {
      await threeVendorsInCart();
      controller().selectVoucher(await _voucher('DREAMWEDDING'));
      await pumpCart(tester, initialTab: 1);

      await tester.tap(find.byTooltip('Hapus dari Custom Order').last);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Kupon DREAMWEDDING: belanja minimal IDR 50.000.000 belum terpenuhi',
        ),
        findsOneWidget,
      );
      expect(state().customDiscount, 0);
    });

    testWidgets('voucher berlaku untuk paket: 95 juta dikurangi 5 juta',
        (tester) async {
      controller().add(await _intimatePackage());
      controller().selectVoucher(await _voucher('DREAMWEDDING'));
      await pumpCart(tester);

      expect(find.text('IDR 90.000.000'), findsWidgets);
    });

    testWidgets('tombol klaim (?claim=KODE) memasang voucher', (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester, claimCode: 'NEWCOUPLE');

      expect(state().voucher?.code, 'NEWCOUPLE');
      expect(find.text('Voucher NEWCOUPLE dipasang.'), findsOneWidget);
    });

    testWidgets('klaim kode yang tidak ada: pesan tidak ditemukan',
        (tester) async {
      controller().add(await _intimatePackage());
      await pumpCart(tester, claimCode: 'XXXX');

      expect(state().voucher, isNull);
      expect(find.text('Voucher tidak ditemukan.'), findsOneWidget);
    });
  });

  testWidgets('"Bantuan" membuka chat admin', (tester) async {
    controller().add(await _intimatePackage());
    await pumpCart(tester);

    await tester.tap(find.text('Bantuan'));
    await tester.pumpAndSettle();

    expect(find.text('Chat Admin MyDream'), findsOneWidget);
  });

  testWidgets('klaim yang belum diputuskan mengikuti AppFeatures.escrowClaims',
      (tester) async {
    controller().add(await _intimatePackage());
    await pumpCart(tester);

    Matcher shown(bool on) => on ? findsOneWidget : findsNothing;
    expect(
        find.text('100% Escrow Protection'), shown(AppFeatures.escrowClaims));
    expect(find.text('Biaya Layanan Escrow Concierge'),
        shown(AppFeatures.escrowClaims));
    expect(find.text('Transfer Bank'), shown(!AppFeatures.escrowClaims));
    expect(find.text('Ketentuan Layanan'), shown(!AppFeatures.escrowClaims));
  });
}
