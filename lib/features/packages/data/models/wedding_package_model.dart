import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';

/// Pemetaan JSON `GET /packages` ke entity. Kunci memakai snake_case, mengikuti
/// kolom tabel `packages`. Angka boleh berupa teks (kolom decimal Laravel
/// dikirim sebagai "95000000.00") dan boolean boleh 0/1.
abstract final class WeddingPackageModel {
  static WeddingPackage fromJson(Map<String, dynamic> json) {
    final date = jsonString(json['availability_date']);
    final rawVendors = json['vendors'];
    final vendors =
        rawVendors is List ? rawVendors.whereType<Map>() : const <Map>[];

    return WeddingPackage(
      id: '${json['id']}',
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: jsonString(json['description']),
      availabilityDate: date == null ? null : DateTime.tryParse(date),
      durationHours: jsonDouble(json['duration']),
      eventPeriod: jsonString(json['event_period']),
      guestCapacity: jsonInt(json['guest_capacity']),
      isFeatured: jsonBool(json['is_featured']),
      photoUrl: jsonString(json['photo']),
      price: jsonInt(json['price']) ?? 0,
      vendors: [
        for (final v in vendors)
          PackageVendor(
            id: '${v['id']}',
            name: jsonString(v['name']) ?? '',
            category: jsonNameOf(v['category']) ?? '',
            city: jsonString(v['city']),
            price: jsonInt(v['price']),
          ),
      ],
    );
  }
}
