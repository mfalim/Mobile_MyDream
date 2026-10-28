import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/home/data/datasources/home_mock_datasource.dart';
import 'package:w51/features/home/data/repositories/home_repository_impl.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/home/domain/repositories/home_repository.dart';
import 'package:w51/features/inspirations/presentation/providers/inspirations_provider.dart';
import 'package:w51/features/packages/presentation/providers/packages_provider.dart';
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(
    vendors: ref.watch(vendorsRepositoryProvider),
    packages: ref.watch(packagesRepositoryProvider),
    inspirations: ref.watch(inspirationsRepositoryProvider),
    progress: const HomeMockDatasource(),
  ),
);

final homeDataProvider = FutureProvider<HomeData>(
  (ref) => ref.watch(homeRepositoryProvider).load(),
);
