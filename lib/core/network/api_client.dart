import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/storage/token_storage.dart';

/// Klien untuk API Laravel. Menambahkan token, membuka amplop `{"data": ...}`,
/// dan mengubah semua kegagalan menjadi pengecualian aplikasi
/// (lihat app_exceptions.dart).
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    this.onUnauthorized,
    Dio? dio,
  })  : _tokens = tokenStorage,
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _addToken));
  }

  final Dio _dio;
  final TokenStorage _tokens;

  /// Dipanggil saat server menolak token yang dikirim (kedaluwarsa atau
  /// dicabut). Biasanya: hapus token dan keluarkan pengguna.
  final Future<void> Function()? onUnauthorized;

  void close() => _dio.close();

  Future<void> _addToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<Object?> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<Object?> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<Object?> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<Object?> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<Object?> delete(String path) => _send('DELETE', path);

  /// Kirim berkas (multipart), mis. bukti transfer. Batas waktu kirim lebih lama.
  Future<Object?> postForm(String path, FormData form) =>
      _send('POST', path, body: form, sendTimeout: const Duration(seconds: 60));

  /// Satu objek; melempar [ServerException] bila respons bukan objek.
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = await get(path, query: query);
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ServerException('Format respons server tidak dikenali.');
  }

  /// Daftar objek; melempar [ServerException] bila respons bukan daftar.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = await get(path, query: query);
    if (data is List) {
      return [
        for (final item in data.whereType<Map>())
          Map<String, dynamic>.from(item),
      ];
    }
    throw const ServerException('Format respons server tidak dikenali.');
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Duration? sendTimeout,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method, sendTimeout: sendTimeout),
      );
      return unwrapEnvelope(response.data);
    } on DioException catch (e) {
      final exception = mapDioException(e);
      final hadToken = e.requestOptions.headers.containsKey('Authorization');
      if (e.response?.statusCode == 401 && hadToken) {
        final callback = onUnauthorized;
        if (callback != null) {
          try {
            await callback();
          } catch (_) {
            // Kegagalan membersihkan sesi tidak boleh menutupi
            // UnauthorizedException yang sebenarnya.
          }
        }
      }
      throw exception;
    }
  }
}

/// `{"data": ...}` menjadi isinya; selain itu dikembalikan apa adanya.
Object? unwrapEnvelope(Object? body) =>
    body is Map && body.containsKey('data') ? body['data'] : body;

/// Mengubah kegagalan Dio menjadi pengecualian aplikasi.
Exception mapDioException(DioException e) => switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout || // <-- Ditambahkan di sini
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate =>
        const NetworkException(),
      DioExceptionType.cancel => const NetworkException(
          'Permintaan dibatalkan.',
        ),
      DioExceptionType.badResponse => _fromResponse(e),
      DioExceptionType.unknown =>
        (e.error is SocketException || e.error is HandshakeException)
            ? const NetworkException()
            : const ServerException('Terjadi kesalahan tak terduga.'),
    };

Exception _fromResponse(DioException e) {
  final status = e.response?.statusCode ?? 0;
  final body = e.response?.data;
  final serverMessage = _messageOf(body);
  final hadToken = e.requestOptions.headers.containsKey('Authorization');

  if (status == 401) {
    return hadToken
        ? const UnauthorizedException()
        : UnauthorizedException(
            serverMessage ?? 'Email atau kata sandi salah.',
          );
  }
  if (status == 403) {
    // Akun pending atau ditolak admin (dari API Google auth Laravel)
    return UnauthorizedException(
      serverMessage ?? 'Akun tidak diizinkan mengakses aplikasi.',
    );
  }
  if (status == 404) return NotFoundException(e.requestOptions.path);
  if (status == 422) {
    final errors = _fieldErrorsOf(body);
    final first = errors.values.expand((list) => list).firstOrNull;
    return ValidationException(
      first ?? serverMessage ?? 'Data yang dikirim tidak valid.',
      fieldErrors: errors,
    );
  }
  if (status == 429) {
    return ServerException(
      'Terlalu banyak permintaan. Coba lagi sebentar lagi.',
      statusCode: status,
    );
  }
  if (status >= 500) {
    return ServerException(
      'Server sedang bermasalah. Coba lagi nanti.',
      statusCode: status,
    );
  }
  return ServerException(
    serverMessage ?? 'Permintaan gagal ($status).',
    statusCode: status,
  );
}

String? _messageOf(Object? body) {
  if (body is Map) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
  }
  return null;
}

/// `{"errors": {"email": ["pesan"]}}` menjadi peta kolom ke daftar pesan.
Map<String, List<String>> _fieldErrorsOf(Object? body) {
  if (body is! Map || body['errors'] is! Map) return const {};
  final result = <String, List<String>>{};
  for (final entry in (body['errors'] as Map).entries) {
    final value = entry.value;
    final messages = value is List
        ? value.whereType<String>().toList()
        : value is String
            ? [value]
            : <String>[];
    if (messages.isNotEmpty) result['${entry.key}'] = messages;
  }
  return result;
}
