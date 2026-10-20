import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/data/repositories/voucher_repository_impl.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';
import 'package:w51/features/cart/domain/repositories/voucher_repository.dart';

final voucherRepositoryProvider = Provider<VoucherRepository>(
  (ref) => VoucherRepositoryImpl(VoucherMockDatasource()),
);

final vouchersProvider = FutureProvider<List<Voucher>>(
  (ref) => ref.watch(voucherRepositoryProvider).load(),
);
