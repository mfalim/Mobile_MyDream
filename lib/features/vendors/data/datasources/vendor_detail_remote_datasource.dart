import 'package:w51/core/network/api_client.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_datasource.dart';
import 'package:w51/features/vendors/data/models/vendor_detail_model.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';

class VendorDetailRemoteDatasource implements VendorDetailDatasource {
  const VendorDetailRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<VendorDetail> fetch(String id) async {
    final json = await _api.getObject('/vendors/${Uri.encodeComponent(id)}');
    return VendorDetailModel.fromJson(json);
  }
}
