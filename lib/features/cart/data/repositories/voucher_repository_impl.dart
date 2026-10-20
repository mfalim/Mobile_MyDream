import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';
import 'package:w51/features/cart/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  const VoucherRepositoryImpl(this._datasource);

  final VoucherMockDatasource _datasource;

  @override
  Future<List<Voucher>> load() => _datasource.fetch();
}
