/// 247459800 -> "IDR 247.459.800"
String formatRupiah(int amount, {String prefix = 'IDR'}) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '$prefix $buffer';
}

/// 61865 -> "61.865"
String formatNumber(int amount) => formatRupiah(amount, prefix: '').trim();

const _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// DateTime(2026, 10, 24) -> "Sabtu, 24 Oktober 2026"
String formatDateId(DateTime d) =>
    '${_dayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]} ${d.year}';

/// 15, 30 -> "15:30 WITA"
String formatTimeWita(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} WITA';

const _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// DateTime(2026, 10, 24) -> "24 Okt 2026"
String formatDateShortId(DateTime d) =>
    '${d.day} ${_monthShort[d.month - 1]} ${d.year}';

/// Format string waktu (misal "2026-11-09T09:00:00.000000Z" -> "09:00", "09:30:00" -> "09:30")
String formatTimeString(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final trimmed = raw.trim();

  // Jika format ISO datetime
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null && trimmed.contains('T')) {
    final local = parsed.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Jika format "HH:mm:ss" atau "HH:mm"
  final timeRegex = RegExp(r'^(\d{1,2}):(\d{2})');
  final match = timeRegex.firstMatch(trimmed);
  if (match != null) {
    final h = match.group(1)!.padLeft(2, '0');
    final m = match.group(2)!;
    return '$h:$m';
  }

  return trimmed;
}

/// Format string tanggal (misal "2026-10-24T00:00:00.000000Z" -> "24 Okt 2026")
String formatDateString(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final trimmed = raw.trim();
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    return formatDateShortId(parsed.toLocal());
  }
  return trimmed;
}

