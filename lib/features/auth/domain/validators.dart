final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
final _usernamePattern = RegExp(r'^[A-Za-z0-9_-]+$');

String? validateName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Nama wajib diisi';
  if (v.length < 2) return 'Nama terlalu pendek';
  return null;
}

String? validateLoginIdentifier(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Username atau Email wajib diisi';
  return null;
}

String? validateUsername(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Username wajib diisi';
  if (v.length < 3) return 'Username minimal 3 karakter';
  if (v.length > 50) return 'Username maksimal 50 karakter';
  if (!_usernamePattern.hasMatch(v)) {
    return 'Hanya boleh huruf, angka, tanda hubung (-), atau garis bawah (_)';
  }
  return null;
}

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email wajib diisi';
  if (!_emailPattern.hasMatch(v)) return 'Masukkan format email yang valid';
  return null;
}

String? validateOptionalEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (!_emailPattern.hasMatch(v)) return 'Masukkan format email yang valid';
  return null;
}

/// Untuk membuat akun: minimal 6 karakter (selaras dengan validasi backend Laravel).
String? validateNewPassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Kata sandi wajib diisi';
  if (v.length < 6) return 'Kata sandi minimal 6 karakter';
  return null;
}

/// Untuk masuk: cukup wajib diisi.
String? validateLoginPassword(String? value) =>
    (value == null || value.isEmpty) ? 'Kata sandi wajib diisi' : null;

String? validateConfirmPassword(String? value, String original) {
  if (value == null || value.isEmpty) return 'Ulangi kata sandi';
  if (value != original) return 'Kata sandi tidak sama';
  return null;
}
