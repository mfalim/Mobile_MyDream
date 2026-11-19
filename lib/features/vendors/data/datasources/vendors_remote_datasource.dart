import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/icon_mapper.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/vendors/data/datasources/vendors_datasource.dart';
import 'package:w51/features/vendors/data/models/featured_vendor_model.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

class VendorsRemoteDatasource implements VendorsDatasource {
  const VendorsRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<VendorsData> fetch() async {
    final results = await Future.wait([
      _api.getList('/catalog/categories'),
      _api.getList('/vendors'),
    ]);
    final categoriesJson = results[0];
    final vendorsJson = results[1];

    final categories = <VendorCategory>[];
    for (final json in categoriesJson) {
      final label = jsonString(json['name']);
      if (label == null) continue;
      categories.add(
        VendorCategory(
          label: label,
          subtitle: jsonString(json['subtitle']) ?? '',
          icon: iconFor(jsonString(json['icon']) ?? _inferIconKey(label)),
        ),
      );
    }

    return VendorsData(
      popularSearches: const [],
      categories: categories,
      quickCategories: const [],
      featured: [
        for (final json in vendorsJson) FeaturedVendorModel.fromJson(json),
      ],
    );
  }

  static String _inferIconKey(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('foto') || lower.contains('photo')) return 'camera';
    if (lower.contains('video')) return 'video';
    if (lower.contains('catering') || lower.contains('katering') || lower.contains('kue') || lower.contains('cake')) {
      return 'restaurant';
    }
    if (lower.contains('dekor') || lower.contains('decor')) return 'flower';
    if (lower.contains('makeup') || lower.contains('rias') || lower.contains('hair')) return 'brush';
    if (lower.contains('gaun') || lower.contains('busana') || lower.contains('dress')) return 'dress';
    if (lower.contains('entertainment') || lower.contains('sound') || lower.contains('musik')) return 'music';
    if (lower.contains('venue') || lower.contains('ballroom')) return 'ceremony';
    if (lower.contains('organizer') || lower.contains('wo')) return 'event';
    return 'sparkle';
  }
}
