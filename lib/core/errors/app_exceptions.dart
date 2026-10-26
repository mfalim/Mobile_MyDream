/// Data yang diminta tidak ada (nanti: respons 404 dari server).
class NotFoundException implements Exception {
  const NotFoundException(this.what);

  final String what;

  @override
  String toString() => 'NotFoundException: $what';
}

/// Data ditolak server (nanti: respons 422).
class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
