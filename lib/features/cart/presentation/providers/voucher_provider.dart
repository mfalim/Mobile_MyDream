import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/data/datasources/voucher_remote_datasource.dart';
import 'package:w51/features/cart/data/repositories/voucher_repository_impl.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';
import 'package:w51/features/cart/domain/repositories/voucher_repository.dart';

final voucherRepositoryProvider = Provider<VoucherRepository>(
  (ref) => VoucherRepositoryImpl(
    AppConfig.useMockData
        ? VoucherMockDatasource()
        : VoucherRemoteDatasource(ref.watch(apiClientProvider)),
  ),
);

final vouchersProvider = FutureProvider<List<Voucher>>(
  (ref) {
    if (!AppConfig.useMockData && ref.watch(authProvider) == null) {
      return const [];
    }
    return ref.watch(voucherRepositoryProvider).load();
  },
);
