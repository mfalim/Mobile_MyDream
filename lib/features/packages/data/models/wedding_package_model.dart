import 'package:w51/features/packages/domain/entities/wedding_package.dart';

int? _toInt(Object? v) => switch (v) {
      num n => n.round(),
      String s => double.tryParse(s)?.round(),
      _ => null,
    };

double? _toDouble(Object? v) => switch (v) {
      num n => n.toDouble(),
      String s => double.tryParse(s),
      _ => null,
    };

bool _toBool(Object? v) => switch (v) {
      bool b => b,
      num n => n != 0,
      String s => s == '1' || s.toLowerCase() == 'true',
      _ => false,
    };

/// Pemetaan JSON dari server ke entity. Kunci memakai snake_case, mengikuti
/// kolom tabel `packages`. Angka boleh berupa teks (kolom decimal Laravel
/// dikirim sebagai "95000000.00") dan boolean boleh 0/1.
abstract final class WeddingPackageModel {
  static WeddingPackage fromJson(Map<String, dynamic> json) {
    final date = json['availability_date'] as String?;
    final vendors = (json['vendors'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return WeddingPackage(
      id: '${json['id']}',
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      availabilityDate: date == null ? null : DateTime.parse(date),
      durationHours: _toDouble(json['duration']),
      eventPeriod: json['event_period'] as String?,
      guestCapacity: _toInt(json['guest_capacity']),
      isFeatured: _toBool(json['is_featured']),
      price: _toInt(json['price']) ?? 0,
      vendors: [
        for (final v in vendors)
          PackageVendor(
            id: '${v['id']}',
            name: v['name'] as String,
            category: v['category'] as String,
            city: v['city'] as String?,
            price: _toInt(v['price']),
          ),
      ],
    );
  }
}
