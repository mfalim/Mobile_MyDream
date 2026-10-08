// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:w51/app/app.dart';

void main() {
  testWidgets('bottom navigation switches between feature pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Selamat datang'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'mfalim13@gmail.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'password-salah',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(
        find.text('Email atau kata sandi demo tidak cocok.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'qwerty123',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Wedora'), findsOneWidget);

    await tester.tap(find.text('Vendors'));
    await tester.pumpAndSettle();
    expect(find.text('Cari vendor berdasarkan:'), findsOneWidget);

    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();
    expect(find.text('Detail kecil, makna besar'), findsOneWidget);

    await tester.tap(find.text('Inspirations'));
    await tester.pumpAndSettle();
    expect(find.text('IDEA BOARD'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Akun saya'), findsOneWidget);
  });

  testWidgets('Google login button opens the homepage',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byKey(const ValueKey('google-logo')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('google-login')));
    await tester.tap(find.byKey(const ValueKey('google-login')));
    await tester.pumpAndSettle();

    expect(find.text('Wedora'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Google'), findsNothing);
  });
}
