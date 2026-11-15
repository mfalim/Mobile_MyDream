import 'package:dio/dio.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/payment/data/datasources/payments_datasource.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';

class PaymentsRemoteDatasource implements PaymentsDatasource {
  const PaymentsRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<BankAccount>> fetchBankAccounts() async {
    final items = await _api.getList('/bank-accounts');
    return [
      for (final json in items)
        BankAccount(
          id: jsonString(json['id']) ??
              (throw const FormatException('Rekening tidak memiliki id.')),
          bankName: jsonString(json['bank_name']) ??
              (throw const FormatException(
                  'Rekening tidak memiliki nama bank.')),
          accountNumber: jsonString(json['account_number']) ??
              (throw const FormatException(
                  'Rekening tidak memiliki nomor akun.')),
          accountHolder: jsonString(json['account_holder']) ??
              (throw const FormatException(
                  'Rekening tidak memiliki nama pemilik.')),
        ),
    ];
  }

  @override
  Future<OrderReceipt> submit(OrderSubmission submission) async {
    final details = submission.checkout;
    final fields = <MapEntry<String, String>>[
      MapEntry('type', submission.isCustom ? 'custom' : 'package'),
      if (!submission.isCustom) MapEntry('package_id', submission.itemId),
      for (final id in submission.vendorIds) MapEntry('vendor_ids[]', id),
      MapEntry('event_date', _date(details.eventDate)),
      MapEntry('ceremony_time', _time(details.ceremonyMinutes)),
      MapEntry('reception_time', _time(details.receptionMinutes)),
      MapEntry('venue_name', details.venueName),
      MapEntry('venue_address', details.venueAddress),
      MapEntry('venue_city', details.venueCity),
      MapEntry('venue_province', details.venueProvince),
      if (details.venueMaps != null) MapEntry('venue_maps', details.venueMaps!),
      MapEntry('guest_count', '${details.guestCount}'),
      MapEntry('bride_name', details.brideName),
      MapEntry('groom_name', details.groomName),
      if (details.concept.trim().isNotEmpty)
        MapEntry('concept', details.concept),
      MapEntry('pic_name', details.picName),
      MapEntry('pic_phone', details.whatsapp),
      if (details.notes.trim().isNotEmpty) MapEntry('notes', details.notes),
      if (submission.voucherCode != null)
        MapEntry('voucher_code', submission.voucherCode!),
      MapEntry(
        'payment_type',
        submission.scheme == PaymentScheme.downPayment ? 'dp' : 'full',
      ),
      MapEntry('bank_account_id', submission.bankAccountId),
    ];
    final form = FormData()
      ..fields.addAll(fields)
      ..files.add(
        MapEntry(
          'proof',
          await MultipartFile.fromFile(
            submission.proofPath,
            filename: submission.proofName,
          ),
        ),
      );
    final raw = await _api.postForm('/bookings', form);
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Respons pesanan tidak dikenali.');
    }

    final payment = raw['payment'];
    if (payment is! Map) {
      throw const FormatException('Respons pesanan tidak memiliki pembayaran.');
    }
    final invoice = jsonString(raw['invoice_number']);
    final title = jsonString(raw['title']);
    final eventDate = DateTime.tryParse('${raw['event_date'] ?? ''}');
    final submittedAt = DateTime.tryParse('${raw['created_at'] ?? ''}');
    final bankName = jsonString(payment['bank_name']);
    if (invoice == null ||
        title == null ||
        eventDate == null ||
        submittedAt == null ||
        bankName == null) {
      throw const FormatException('Respons pesanan tidak lengkap.');
    }
    return OrderReceipt(
      invoiceNumber: invoice,
      title: title,
      eventDate: eventDate,
      scheme: submission.scheme,
      payAmount: jsonInt(payment['amount']) ??
          (throw const FormatException('Nominal pembayaran tidak dikenal.')),
      totalAmount: jsonInt(raw['total_price']) ??
          (throw const FormatException('Total pesanan tidak dikenal.')),
      bankName: bankName,
      submittedAt: submittedAt,
      bookingStatus: _status(raw['status']),
      paymentStatus: _status(payment['status']),
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _time(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  static ReviewStatus _status(Object? value) => switch (value) {
        'pending' => ReviewStatus.pending,
        'approved' => ReviewStatus.approved,
        'rejected' => ReviewStatus.rejected,
        _ => throw const FormatException('Status pesanan tidak dikenali.'),
      };
}
