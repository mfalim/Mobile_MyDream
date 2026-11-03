import 'package:w51/features/packages/domain/entities/wedding_package.dart';

abstract interface class PackagesRepository {
  Future<List<WeddingPackage>> loadAll();
  Future<WeddingPackage> load(String id);
}
