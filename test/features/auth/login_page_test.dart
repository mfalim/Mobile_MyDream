import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/auth/presentation/pages/login_page.dart';
import 'package:w51/features/auth/presentation/pages/register_page.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

import '../../helpers/test_app.dart';

final _email = find.widgetWithText(TextFormField, 'nama@email.com');
final _password = find.widgetWithText(TextFormField, 'Masukkan kata sandi');

void main() {
  setUpAll(useTestFonts);

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/login?from=%2Fcart',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              LoginPage(from: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              RegisterPage(from: state.uri.queryParameters['from']),
        ),
        markerRoute('/home', 'HALAMAN HOME'),
        markerRoute('/cart', 'HALAMAN KERANJANG'),
        markerRoute('/couple-setup', 'HALAMAN DATA PASANGAN'),
      ],
    );
  }

  void saveCouple() {
    container.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: 'Dewi',
            groomName: 'Dimas',
            weddingDate: DateTime(2030, 1, 1),
          ),
        );
  }

  testWidgets('form kosong: pesan wajib diisi, tidak masuk', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    expect(container.read(authProvider), isNull);
  });

  testWidgets('email salah format ditolak', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(_email, 'abc');
    await tester.enterText(_password, 'abcd1234');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Masukkan format email yang valid'), findsOneWidget);
    expect(container.read(authProvider), isNull);
  });

  testWidgets('login valid: spinner, lalu pindah ke tujuan semula',
      (tester) async {
    saveCouple();
    await pumpLogin(tester);

    await tester.enterText(_email, 'dewi@mail.com');
    await tester.enterText(_password, 'abcd1234');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN KERANJANG'), findsOneWidget);
    expect(container.read(authProvider)?.email, 'dewi@mail.com');
    expect(container.read(authProvider)?.hasPassword, isTrue);
  });

  testWidgets('data pasangan belum diisi: lewat layar data pasangan dulu',
      (tester) async {
    await pumpLogin(tester);

    await tester.enterText(_email, 'dewi@mail.com');
    await tester.enterText(_password, 'abcd1234');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN DATA PASANGAN'), findsOneWidget);
  });

  testWidgets('saat memproses, tombol Google nonaktif (tidak bisa kirim ganda)',
      (tester) async {
    await pumpLogin(tester);

    await tester.enterText(_email, 'dewi@mail.com');
    await tester.enterText(_password, 'abcd1234');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    final google = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(google.onPressed, isNull);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  });

  testWidgets('Google: masuk tanpa kata sandi', (tester) async {
    saveCouple();
    await pumpLogin(tester);

    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN KERANJANG'), findsOneWidget);
    expect(container.read(authProvider)?.hasPassword, isFalse);
  });

  testWidgets('tombol Daftar membuka halaman Register', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Mulai Rencanakan Hari Bahagia'), findsOneWidget);
  });

  testWidgets('Lanjut sebagai tamu membuka Home tanpa login', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Lanjut sebagai tamu'));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN HOME'), findsOneWidget);
    expect(container.read(authProvider), isNull);
  });
}
