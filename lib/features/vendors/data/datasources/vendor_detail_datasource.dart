import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

abstract interface class VendorDetailDatasource {
  Future<VendorDetail> fetch(String id);
}
