final _digitsOnly = RegExp(r'^\d+$');

/// Isian teks wajib dengan panjang minimal.
String? validateRequired(String? value, String label, {int minLength = 1}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return '$label wajib diisi';
  if (v.length < minLength) {
    return '$label terlalu pendek (minimal $minLength karakter)';
  }
  return null;
}

/// Nomor ponsel Indonesia tanpa kode negara dan tanpa 0 di depan:
/// diawali 8, 9–12 digit (contoh: 81298743210).
String? validateIdMobile(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Nomor WhatsApp wajib diisi';
  if (v.startsWith('0')) return 'Tulis tanpa angka 0 di depan (contoh: 811...)';
  if (!_digitsOnly.hasMatch(v)) return 'Hanya boleh angka';
  if (!v.startsWith('8')) {
    return 'Nomor ponsel diawali angka 8 (contoh: 811...)';
  }
  if (v.length < 9 || v.length > 12) return 'Nomor harus 9–12 digit';
  return null;
}

/// Tautan opsional: kosong boleh, bila diisi harus http(s) dengan domain.
String? validateOptionalUrl(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  final uri = Uri.tryParse(v);
  final ok = uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.contains('.');
  return ok ? null : 'Masukkan tautan yang valid (diawali https://)';
}

/// Jumlah tamu: 1–10.000, dan tidak melebihi [capacity] bila ada.
String? validateGuestCount(String? value, {int? capacity}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Jumlah tamu wajib diisi';
  final n = int.tryParse(v);
  if (n == null) return 'Masukkan angka';
  if (n < 1) return 'Minimal 1 tamu';
  if (capacity != null && n > capacity) {
    return 'Maksimal $capacity tamu untuk paket ini';
  }
  if (n > 10000) return 'Maksimal 10.000 tamu';
  return null;
}
