import 'package:w51/features/packages/data/datasources/packages_datasource.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/domain/repositories/packages_repository.dart';

class PackagesRepositoryImpl implements PackagesRepository {
  const PackagesRepositoryImpl(this._datasource);

  final PackagesDatasource _datasource;

  @override
  Future<List<WeddingPackage>> loadAll() => _datasource.fetchAll();

  @override
  Future<WeddingPackage> load(String id) => _datasource.fetch(id);
}
