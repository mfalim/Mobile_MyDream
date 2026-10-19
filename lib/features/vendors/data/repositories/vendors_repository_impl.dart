import 'package:w51/features/vendors/data/datasources/vendor_detail_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';
import 'package:w51/features/vendors/domain/repositories/vendors_repository.dart';

class VendorsRepositoryImpl implements VendorsRepository {
  const VendorsRepositoryImpl(this._list, this._detail);

  final VendorsMockDatasource _list;
  final VendorDetailMockDatasource _detail;

  @override
  Future<VendorsData> load() => _list.fetch();

  @override
  Future<VendorDetail> loadDetail(String id) => _detail.fetch(id);
}
