import 'package:w51/features/account/data/datasources/account_mock_datasource.dart';
import 'package:w51/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._datasource);

  final AccountMockDatasource _datasource;

  @override
  Future<String> updateName(String name) => _datasource.updateName(name);

  @override
  Future<void> changePassword({
    required String current,
    required String password,
  }) =>
      _datasource.changePassword(current: current, password: password);
}
