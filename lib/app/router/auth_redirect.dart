import 'route_names.dart';

/// Tujuan internal yang aman dari parameter `from`. Alamat eksternal atau
/// kosong menjadi Home.
String safeInternalPath(String? from) {
  if (from != null && from.startsWith('/') && !from.startsWith('//')) {
    return from;
  }
  return AppRoutes.home;
}

/// Tujuan setelah berhasil masuk atau daftar: tujuan semula, atau layar data
/// pasangan dulu bila belum diisi (sekali setelah login).
String postLoginDestination({
  String? from,
  required bool needsCoupleSetup,
}) {
  final target = safeInternalPath(from);
  if (needsCoupleSetup && !target.startsWith(AppRoutes.coupleSetup)) {
    return AppRoutes.coupleSetupPath(from: target);
  }
  return target;
}

/// Aturan penjaga login. Mengembalikan alamat tujuan baru, atau `null`
/// bila tidak perlu dialihkan.
String? authRedirect({
  required bool loggedIn,
  required Uri uri,
  bool needsCoupleSetup = false,
}) {
  final path = uri.path;
  final isProtected = AppRoutes.protectedPaths.any(
    (p) => path == p || path.startsWith('$p/'),
  );

  // Tamu membuka halaman yang butuh login -> ke Login, ingat tujuannya.
  if (!loggedIn && isProtected) {
    return Uri(
      path: AppRoutes.login,
      queryParameters: {'from': uri.toString()},
    ).toString();
  }

  // Sudah login tapi berada di Login/Register -> ke tujuan semula.
  if (loggedIn && AppRoutes.authPaths.contains(path)) {
    return postLoginDestination(
      from: uri.queryParameters['from'],
      needsCoupleSetup: needsCoupleSetup,
    );
  }

  return null;
}
