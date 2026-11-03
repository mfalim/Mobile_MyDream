import 'package:w51/features/home/data/datasources/home_mock_datasource.dart';
import 'package:w51/features/home/data/home_composer.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/home/domain/repositories/home_repository.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/domain/repositories/inspirations_repository.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/domain/repositories/packages_repository.dart';
import 'package:w51/features/vendors/domain/repositories/vendors_repository.dart';

/// Home dirakit dari repository vendor, paket, dan artikel. Hanya data vendor
/// yang wajib; paket, artikel, dan kemajuan yang gagal dimuat membuat
/// bagian itu kosong (disembunyikan), bukan membuat Home gagal.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required VendorsRepository vendors,
    required PackagesRepository packages,
    required InspirationsRepository inspirations,
    required HomeMockDatasource progress,
  })  : _vendors = vendors,
        _packages = packages,
        _inspirations = inspirations,
        _progress = progress;

  final VendorsRepository _vendors;
  final PackagesRepository _packages;
  final InspirationsRepository _inspirations;
  final HomeMockDatasource _progress;

  // Mengganti catchError dengan try-catch async agar aman dari error tipe data Future
  static Future<T> _orElse<T>(Future<T> future, T fallback) async {
    try {
      return await future;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<HomeData> load() async {
    // Semua permintaan dimulai bersamaan, lalu dikumpulkan.
    final vendorsFuture = _vendors.load();
    final packagesFuture = _orElse<List<WeddingPackage>>(
      _packages.loadAll(),
      const [],
    );
    final inspirationsFuture = _orElse<InspirationsData?>(
      _inspirations.load(),
      null,
    );
    final progressFuture = _orElse<WeddingCountdown?>(
      _progress.fetchProgress(),
      null,
    );

    return HomeComposer.compose(
      vendors: await vendorsFuture,
      packages: await packagesFuture,
      inspirations: await inspirationsFuture,
      progress: await progressFuture,
    );
  }
}
