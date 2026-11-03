import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/storage/token_storage.dart';

void main() {
  test('API config has a Laravel API base URL', () {
    final uri = Uri.parse(AppConfig.apiBaseUrl);

    expect(uri.hasScheme, isTrue);
    expect(uri.hasAuthority, isTrue);
    expect(uri.path, endsWith('/api'));
  });

  test('apiClientProvider creates the shared API client', () {
    final container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(apiClientProvider), isA<ApiClient>());
  });
}
