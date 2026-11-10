/// Data yang diminta tidak ada (respons 404 dari server).
class NotFoundException implements Exception {
  const NotFoundException(this.what);

  final String what;

  @override
  String toString() => 'NotFoundException: $what';
}

/// Data ditolak server (respons 422). [message] adalah pesan pertama yang
/// layak ditampilkan; [fieldErrors] berisi semua pesan per kolom.
class ValidationException implements Exception {
  const ValidationException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, List<String>> fieldErrors;

  /// Pesan pertama untuk [field], atau null bila tidak ada.
  String? firstError(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  @override
  String toString() => 'ValidationException: $message';
}

/// Belum masuk atau sesi berakhir (respons 401).
class UnauthorizedException implements Exception {
  const UnauthorizedException([
    this.message = 'Sesi berakhir. Silakan masuk kembali.',
  ]);

  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Tidak ada koneksi, timeout, atau server tidak terjangkau.
class NetworkException implements Exception {
  const NetworkException([
    this.message = 'Tidak bisa terhubung ke server. Periksa koneksi internet.',
  ]);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Server membalas dengan kesalahan (5xx, 429, dan sejenisnya) atau dengan
/// respons yang tidak dikenali.
class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Akun pengguna tidak diizinkan masuk ke aplikasi mobile (mis. Admin atau Vendor).
class RoleRestrictedException implements Exception {
  const RoleRestrictedException(this.role, [
    this.message = 'Akun Admin dan Vendor hanya dapat diakses melalui portal Web MyDream di browser.',
  ]);

  final String role;
  final String message;

  @override
  String toString() => 'RoleRestrictedException ($role): $message';
}

/// Pesan untuk pengguna dari sebuah kegagalan. Kegagalan jaringan dan server
/// punya pesan sendiri; selain itu memakai [fallback].
String userMessage(Object error, {required String fallback}) => switch (error) {
      NetworkException(:final message) => message,
      UnauthorizedException(:final message) => message,
      ServerException(:final message) => message,
      ValidationException(:final message) => message,
      RoleRestrictedException(:final message) => message,
      _ => fallback,
    };
