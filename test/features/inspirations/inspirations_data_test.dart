import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/inspirations/data/datasources/inspirations_mock_datasource.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';

void main() {
  final datasource = InspirationsMockDatasource();

  test('cerita utama terstruktur, cerita lain berbentuk data database',
      () async {
    final data = await datasource.fetch();
    final story = data.story!;
    expect(story.stats, isNotEmpty);
    expect(story.quote, isNotNull);
    expect(story.gallery, isNotEmpty);
    expect(story.vendors, isNotEmpty);
    expect(story.tips, isNotEmpty);
    expect(story.likes, isNotNull);

    expect(data.more.length, 3);
    final other = await datasource.fetchStory(data.more.first.id);
    expect(other.stats, isEmpty);
    expect(other.gallery, isEmpty);
    expect(other.vendors, isEmpty);
    expect(other.tips, isEmpty);
    expect(other.likes, isNull);
    expect(other.paragraphs, isNotEmpty);
  });

  test('setiap cerita di daftar bisa dibuka dan judulnya sama', () async {
    final data = await datasource.fetch();
    for (final t in data.more) {
      final story = await datasource.fetchStory(t.id);
      expect(story.title, t.title, reason: t.id);
      expect(story.category, t.category, reason: t.id);
    }
    final main = await datasource.fetchStory(data.story!.id);
    expect(main.title, data.story!.title);
  });

  test('id cerita unik', () async {
    final data = await datasource.fetch();
    final ids = [data.story!.id, ...data.more.map((t) => t.id)];
    expect(ids.toSet().length, ids.length);
  });

  test('id yang tidak dikenal melempar NotFoundException', () {
    expect(
      datasource.fetchStory('tidak-ada'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('paket terkait ada di data paket', () async {
    final data = await datasource.fetch();
    final packages = await PackagesMockDatasource().fetchAll();
    final stories = [
      data.story!,
      for (final t in data.more) await datasource.fetchStory(t.id),
    ];
    for (final s in stories) {
      final id = s.relatedPackageId;
      if (id == null) continue;
      expect(packages.map((p) => p.id), contains(id), reason: s.id);
    }
  });
}
