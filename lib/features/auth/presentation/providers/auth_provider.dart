import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/auth/data/user_codec.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

import '../../domain/entities/app_user.dart';

/// Status login. `null` berarti tamu (belum login).
final authProvider = NotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    // 1. Pulihkan sesi dari penyimpanan lokal untuk startup instan
    final cached = UserCodec.decode(
      ref.read(localStorageProvider).getJson(kStorageUser),
    );

    // 2. Di mode API, periksa dan sinkronkan sesi terbaru via GET /me (auth:sanctum)
    if (!AppConfig.useMockData) {
      Future.microtask(() => checkSession());
    }

    return cached;
  }

  /// Sinkronkan sesi pengguna ke server lewat GET /me (middleware auth:sanctum).
  Future<void> checkSession() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      if (state != null) state = null;
      return;
    }

    try {
      final client = ref.read(apiClientProvider);
      final dynamic raw = await client.get('/me');
      if (raw is Map<String, dynamic>) {
        final userMap = raw['user'] is Map<String, dynamic>
            ? raw['user'] as Map<String, dynamic>
            : raw;
        final role = (raw['role'] ?? userMap['role'])?.toString() ?? 'client';
        final clientData = raw['client'] is Map<String, dynamic>
            ? raw['client'] as Map<String, dynamic>
            : (userMap['client'] is Map<String, dynamic>
                ? userMap['client'] as Map<String, dynamic>
                : null);

        // Sinkronkan data pasangan (tabel `clients` di MySQL) terlebih dahulu
        ref
            .read(coupleProvider.notifier)
            .syncFromServer(clientData, isClientRole: role == 'client');

        final updatedUser = UserCodec.fromApiResponse({
          'user': userMap,
          'role': role,
        });
        state = updatedUser;
        ref
            .read(localStorageProvider)
            .setJson(kStorageUser, UserCodec.encode(updatedUser));
      }
    } on UnauthorizedException {
      await signOut();
    } catch (_) {
      // Abaikan gangguan jaringan sementara agar sesi tidak hilang saat offline
    }
  }

  /// Login dengan Google secara native dan autentikasi ke Laravel Sanctum (`/api/auth/google`).
  Future<GoogleAuthResult> signInWithGoogle() async {
    // 1. Autentikasi via Google Sign-In native
    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate();
    final String? idToken = account.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const ServerException(
        'Gagal mendapatkan ID token dari Google. '
        'Pastikan SHA-1 dan Package Name sudah terdaftar di Google Cloud Console.',
      );
    }

    // 2. Kirim ID token ke backend Laravel
    return _authenticateWithBackend({
      'id_token': idToken,
      'device_name': 'Flutter Mobile',
    });
  }

  /// Kirim payload (`id_token`) ke `POST /api/auth/google` dan simpan sesi Sanctum.
  Future<GoogleAuthResult> _authenticateWithBackend(
    Map<String, dynamic> payload,
  ) async {
    final client = ref.read(apiClientProvider);
    final dynamic raw = await client.post('/auth/google', body: payload);
    final data = raw as Map<String, dynamic>;
    return _applyAuthData(data);
  }

  /// Simpan Sanctum token, sinkronkan profil `clients` dari MySQL, dan perbarui state `authProvider`.
  Future<GoogleAuthResult> _applyAuthData(Map<String, dynamic> data) async {
    // 1. Simpan Sanctum token ke penyimpanan aman (dipakai oleh middleware auth:sanctum)
    final sanctumToken = data['token'] as String;
    await ref.read(tokenStorageProvider).write(sanctumToken);

    // 2. Bangun AppUser dan ambil status kelengkapan profil dari MySQL
    final user = UserCodec.fromApiResponse(data);
    final nextStep = data['next_step'] as String? ?? 'dashboard';

    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final clientData = data['client'] is Map<String, dynamic>
        ? data['client'] as Map<String, dynamic>
        : (userMap['client'] is Map<String, dynamic>
            ? userMap['client'] as Map<String, dynamic>
            : null);

    // 3. Sinkronkan `coupleProvider` SEBELUM mengubah `state = user`
    //    agar GoRouter redirect langsung mengenali apakah profil mempelai sudah ada di MySQL
    ref.read(coupleProvider.notifier).syncFromServer(
          nextStep == 'complete_profile' ? null : clientData,
          isClientRole: user.role == 'client',
        );

    // 4. Update state authProvider
    state = user;

    return GoogleAuthResult(user: user, nextStep: nextStep);
  }

  /// Logout: hapus token Sanctum di server lalu bersihkan state lokal.
  Future<void> signOut() async {
    try {
      await ref.read(apiClientProvider).post('/logout');
    } catch (_) {}

    await ref.read(tokenStorageProvider).clear();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    state = null;
  }

  // ── Mode prototype (hanya aktif saat USE_MOCK=true) ──────────────────────

  void signInDemo({String? email, bool viaGoogle = false}) {
    assert(AppConfig.useMockData, 'signInDemo hanya untuk mode mock');
    final mail = email ?? 'demo@example.com';
    state = AppUser(
      id: 'demo-user',
      name: mail.split('@').first,
      email: mail,
      hasPassword: !viaGoogle,
      role: 'client',
    );
  }

  void register({required String name, required String email}) {
    assert(AppConfig.useMockData, 'register hanya untuk mode mock');
    state = AppUser(id: 'demo-user', name: name, email: email, role: 'client');
  }

  void updateName(String name) {
    final user = state;
    if (user == null) return;
    state = user.copyWith(name: name);
  }
}

/// Hasil dari [AuthController.signInWithGoogle].
class GoogleAuthResult {
  const GoogleAuthResult({required this.user, required this.nextStep});
  final AppUser user;

  /// 'dashboard' atau 'complete_profile' (dari API Laravel).
  final String nextStep;
}
