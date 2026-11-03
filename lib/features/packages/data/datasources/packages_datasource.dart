import 'package:w51/features/packages/domain/entities/wedding_package.dart';

/// Sumber data paket: contoh (mock) atau API.
abstract interface class PackagesDatasource {
  Future<List<WeddingPackage>> fetchAll();
  Future<WeddingPackage> fetch(String id);
}
