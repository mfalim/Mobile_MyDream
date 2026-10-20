/// Data yang diminta tidak ada (nanti: respons 404 dari server).
class NotFoundException implements Exception {
  const NotFoundException(this.what);

  final String what;

  @override
  String toString() => 'NotFoundException: $what';
}
