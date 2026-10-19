import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_mock_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendors_mock_datasource.dart';
import 'package:w51/features/vendors/data/repositories/vendors_repository_impl.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';
import 'package:w51/features/vendors/domain/repositories/vendors_repository.dart';

final vendorsRepositoryProvider = Provider<VendorsRepository>(
  (ref) => VendorsRepositoryImpl(
    VendorsMockDatasource(),
    VendorDetailMockDatasource(),
  ),
);

final vendorsDataProvider = FutureProvider<VendorsData>(
  (ref) => ref.watch(vendorsRepositoryProvider).load(),
);

final vendorDetailProvider = FutureProvider.family<VendorDetail, String>(
  (ref, id) => ref.watch(vendorsRepositoryProvider).loadDetail(id),
);
