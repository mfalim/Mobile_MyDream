import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/packages/data/datasources/packages_datasource.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/packages/data/datasources/packages_remote_datasource.dart';
import 'package:w51/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/domain/repositories/packages_repository.dart';

/// Satu-satunya tempat yang memilih sumber data paket: contoh (bawaan) atau
/// API (--dart-define=USE_MOCK=false --dart-define=API_BASE_URL=...).
final packagesRepositoryProvider = Provider<PackagesRepository>((ref) {
  final PackagesDatasource datasource = AppConfig.useMockData
      ? PackagesMockDatasource()
      : PackagesRemoteDatasource(ref.watch(apiClientProvider));
  return PackagesRepositoryImpl(datasource);
});

/// Daftar paket: pilihan editor di atas, lalu urut nama.
final packagesProvider = FutureProvider<List<WeddingPackage>>((ref) async {
  final list = await ref.watch(packagesRepositoryProvider).loadAll();
  return [...list]..sort((a, b) {
      if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
      return a.name.compareTo(b.name);
    });
});

final packageDetailProvider = FutureProvider.family<WeddingPackage, String>(
  (ref, id) => ref.watch(packagesRepositoryProvider).load(id),
);
