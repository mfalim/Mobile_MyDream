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
