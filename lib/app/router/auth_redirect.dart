import 'route_names.dart';

/// Aturan penjaga login. Mengembalikan alamat tujuan baru, atau `null`
/// bila tidak perlu dialihkan.
String? authRedirect({required bool loggedIn, required Uri uri}) {
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

  // Sudah login tapi berada di Login -> kembali ke tujuan semula.
  if (loggedIn && path == AppRoutes.login) {
    final from = uri.queryParameters['from'];
    // Hanya alamat internal aplikasi yang diterima.
    if (from != null && from.startsWith('/') && !from.startsWith('//')) {
      return from;
    }
    return AppRoutes.home;
  }

  return null;
}
