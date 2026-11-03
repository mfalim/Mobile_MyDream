import 'package:w51/core/network/api_client.dart';
import 'package:w51/features/packages/data/datasources/packages_datasource.dart';
import 'package:w51/features/packages/data/models/wedding_package_model.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';

/// GET /packages dan GET /packages/{id} (lihat docs/api-contract.md).
class PackagesRemoteDatasource implements PackagesDatasource {
  const PackagesRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<WeddingPackage>> fetchAll() async {
    final items = await _api.getList('/packages');
    return [for (final json in items) WeddingPackageModel.fromJson(json)];
  }

  @override
  Future<WeddingPackage> fetch(String id) async {
    final json = await _api.getObject('/packages/${Uri.encodeComponent(id)}');
    return WeddingPackageModel.fromJson(json);
  }
}
