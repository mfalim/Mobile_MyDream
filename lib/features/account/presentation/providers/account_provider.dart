import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/account/data/datasources/account_mock_datasource.dart';
import 'package:w51/features/account/data/repositories/account_repository_impl.dart';
import 'package:w51/features/account/domain/repositories/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => const AccountRepositoryImpl(AccountMockDatasource()),
);
