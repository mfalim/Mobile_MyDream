import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/storage/token_storage.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';

/// Mode data contoh memakai penyimpanan di memori; mode API memakai
/// penyimpanan aman.
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) =>
      AppConfig.useMockData ? MemoryTokenStorage() : const SecureTokenStorage(),
);

/// Klien API tunggal untuk seluruh app. Selalu tersedia meski mode mock aktif
/// (beberapa fitur mungkin tetap memanggil API meski mock=true).
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokens = ref.watch(tokenStorageProvider);
  final client = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: tokens,
    // Token ditolak: bersihkan dan keluarkan pengguna. Router otomatis
    // mengarahkan halaman yang butuh login ke Login.
    onUnauthorized: () async {
      await tokens.clear();
      ref.read(authProvider.notifier).signOut();
    },
  );
  ref.onDispose(client.close);
  return client;
});
