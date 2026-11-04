import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/image_rules.dart';

void main() {
  test('format: JPG, PNG, WEBP diterima (huruf besar juga)', () {
    for (final name in ['a.jpg', 'a.JPEG', 'b.png', 'c.webp', 'd.PnG']) {
      expect(validateImageFile(name: name, bytes: 1000), isNull, reason: name);
    }
  });

  test('format lain atau tanpa ekstensi ditolak', () {
    for (final name in ['a.pdf', 'a.heic', 'a.gif', 'foto', 'a.jpg.exe']) {
      expect(
        validateImageFile(name: name, bytes: 1000),
        'Format file harus JPG, PNG, atau WEBP.',
        reason: name,
      );
    }
  });

  test('ukuran: kosong dan di atas batas ditolak, tepat batas diterima', () {
    expect(validateImageFile(name: 'a.jpg', bytes: 0), isNotNull);
    expect(validateImageFile(name: 'a.jpg', bytes: kMaxImageBytes), isNull);
    expect(
      validateImageFile(name: 'a.jpg', bytes: kMaxImageBytes + 1),
      contains('maksimal 2 MB'),
    );
  });

  test('batas bisa diganti', () {
    expect(
      validateImageFile(
          name: 'a.jpg', bytes: 6 * 1024 * 1024, maxBytes: 5 * 1024 * 1024),
      contains('maksimal 5 MB'),
    );
    expect(
      validateImageFile(
          name: 'a.jpg', bytes: 4 * 1024 * 1024, maxBytes: 5 * 1024 * 1024),
      isNull,
    );
  });
}
