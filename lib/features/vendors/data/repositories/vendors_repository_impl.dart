import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';
import 'package:w51/features/vendors/domain/repositories/vendors_repository.dart';

class VendorsRepositoryImpl implements VendorsRepository {
  const VendorsRepositoryImpl(this._datasource);

  final VendorsMockDatasource _datasource;

  @override
  Future<VendorsData> load() => _datasource.fetch();
}
