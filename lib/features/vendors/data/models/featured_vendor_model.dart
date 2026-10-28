import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

/// Pemetaan JSON `GET /vendors` ke entity. Hanya `id`, `name`, `category`,
/// dan `price` yang wajib; sisanya opsional (lihat docs/api-contract.md).
abstract final class FeaturedVendorModel {
  static FeaturedVendor fromJson(Map<String, dynamic> json) {
    final category = jsonNameOf(json['category']) ?? '';
    final cities = _cities(json);
    final price = jsonInt(json['price']) ?? 0;

    return FeaturedVendor(
      id: '${json['id']}',
      name: json['name'] as String,
      category: category,
      cities: cities,
      categoryLabel:
          cities.isEmpty ? category : '$category • ${cities.join(' & ')}',
      price: price,
      startingBudget: jsonInt(json['starting_budget']) ?? price,
      originalPrice: jsonInt(json['original_price']),
      rating: jsonDouble(json['rating']),
      reviewCount: jsonInt(json['review_count']),
      tag: jsonString(json['tag']),
      badge: jsonString(json['badge']),
      description: jsonString(json['description']),
      priceLabel: jsonString(json['price_label']),
      priceNote: jsonString(json['price_note']),
      promoBadge: jsonString(json['promo_badge']),
      promoNote: jsonString(json['promo_note']),
      photoUrl: jsonString(json['photo']),
    );
  }

  static List<String> _cities(Map<String, dynamic> json) {
    final list = json['cities'];
    if (list is List) {
      return list.map(jsonString).whereType<String>().toList();
    }
    final city = jsonString(json['city']);
    return city == null ? const [] : [city];
  }
}
