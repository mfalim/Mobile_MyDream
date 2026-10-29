import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/features/auth/presentation/pages/login_page.dart';
import 'package:w51/features/auth/presentation/pages/register_page.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';

import '../../helpers/test_app.dart';

final _name = find.widgetWithText(TextFormField, 'Nama kamu');
final _email = find.widgetWithText(TextFormField, 'nama@email.com');
final _password = find.widgetWithText(TextFormField, 'Buat kata sandi');
final _confirm = find.widgetWithText(TextFormField, 'Ketik ulang kata sandi');

void main() {
  setUpAll(useTestFonts);

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> pumpRegister(WidgetTester tester) async {
    useTallViewport(tester);
    await pumpRouter(
      tester,
      container: container,
      initialLocation: '/register?from=%2Fcart',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              RegisterPage(from: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              LoginPage(from: state.uri.queryParameters['from']),
        ),
        markerRoute('/home', 'HALAMAN HOME'),
        markerRoute('/cart', 'HALAMAN KERANJANG'),
        markerRoute('/couple-setup', 'HALAMAN DATA PASANGAN'),
      ],
    );
  }

  testWidgets('form kosong: semua pesan wajib diisi muncul', (tester) async {
    await pumpRegister(tester);

    await tester.tap(find.text('Buat Akun'));
    await tester.pump();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    expect(find.text('Ulangi kata sandi'), findsOneWidget);
    expect(container.read(authProvider), isNull);
  });

  testWidgets('kata sandi lemah dan konfirmasi tidak sama ditolak',
      (tester) async {
    await pumpRegister(tester);

    await tester.enterText(_name, 'Dewi');
    await tester.enterText(_email, 'dewi@mail.com');
    await tester.enterText(_password, 'abcdefgh');
    await tester.enterText(_confirm, 'berbeda123');
    await tester.tap(find.text('Buat Akun'));
    await tester.pump();

    expect(find.text('Gunakan kombinasi huruf dan angka'), findsOneWidget);
    expect(find.text('Kata sandi tidak sama'), findsOneWidget);
    expect(container.read(authProvider), isNull);
  });

  testWidgets('daftar valid: akun dibuat dengan nama yang diisi',
      (tester) async {
    await pumpRegister(tester);

    await tester.enterText(_name, 'Dewi');
    await tester.enterText(_email, 'dewi@mail.com');
    await tester.enterText(_password, 'abcd1234');
    await tester.enterText(_confirm, 'abcd1234');
    await tester.tap(find.text('Buat Akun'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN DATA PASANGAN'), findsOneWidget);
    expect(container.read(authProvider)?.name, 'Dewi');
    expect(container.read(authProvider)?.email, 'dewi@mail.com');
  });
}
