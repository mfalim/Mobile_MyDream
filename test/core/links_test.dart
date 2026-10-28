import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/links.dart';

void main() {
  test('instagramUri menerima berbagai penulisan', () {
    for (final raw in [
      '@contoh.vendor',
      'contoh.vendor',
      'https://www.instagram.com/contoh.vendor/',
      'instagram.com/contoh.vendor?igsh=abc',
      '  @contoh.vendor  ',
    ]) {
      expect(
        instagramUri(raw)?.toString(),
        'https://instagram.com/contoh.vendor',
        reason: raw,
      );
    }
  });

  test('instagramUri menolak yang bukan nama pengguna Instagram', () {
    for (final raw in [
      '',
      '@',
      'a b',
      'https://evil.example/contoh',
      'javascript:alert(1)',
      '@${'a' * 31}',
    ]) {
      expect(instagramUri(raw), isNull, reason: raw);
    }
  });
}
