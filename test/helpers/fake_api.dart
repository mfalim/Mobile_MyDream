import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/storage/token_storage.dart';

typedef FakeHandler = FutureOr<ResponseBody> Function(RequestOptions options);

/// Adapter HTTP palsu: tidak ada jaringan, semua permintaan dicatat.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FakeHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object? body, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody htmlResponse(String html, {int status = 200}) =>
    ResponseBody.fromString(
      html,
      status,
      headers: {
        Headers.contentTypeHeader: ['text/html'],
      },
    );

/// ApiClient yang berbicara dengan [adapter], tanpa jaringan.
ApiClient fakeApiClient(
  FakeAdapter adapter, {
  TokenStorage? tokens,
  Future<void> Function()? onUnauthorized,
  String baseUrl = 'https://api.example.com/api',
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: baseUrl,
    tokenStorage: tokens ?? MemoryTokenStorage(),
    onUnauthorized: onUnauthorized,
    dio: dio,
  );
}
