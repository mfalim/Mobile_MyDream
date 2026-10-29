import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/payment/presentation/pages/payment_page.dart';

import '../../helpers/test_app.dart';

CheckoutDetails _details() => CheckoutDetails(
      vendorId: 'pkg-intimate-bali',
      brideName: 'Dewi',
      groomName: 'Dimas',
      eventDate: DateTime(2027, 3, 1),
      ceremonyMinutes: 930,
      receptionMinutes: 1110,
      venueName: 'Gedung Nusa',
      venueAddress: 'Jalan Raya No. 1',
      venueCity: 'Badung',
      venueProvince: 'Bali',
      guestCount: 80,
      concept: 'Modern Romantic',
      picName: 'Dewi',
      whatsapp: '+6281298743210',
      notes: '',
    );

void main() {
  late CartItem item;

  setUpAll(() async {
    useTestFonts();
    item = CartItem.fromPackage(
      await PackagesMockDatasource().fetch('pkg-intimate-bali'),
    );
  });

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(item);
    container.read(checkoutProvider.notifier).save(_details());
  });

  Future<void> pumpPayment(WidgetTester tester) async {
    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/payment',
      routes: [
        GoRoute(
          path: '/payment',
          builder: (context, state) => const PaymentPage(),
        ),
        markerRoute('/checkout', 'HALAMAN CHECKOUT'),
        markerRoute('/cart', 'HALAMAN KERANJANG'),
        markerRoute('/order-submitted', 'HALAMAN PESANAN TERKIRIM'),
      ],
    );
    // Rekening tujuan dimuat setelah frame pertama.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('kirim tanpa bukti transfer ditolak', (tester) async {
    await pumpPayment(tester);

    await tester.tap(find.text('Kirim Pesanan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Unggah bukti transfer terlebih dahulu.'),
      findsWidgets,
    );
    expect(find.text('HALAMAN PESANAN TERKIRIM'), findsNothing);
    // Pesanan belum dikirim, jadi keranjang masih berisi paket.
    expect(container.read(cartProvider).items.length, 1);
  });

  testWidgets('ganti skema DP ke pelunasan mengubah semua jumlah transfer',
      (tester) async {
    await pumpPayment(tester);

    expect(find.text('Uang Muka (DP)'), findsOneWidget);
    expect(find.text('Pelunasan Penuh'), findsOneWidget);

    // Mode DP: Rp 1.000.000 tampil di pilihan DP, kartu rekening, rincian,
    // dan bar bawah.
    expect(find.text('IDR 1.000.000'), findsNWidgets(4));

    await tester.tap(find.text('Pelunasan Penuh'));
    await tester.pump();

    // Mode lunas: hanya tersisa di pilihan DP.
    expect(find.text('IDR 1.000.000'), findsNWidgets(1));
  });
}
