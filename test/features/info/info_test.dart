import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/info/data/datasources/info_mock_datasource.dart';

void main() {
  test('dokumen yang dikenal tersedia dan berisi bagian', () async {
    final datasource = InfoMockDatasource();
    for (final slug in ['terms', 'guarantee', 'privacy']) {
      final doc = await datasource.fetch(slug);
      expect(doc.slug, slug);
      expect(doc.title, isNotEmpty);
      expect(doc.sections, isNotEmpty);
    }
  });

  test('slug yang tidak dikenal melempar NotFoundException', () {
    expect(
      InfoMockDatasource().fetch('tidak-ada'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
