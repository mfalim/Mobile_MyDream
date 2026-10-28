import 'dart:math' as math;

import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

/// Pemetaan JSON `GET /vendors/{id}` ke entity. Kunci memakai snake_case.
/// Hanya `id`, `name`, `category`, dan `price` yang wajib; sisanya opsional
/// (lihat docs/api-contract.md). Data yang kosong atau salah bentuk dilewati,
/// tidak membuat pemetaan gagal.
abstract final class VendorDetailModel {
  static VendorDetail fromJson(Map<String, dynamic> json) {
    final price = jsonInt(json['price']) ?? 0;
    final percent = jsonDouble(json['cashback_percent']);
    final months = jsonInt(json['installment_months']);
    final photos = _photoUrls(json['photos']);

    return VendorDetail(
      id: '${json['id']}',
      name: json['name'] as String,
      category: jsonNameOf(json['category']) ?? '',
      location: jsonString(json['location']) ??
          jsonString(json['city']) ??
          jsonString(json['address']) ??
          '',
      price: price,
      packageLabel: jsonString(json['package_label']),
      originalPrice: jsonInt(json['original_price']),
      validUntil: _validUntil(jsonString(json['valid_until'])),
      photoUrls: photos,
      photoCount: math.max(jsonInt(json['photo_count']) ?? 0, photos.length),
      paxIncluded: jsonInt(json['pax_included']) ?? 0,
      facts: _facts(json['facts']),
      description: jsonString(json['description']),
      instagram: jsonString(json['instagram']),
      cashback: (percent == null || percent <= 0 || price <= 0)
          ? null
          : VendorCashback(
              points: jsonInt(json['cashback_points']) ??
                  (price * percent / 10000).round(),
              percent: percent,
              note: jsonString(json['cashback_note']),
            ),
      installment: (months == null || months <= 0 || price <= 0)
          ? null
          : VendorInstallment(
              months: months,
              perMonth:
                  jsonInt(json['installment_per_month']) ?? price ~/ months,
            ),
      provider: _provider(json['provider']),
      sections: _sections(json['sections']),
      guarantee: _guarantee(json['guarantee']),
      phone: jsonString(json['phone']),
    );
  }

  /// Tanggal ISO menjadi "Valid s/d 31 Des 2026"; teks lain dipakai apa adanya.
  static String? _validUntil(String? raw) {
    if (raw == null) return null;
    final date = DateTime.tryParse(raw);
    return date == null ? raw : 'Valid s/d ${formatDateShortId(date)}';
  }

  static List<String> _photoUrls(Object? raw) {
    if (raw is! List) return const [];
    final urls = <String>[];
    for (final item in raw) {
      final url = item is Map
          ? jsonString(item['url'] ?? item['photo'])
          : jsonString(item);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  static List<VendorFact> _facts(Object? raw) {
    if (raw is! List) return const [];
    final facts = <VendorFact>[];
    for (final f in raw) {
      if (f is! Map) continue;
      final text = jsonString(f['text']);
      if (text == null) continue;
      facts.add(
          VendorFact(iconKey: jsonString(f['icon']) ?? 'check', text: text));
    }
    return facts;
  }

  static List<PackageSection> _sections(Object? raw) {
    if (raw is! List) return const [];
    final sections = <PackageSection>[];
    for (final s in raw) {
      if (s is! Map) continue;
      final title = jsonString(s['title']);
      final inclusions = s['inclusions'] is List
          ? (s['inclusions'] as List)
              .map(jsonString)
              .whereType<String>()
              .toList()
          : <String>[];
      if (title == null || inclusions.isEmpty) continue;
      sections.add(
        PackageSection(
          title: title,
          subtitle: jsonString(s['subtitle']) ?? '',
          iconKey: jsonString(s['icon']) ?? 'check',
          inclusions: inclusions,
        ),
      );
    }
    return sections;
  }

  /// Hanya dipakai bila lengkap (nama, rating, jumlah ulasan).
  static VendorProviderInfo? _provider(Object? raw) {
    if (raw is! Map) return null;
    final name = jsonString(raw['name']);
    final rating = jsonDouble(raw['rating']);
    final reviews = jsonInt(raw['review_count']);
    if (name == null || rating == null || reviews == null) return null;
    return VendorProviderInfo(
      name: name,
      tagline: jsonString(raw['tagline']) ?? '',
      rating: rating,
      reviewCount: reviews,
    );
  }

  static VendorGuarantee? _guarantee(Object? raw) {
    if (raw is! Map) return null;
    final title = jsonString(raw['title']);
    final note = jsonString(raw['note']);
    if (title == null || note == null) return null;
    return VendorGuarantee(title: title, note: note);
  }
}
