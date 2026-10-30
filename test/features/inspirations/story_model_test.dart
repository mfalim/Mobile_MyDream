import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/inspirations/data/models/story_model.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

void main() {
  test('artikel dari kolom database saja', () {
    final s = StoryModel.story({
      'id': 5,
      'title': 'Judul',
      'slug': 'judul',
      'category': 'Artikel',
      'excerpt': 'Ringkasan',
      'content': 'Paragraf satu.\n\nParagraf dua.',
      'photo': null,
      'author': 'Admin',
      'published_at': '2026-10-05',
      'package_id': 3,
      'is_published': 1,
    });
    expect(s.id, '5');
    expect(s.category, 'Artikel');
    expect(s.excerpt, 'Ringkasan');
    expect(s.paragraphs, ['Paragraf satu.', 'Paragraf dua.']);
    expect(s.authorName, 'Admin');
    expect(s.publishedLabel, '5 Okt 2026');
    expect(s.relatedPackageId, '3');
    expect(s.readMinutes, 1);
    expect(s.photoUrl, isNull);
    expect(s.tag, isNull);
    expect(s.stats, isEmpty);
    expect(s.gallery, isEmpty);
    expect(s.vendors, isEmpty);
    expect(s.tips, isEmpty);
    expect(s.quote, isNull);
    expect(s.likes, isNull);
    expect(s.reads, isNull);
  });

  test('isi berupa HTML sederhana dibersihkan menjadi paragraf', () {
    final s = StoryModel.story({
      'id': 1,
      'title': 'T',
      'content': '<p>Halo&nbsp;dunia</p><p>Baris <b>dua</b><br>tiga</p>',
    });
    expect(s.paragraphs, ['Halo dunia', 'Baris dua', 'tiga']);
  });

  test('tanpa isi: tanpa paragraf dan tanpa menit baca', () {
    final s = StoryModel.story({'id': 1, 'title': 'T', 'content': null});
    expect(s.paragraphs, isEmpty);
    expect(s.readMinutes, isNull);
  });

  test('menit baca dihitung dari jumlah kata, kecuali dikirim server', () {
    final words = List.filled(450, 'kata').join(' ');
    expect(
      StoryModel.story({'id': 1, 'title': 'T', 'content': words}).readMinutes,
      3,
    );
    expect(
      StoryModel.story({
        'id': 1,
        'title': 'T',
        'content': words,
        'read_minutes': 10,
      }).readMinutes,
      10,
    );
  });

  test('bagian terstruktur terbaca, yang rusak dilewati', () {
    final s = StoryModel.story({
      'id': 1,
      'title': 'T',
      'stats': [
        {'label': 'Tamu', 'value': '45 Undangan'},
        {'label': 'Tanpa nilai'},
        'bukan-objek',
      ],
      'gallery': [
        {'url': 'https://a/1.jpg', 'caption': 'Satu'},
        'https://a/2.jpg',
        {'caption': 'Hanya teks'},
        {'foo': 'bar'},
      ],
      'vendors': [
        {
          'name': 'A',
          'role': 'WO',
          'rating': '4.9',
          'review_count': 10,
          'kind': 'planner'
        },
        {'name': 'B', 'kind': 'tidak-dikenal'},
        {'role': 'tanpa nama'},
      ],
      'tips': ['Satu', '', 'Dua', 7],
      'likes': '384',
      'reads': 1842,
    });
    expect(s.stats.length, 1);
    expect(s.gallery.map((p) => p.url),
        ['https://a/1.jpg', 'https://a/2.jpg', null]);
    expect(s.vendors.length, 2);
    expect(s.vendors.first.kind, StoryVendorKind.planner);
    expect(s.vendors.first.rating, 4.9);
    expect(s.vendors.last.kind, StoryVendorKind.other);
    expect(s.vendors.last.rating, isNull);
    expect(s.vendors.last.role, '');
    expect(s.tips, ['Satu', 'Dua', '7']);
    expect(s.likes, 384);
    expect(s.reads, 1842);
  });

  test('teaser: kategori bawaan "Artikel", angka berbentuk teks diterima', () {
    final t = StoryModel.teaser({
      'id': 9,
      'title': 'Judul',
      'published_at': '2026-09-28',
      'reads': '412',
    });
    expect(t.id, '9');
    expect(t.category, 'Artikel');
    expect(t.dateLabel, '28 Sep 2026');
    expect(t.reads, 412);
    expect(t.photoUrl, isNull);
  });
}
