/// Mengubah nomor ponsel Indonesia ke format WhatsApp (62..., tanpa "+").
/// Menerima 0812..., +62 812..., 812..., atau 62812... dengan spasi atau
/// tanda hubung. Mengembalikan null bila bukan nomor ponsel Indonesia.
String? normalizeWhatsAppNumber(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) {
    digits = '62${digits.substring(1)}';
  } else if (digits.startsWith('8')) {
    digits = '62$digits';
  }
  if (!digits.startsWith('62')) return null;
  final national = digits.substring(2);
  if (!national.startsWith('8')) return null;
  if (national.length < 9 || national.length > 12) return null;
  return digits;
}

/// Tautan wa.me dengan pesan terisi.
Uri whatsAppUri(String number, String message) => Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$number',
      query: 'text=${Uri.encodeComponent(message)}',
    );
