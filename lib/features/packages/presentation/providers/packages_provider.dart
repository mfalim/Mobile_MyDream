import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/packages/data/datasources/packages_mock_datasource.dart';
import 'package:w51/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/domain/repositories/packages_repository.dart';

final packagesRepositoryProvider = Provider<PackagesRepository>(
  (ref) => PackagesRepositoryImpl(PackagesMockDatasource()),
);

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
