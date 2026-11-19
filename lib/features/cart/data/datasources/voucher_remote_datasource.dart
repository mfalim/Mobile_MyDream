import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/cart/data/datasources/voucher_datasource.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';

class VoucherRemoteDatasource implements VoucherDatasource {
  const VoucherRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<Voucher>> fetch() async {
    try {
      final items = await _api.getList('/vouchers');
      return [
        for (final json in items)
          Voucher(
            code: _requiredString(json, 'code'),
            title: _requiredString(json, 'title'),
            description: jsonString(json['description']) ?? '',
            type: _type(json['type']),
            value: _requiredInt(json, 'value'),
            minSpend: _requiredInt(json, 'min_spend'),
            maxDiscount: jsonInt(json['max_discount']),
            validUntilLabel: _validUntil(jsonString(json['valid_until'])),
          ),
      ];
    } on NotFoundException {
      // Backend Laravel belum memiliki modul voucher -> kembalikan kosong dengan aman
      return const [];
    }
  }

  static String _requiredString(Map<String, dynamic> json, String key) =>
      jsonString(json[key]) ??
      (throw FormatException('Voucher tidak memiliki $key.'));

  static int _requiredInt(Map<String, dynamic> json, String key) =>
      jsonInt(json[key]) ??
      (throw FormatException('Voucher tidak memiliki nilai $key.'));

  static VoucherType _type(Object? value) => switch (value) {
        'fixed' => VoucherType.fixed,
        'percent' => VoucherType.percent,
        _ => throw const FormatException('Jenis voucher tidak dikenali.'),
      };

  static String _validUntil(String? raw) {
    if (raw == null) return '';
    final date = DateTime.tryParse(raw);
    return date == null ? raw : formatDateShortId(date);
  }
}
