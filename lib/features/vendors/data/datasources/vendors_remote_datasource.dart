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
    final categoriesRequest = _api.getList('/categories');
    final vendorsRequest = _api.getList('/vendors');
    final categoriesJson = await categoriesRequest;
    final vendorsJson = await vendorsRequest;

    final categories = <VendorCategory>[];
    for (final json in categoriesJson) {
      final label = jsonString(json['name']);
      if (label == null) continue;
      categories.add(
        VendorCategory(
          label: label,
          subtitle: jsonString(json['subtitle']) ?? '',
          icon: iconFor(jsonString(json['icon']) ?? ''),
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
}
