import 'package:w51/core/errors/app_exceptions.dart';

/// MOCK: meniru server (PATCH /me dan PUT /me/password). Prototype tidak
/// menyimpan kata sandi, jadi kata sandi lama tidak bisa diperiksa; nilai
/// "salah" dipakai untuk meniru penolakan server.
class AccountMockDatasource {
  const AccountMockDatasource({
    this.delay = const Duration(milliseconds: 500),
  });

  final Duration delay;

  Future<String> updateName(String name) async {
    await Future<void>.delayed(delay);
    final v = name.trim();
    if (v.length < 2) throw const ValidationException('Nama terlalu pendek.');
    if (v.length > 100) {
      throw const ValidationException(
          'Nama terlalu panjang (maksimal 100 karakter).');
    }
    return v;
  }

  Future<void> changePassword({
    required String current,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (current == 'salah') {
      throw const ValidationException('Kata sandi saat ini salah.');
    }
    if (password.length < 8) {
      throw const ValidationException('Kata sandi baru minimal 8 karakter.');
    }
    if (password == current) {
      throw const ValidationException(
        'Kata sandi baru harus berbeda dari yang lama.',
      );
    }
  }
}
