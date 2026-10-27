import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

/// Pemetaan JSON dari server ke entity. Kunci memakai snake_case.
///
/// Nilai turunan (persen hemat, poin, cicilan) saat ini dihitung di sini
/// agar konsisten di semua layar; saat API siap, server boleh mengirimnya
/// langsung dan bagian ini cukup membaca nilainya.
abstract final class VendorDetailModel {
  static VendorDetail fromJson(Map<String, dynamic> json) {
    final price = json['price'] as int;
    final original = json['original_price'] as int;
    final percent = (json['cashback_percent'] as num).toDouble();
    final months = json['installment_months'] as int;
    final provider = json['provider'] as Map<String, dynamic>;
    final guarantee = json['guarantee'] as Map<String, dynamic>;

    return VendorDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      packageLabel: json['package_label'] as String,
      price: price,
      originalPrice: original,
      savePercent: ((original - price) * 100 / original).round(),
      savingsBadge: 'Hemat ${((original - price) / 1000000).round()} Jt',
      validUntil: json['valid_until'] as String,
      photoCount: json['photo_count'] as int,
      paxIncluded: json['pax_included'] as int,
      facts: [
        for (final f
            in (json['facts'] as List<dynamic>).cast<Map<String, dynamic>>())
          VendorFact(iconKey: f['icon'] as String, text: f['text'] as String),
      ],
      cashbackPoints: (price * percent / 10000).round(),
      cashbackPercent: percent,
      cashbackNote: json['cashback_note'] as String,
      installmentMonths: months,
      installmentPerMonth: price ~/ months,
      provider: VendorProviderInfo(
        name: provider['name'] as String,
        tagline: provider['tagline'] as String,
        rating: (provider['rating'] as num).toDouble(),
        reviewCount: provider['review_count'] as int,
      ),
      sections: [
        for (final s
            in (json['sections'] as List<dynamic>).cast<Map<String, dynamic>>())
          PackageSection(
            title: s['title'] as String,
            subtitle: s['subtitle'] as String,
            iconKey: s['icon'] as String,
            inclusions:
                (s['inclusions'] as List<dynamic>).cast<String>().toList(),
          ),
      ],
      guaranteeTitle: guarantee['title'] as String,
      guaranteeNote: guarantee['note'] as String,
      phone: json['phone'] as String?,
    );
  }
}
