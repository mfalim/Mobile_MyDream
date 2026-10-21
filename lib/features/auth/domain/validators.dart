final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
final _letter = RegExp(r'[A-Za-z]');
final _digit = RegExp(r'\d');

String? validateName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Nama wajib diisi';
  if (v.length < 2) return 'Nama terlalu pendek';
  return null;
}

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email wajib diisi';
  if (!_emailPattern.hasMatch(v)) return 'Masukkan format email yang valid';
  return null;
}

/// Untuk membuat akun: minimal 8 karakter, kombinasi huruf dan angka.
String? validateNewPassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Kata sandi wajib diisi';
  if (v.length < 8) return 'Kata sandi minimal 8 karakter';
  if (!_letter.hasMatch(v) || !_digit.hasMatch(v)) {
    return 'Gunakan kombinasi huruf dan angka';
  }
  return null;
}

/// Untuk masuk: cukup wajib diisi (aturan komposisi hanya saat membuat akun).
String? validateLoginPassword(String? value) =>
    (value == null || value.isEmpty) ? 'Kata sandi wajib diisi' : null;

String? validateConfirmPassword(String? value, String original) {
  if (value == null || value.isEmpty) return 'Ulangi kata sandi';
  if (value != original) return 'Kata sandi tidak sama';
  return null;
}
