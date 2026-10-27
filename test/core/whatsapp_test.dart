import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/whatsapp.dart';

void main() {
  test('normalizeWhatsAppNumber menerima berbagai penulisan', () {
    for (final raw in [
      '0812-9874-3210',
      '+62 812 9874 3210',
      '81298743210',
      '6281298743210',
      '(0812) 9874 3210',
    ]) {
      expect(normalizeWhatsAppNumber(raw), '6281298743210', reason: raw);
    }
  });

  test('normalizeWhatsAppNumber menolak nomor yang bukan ponsel Indonesia', () {
    for (final raw in [
      '',
      'abc',
      '12345',
      '+1 202 555 0100',
      '0712345678', // bukan diawali 8 setelah 0
      '08123', // terlalu pendek
      '08123456789012345', // terlalu panjang
    ]) {
      expect(normalizeWhatsAppNumber(raw), isNull, reason: raw);
    }
  });

  test('whatsAppUri meng-encode pesan', () {
    final uri = whatsAppUri('6281298743210', 'Halo & terima kasih');
    expect(
      uri.toString(),
      'https://wa.me/6281298743210?text=Halo%20%26%20terima%20kasih',
    );
    expect(uri.queryParameters['text'], 'Halo & terima kasih');
  });
}
