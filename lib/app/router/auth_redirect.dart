import 'route_names.dart';

/// Tujuan internal yang aman dari parameter `from`. Alamat eksternal atau
/// kosong menjadi Home.
String safeInternalPath(String? from) {
  if (from != null && from.startsWith('/') && !from.startsWith('//')) {
    return from;
  }
  return AppRoutes.home;
}

/// Tujuan setelah berhasil masuk atau daftar: tujuan semula, layar pasangan untuk client,
/// atau dashboard member untuk kru EO.
String postLoginDestination({
  String? from,
  String? role,
  bool needsCoupleSetup = false,
  bool needsMemberSetup = false,
}) {
  if (role == 'member') {
    if (needsMemberSetup) {
      return AppRoutes.memberCompleteProfile;
    }
    return AppRoutes.memberDashboard;
  }

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
  String? role,
  bool needsCoupleSetup = false,
  bool needsMemberSetup = false,
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

  // Sudah login tapi berada di Login/Register -> ke tujuan yang sesuai role
  if (loggedIn && AppRoutes.authPaths.contains(path)) {
    return postLoginDestination(
      from: uri.queryParameters['from'],
      role: role,
      needsCoupleSetup: needsCoupleSetup,
      needsMemberSetup: needsMemberSetup,
    );
  }

  // Penjagaan khusus akun Member (Kru WO)
  if (loggedIn && role == 'member') {
    if (needsMemberSetup && path != AppRoutes.memberCompleteProfile) {
      return AppRoutes.memberCompleteProfile;
    }
    if (path == AppRoutes.coupleSetup) {
      return AppRoutes.memberDashboard;
    }
  }

  // Penjagaan akun Client agar tidak masuk ke halaman operasional Member
  if (loggedIn && role == 'client' && path.startsWith('/member')) {
    return AppRoutes.home;
  }

  return null;
}
