import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/network/api_config.dart';
import 'package:w51/core/network/api_provider.dart';

void main() {
  test('apiClientProvider uses the configured base URL', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final client = container.read(apiClientProvider);
    final expectedBaseUrl = Uri.parse(
      ApiConfig.baseUrl.endsWith('/')
          ? ApiConfig.baseUrl
          : '${ApiConfig.baseUrl}/',
    );

    expect(client, isA<ApiClient>());
    expect(client.baseUrl, expectedBaseUrl);
  });
}
