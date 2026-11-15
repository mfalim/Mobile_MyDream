import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/support/data/datasources/support_datasource.dart';
import 'package:w51/features/support/domain/entities/support_report.dart';

class SupportRemoteDatasource implements SupportDatasource {
  const SupportRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<String> submit(SupportReport report) async {
    final json = await _api.post(
      '/support/reports',
      body: {
        'category': report.category,
        'message': report.message.trim(),
      },
    );
    if (json is Map) {
      final ticket = jsonString(json['ticket']);
      if (ticket != null) return ticket;
    }
    throw const ServerException('Nomor tiket tidak ditemukan pada respons.');
  }
}
