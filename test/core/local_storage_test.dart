import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/storage/local_storage.dart';

void main() {
  test('tulis, baca, dan hapus', () async {
    final storage = MemoryLocalStorage();
    expect(storage.getString('k'), isNull);
    await storage.setString('k', 'nilai');
    expect(storage.getString('k'), 'nilai');
    await storage.remove('k');
    expect(storage.getString('k'), isNull);
  });

  test('JSON: simpan dan baca kembali', () async {
    final storage = MemoryLocalStorage();
    await storage.setJson('k', {'a': 1, 'b': 'dua'});
    expect(storage.getJson('k'), {'a': 1, 'b': 'dua'});
  });

  test('JSON rusak atau bukan objek menjadi null, bukan error', () async {
    final storage = MemoryLocalStorage();
    await storage.setString('k', '{bukan json');
    expect(storage.getJson('k'), isNull);
    await storage.setString('k', '[1, 2]');
    expect(storage.getJson('k'), isNull);
    expect(storage.getJson('tidak-ada'), isNull);
  });
}
