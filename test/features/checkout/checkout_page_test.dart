import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/presentation/pages/checkout_page.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';

import '../../helpers/test_app.dart';

final _venueName =
    find.widgetWithText(TextFormField, 'Contoh: Gedung Serbaguna Nusa');
final _venueAddress =
    find.widgetWithText(TextFormField, 'Jalan, nomor, kelurahan, kecamatan');
final _venueCity = find.widgetWithText(TextFormField, 'Contoh: Badung');
final _guests = find.widgetWithText(TextFormField, 'Contoh: 150');
final _pic = find.widgetWithText(TextFormField, 'Nama penanggung jawab');
final _whatsapp = find.widgetWithText(TextFormField, '812 9874 3210');
final _submit = find.text('Konfirmasi & Lanjut');

void main() {
  late CartItem item;

  setUpAll(() async {
    useTestFonts();
    // Paket Intimate Bali: kapasitas 100 tamu.
    item = CartItem.fromPackage(
      await PackagesMockDatasource().fetch('pkg-intimate-bali'),
    );
  });

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(item);
  });

  Future<void> pumpCheckout(WidgetTester tester) async {
    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/checkout',
      routes: [
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        markerRoute('/payment', 'HALAMAN PEMBAYARAN'),
        markerRoute('/cart', 'HALAMAN KERANJANG'),
      ],
    );
  }

  testWidgets(
      'form kosong: semua pesan merah muncul, tidak lanjut, tidak tersimpan',
      (tester) async {
    await pumpCheckout(tester);

    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(
      find.text('Periksa kembali isian yang ditandai merah.'),
      findsOneWidget,
    );
    for (final message in [
      'Nama pengantin wanita wajib diisi',
      'Nama pengantin pria wajib diisi',
      'Pilih tanggal pelaksanaan',
      'Nama venue wajib diisi',
      'Alamat wajib diisi',
      'Kota wajib diisi',
      'Provinsi wajib dipilih',
      'Jumlah tamu wajib diisi',
      'Nama PIC wajib diisi',
      'Nomor WhatsApp wajib diisi',
    ]) {
      expect(find.text(message), findsOneWidget, reason: message);
    }
    expect(find.text('HALAMAN PEMBAYARAN'), findsNothing);
    expect(container.read(checkoutProvider), isNull);
  });

  testWidgets('jumlah tamu dibatasi kapasitas paket', (tester) async {
    await pumpCheckout(tester);

    expect(find.text('Kapasitas paket ini hingga 100 tamu.'), findsOneWidget);

    await tester.enterText(_guests, '150');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(find.text('Maksimal 100 tamu untuk paket ini'), findsOneWidget);
  });

  testWidgets('WhatsApp tidak boleh diawali 0', (tester) async {
    await pumpCheckout(tester);

    await tester.enterText(_whatsapp, '0812345678');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(
      find.text('Tulis tanpa angka 0 di depan (contoh: 811...)'),
      findsOneWidget,
    );
  });

  testWidgets('data pasangan mengisi nama dan tanggal otomatis',
      (tester) async {
    final now = DateTime.now();
    container.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: 'Dewi Mayang',
            groomName: 'Dimas Arkan',
            weddingDate: DateTime(now.year, now.month, now.day + 60),
          ),
        );
    await pumpCheckout(tester);

    await tester.tap(_submit);
    await tester.pumpAndSettle();

    // Nama dan tanggal sudah terisi, jadi tidak ada pesan merahnya.
    expect(find.text('Nama pengantin wanita wajib diisi'), findsNothing);
    expect(find.text('Nama pengantin pria wajib diisi'), findsNothing);
    expect(find.text('Pilih tanggal pelaksanaan'), findsNothing);
    // Isian lain masih kosong.
    expect(find.text('Nama venue wajib diisi'), findsOneWidget);
  });

  testWidgets('isian lengkap: tersimpan lalu lanjut ke pembayaran',
      (tester) async {
    final now = DateTime.now();
    final weddingDate = DateTime(now.year, now.month, now.day + 60);
    container.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: 'Dewi Mayang',
            groomName: 'Dimas Arkan',
            weddingDate: weddingDate,
          ),
        );
    await pumpCheckout(tester);
    await tester.enterText(_venueName, 'Gedung Nusa');
    await tester.enterText(_venueAddress, 'Jalan Raya No. 1, Kecamatan Kuta');
    await tester.enterText(_venueCity, 'Badung');

    // 1. Cukup tap dropdown 'Pilih provinsi' agar menu pilihannya terbuka
    await tester.tap(find.text('Pilih provinsi').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // 2. Tap pilihan provinsinya (misal 'Aceh') langsung setelah terbuka
    await tester.tap(find.text('Aceh').last);
    await tester.pumpAndSettle();

    await tester.enterText(_guests, '80');
    await tester.enterText(_pic, 'Dewi');
    await tester.enterText(_whatsapp, '81298743210');
    await tester.tap(_submit);
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN PEMBAYARAN'), findsOneWidget);

    final d = container.read(checkoutProvider)!;
    expect(d.vendorId, 'pkg-intimate-bali');
    expect(d.brideName, 'Dewi Mayang');
    expect(d.groomName, 'Dimas Arkan');
    expect(
      d.eventDate,
      DateTime(weddingDate.year, weddingDate.month, weddingDate.day),
    );
    expect(d.ceremonyMinutes, 930);
    expect(d.receptionMinutes, 1110);
    expect(d.venueName, 'Gedung Nusa');
    expect(d.venueAddress, 'Jalan Raya No. 1, Kecamatan Kuta');
    expect(d.venueCity, 'Badung');
    expect(d.venueProvince, 'Aceh');
    expect(d.venueMaps, isNull);
    expect(d.guestCount, 80);
    expect(d.picName, 'Dewi');
    expect(d.whatsapp, '+6281298743210');
  });
}
