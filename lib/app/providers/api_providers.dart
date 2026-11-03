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

/// Hanya dibaca oleh fitur yang sedang memakai API sungguhan.
final apiClientProvider = Provider<ApiClient>((ref) {
  assert(
    AppConfig.apiBaseUrl.isNotEmpty,
    'Isi --dart-define=API_BASE_URL=https://.../api',
  );
  final tokens = ref.watch(tokenStorageProvider);
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: tokens,
    // Token ditolak: bersihkan dan keluarkan pengguna. Router otomatis
    // mengarahkan halaman yang butuh login ke Login.
    onUnauthorized: () async {
      await tokens.clear();
      ref.read(authProvider.notifier).signOut();
    },
  );
});
