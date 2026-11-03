import 'dart:math' as math;

import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';

/// Pemetaan JSON `GET /articles` ke entity. Hanya `id` dan `title` yang wajib;
/// sisanya opsional (lihat docs/api-contract.md). Data kosong atau salah
/// bentuk dilewati, tidak membuat pemetaan gagal.
abstract final class StoryModel {
  static RealWeddingStory story(Map<String, dynamic> json) {
    final paragraphs = _paragraphs(jsonString(json['content']));
    return RealWeddingStory(
      id: '${json['id']}',
      title: json['title'] as String,
      category: jsonString(json['category']),
      tag: jsonString(json['tag']),
      location: jsonString(json['location']),
      excerpt: jsonString(json['excerpt']),
      authorName: jsonString(json['author']),
      publishedLabel: _date(jsonString(json['published_at'])),
      readMinutes: jsonInt(json['read_minutes']) ?? _readMinutes(paragraphs),
      photoUrl: jsonString(json['photo']),
      heroCaption: jsonString(json['hero_caption']),
      stats: _stats(json['stats']),
      paragraphs: paragraphs,
      quote: jsonString(json['quote']),
      gallery: _gallery(json['gallery']),
      vendorsTitle: jsonString(json['vendors_title']),
      vendors: _vendors(json['vendors']),
      tipsTitle: jsonString(json['tips_title']),
      tips: _tips(json['tips']),
      likes: jsonInt(json['likes']),
      reads: jsonInt(json['reads']),
      relatedPackageId: jsonString(json['package_id']),
    );
  }

  static StoryTeaser teaser(Map<String, dynamic> json) => StoryTeaser(
        id: '${json['id']}',
        category: jsonString(json['category']) ?? 'Artikel',
        title: json['title'] as String,
        dateLabel: _date(jsonString(json['published_at'])),
        reads: jsonInt(json['reads']),
        photoUrl: jsonString(json['photo']),
      );

  /// Tanggal ISO menjadi "5 Okt 2026"; teks lain dipakai apa adanya.
  static String? _date(String? raw) {
    if (raw == null) return null;
    final date = DateTime.tryParse(raw);
    return date == null ? raw : formatDateShortId(date);
  }

  /// Isi artikel menjadi paragraf. Tag HTML sederhana dibersihkan.
  static List<String> _paragraphs(String? content) {
    if (content == null) return const [];
    final text = content
        .replaceAll(RegExp(r'</p\s*>|<br\s*/?>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&');
    return text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// Sekitar 200 kata per menit; minimal 1 menit.
  static int? _readMinutes(List<String> paragraphs) {
    if (paragraphs.isEmpty) return null;
    final words = paragraphs
        .join(' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    return math.max(1, (words / 200).ceil());
  }

  static List<StoryStat> _stats(Object? raw) {
    if (raw is! List) return const [];
    final stats = <StoryStat>[];
    for (final s in raw) {
      if (s is! Map) continue;
      final label = jsonString(s['label']);
      final value = jsonString(s['value']);
      if (label == null || value == null) continue;
      stats.add(StoryStat(label: label, value: value));
    }
    return stats;
  }

  static List<StoryPhoto> _gallery(Object? raw) {
    if (raw is! List) return const [];
    final photos = <StoryPhoto>[];
    for (final item in raw) {
      final photo = item is Map
          ? StoryPhoto(
              url: jsonString(item['url'] ?? item['photo']),
              caption: jsonString(item['caption']),
            )
          : StoryPhoto(url: jsonString(item));
      if (photo.url != null || photo.caption != null) photos.add(photo);
    }
    return photos;
  }

  static List<StoryVendor> _vendors(Object? raw) {
    if (raw is! List) return const [];
    final vendors = <StoryVendor>[];
    for (final v in raw) {
      if (v is! Map) continue;
      final name = jsonString(v['name']);
      if (name == null) continue;
      vendors.add(
        StoryVendor(
          name: name,
          role: jsonString(v['role']) ?? '',
          kind: _kind(jsonString(v['kind'])),
          rating: jsonDouble(v['rating']),
          reviewCount: jsonInt(v['review_count']),
        ),
      );
    }
    return vendors;
  }

  static StoryVendorKind _kind(String? raw) => switch (raw) {
        'planner' => StoryVendorKind.planner,
        'decor' => StoryVendorKind.decor,
        'photographer' => StoryVendorKind.photographer,
        _ => StoryVendorKind.other,
      };

  static List<String> _tips(Object? raw) {
    if (raw is! List) return const [];
    return raw.map(jsonString).whereType<String>().toList();
  }
}
