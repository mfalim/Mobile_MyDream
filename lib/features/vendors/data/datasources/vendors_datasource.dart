import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

abstract interface class VendorsDatasource {
  Future<VendorsData> fetch();
}
