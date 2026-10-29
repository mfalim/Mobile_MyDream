import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/theme/app_theme.dart';
import 'package:w51/app/theme/app_typography.dart';

/// Panggil di setUpAll: font Google tidak diunduh saat tes.
void useTestFonts() => AppTypography.useGoogleFonts = false;

/// Layar lebar dan tinggi. Font tes (Ahem) lebih lebar daripada font asli,
/// jadi layar sempit membuat tata letak overflow yang tidak terjadi di HP.
void useTallViewport(WidgetTester tester, {Size size = const Size(900, 4000)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Menampilkan [routes] dengan GoRouter mulai dari [initialLocation].
Future<GoRouter> pumpRouter(
  WidgetTester tester, {
  required ProviderContainer container,
  required List<RouteBase> routes,
  required String initialLocation,
}) async {
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pump();
  return router;
}

/// Halaman penanda untuk memastikan navigasi sampai ke tujuan.
GoRoute markerRoute(String path, String text) => GoRoute(
      path: path,
      builder: (context, state) => Scaffold(body: Center(child: Text(text))),
    );
