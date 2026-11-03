import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/payment/domain/proof_rules.dart';

void main() {
  test('format file: JPG, PNG, WEBP diterima (huruf besar juga)', () {
    for (final name in ['a.jpg', 'a.JPEG', 'b.png', 'c.webp', 'd.PnG']) {
      expect(validateProofFile(name: name, bytes: 1000), isNull, reason: name);
    }
  });

  test('format lain atau tanpa ekstensi ditolak', () {
    for (final name in ['a.pdf', 'a.heic', 'a.gif', 'bukti', 'a.jpg.exe']) {
      expect(
        validateProofFile(name: name, bytes: 1000),
        'Format file harus JPG, PNG, atau WEBP.',
        reason: name,
      );
    }
  });

  test('ukuran: kosong dan di atas 2 MB ditolak, tepat 2 MB diterima', () {
    expect(validateProofFile(name: 'a.jpg', bytes: 0), isNotNull);
    expect(validateProofFile(name: 'a.jpg', bytes: kMaxProofBytes), isNull);
    final tooBig = validateProofFile(name: 'a.jpg', bytes: kMaxProofBytes + 1);
    expect(tooBig, contains('maksimal 2 MB'));
  });
}
