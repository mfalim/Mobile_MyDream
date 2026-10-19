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
