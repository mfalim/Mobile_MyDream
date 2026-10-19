import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';

abstract interface class VendorsRepository {
  Future<VendorsData> load();
  Future<VendorDetail> loadDetail(String id);
}
