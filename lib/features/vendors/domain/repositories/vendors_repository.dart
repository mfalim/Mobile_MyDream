import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

abstract interface class VendorsRepository {
  Future<VendorsData> load();
}
