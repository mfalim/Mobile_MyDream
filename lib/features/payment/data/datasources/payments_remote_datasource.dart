import 'package:dio/dio.dart';
import 'package:w51/core/network/api_client.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/payment/data/datasources/payments_datasource.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';

class PaymentsRemoteDatasource implements PaymentsDatasource {
  const PaymentsRemoteDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<BankAccount>> fetchBankAccounts() async {
    try {
      final items = await _api.getList('/bank-accounts');
      if (items.isNotEmpty) {
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
    } catch (_) {
      // Fallback ke daftar rekening resmi MyDream (sesuai config/mydream.php di Laravel)
    }
    return const [
      BankAccount(
        id: 'bca',
        bankName: 'BCA',
        accountNumber: '1234567890',
        accountHolder: 'MyDream Wedding Organizer',
      ),
      BankAccount(
        id: 'mandiri',
        bankName: 'Mandiri',
        accountNumber: '1234567890123',
        accountHolder: 'MyDream Wedding Organizer',
      ),
    ];
  }

  Future<int> _ensureBookingId(OrderSubmission submission) async {
    if (submission.bookingId != null) {
      return submission.bookingId!;
    }

    final details = submission.checkout;
    final bookingPayload = <String, dynamic>{
      if (!submission.isCustom)
        'package_id': int.tryParse(submission.itemId) ?? submission.itemId,
      if (submission.isCustom)
        'vendor_ids': [
          for (final id in submission.vendorIds) int.tryParse(id) ?? id,
        ],
      'venue_name': details.venueName,
      'venue_address': details.venueAddress,
      'venue_city': details.venueCity,
      'venue_province': details.venueProvince,
      if (details.venueMaps != null) 'venue_maps': details.venueMaps,
      'guest_count': details.guestCount,
      'event_date': _date(details.eventDate),
      'bride_name': details.brideName,
      'groom_name': details.groomName,
      if (details.notes.trim().isNotEmpty) 'notes': details.notes,
    };

    final bookingRaw = await _api.post('/client/bookings', body: bookingPayload);
    if (bookingRaw is! Map<String, dynamic>) {
      throw const FormatException('Respons pembuatan pesanan tidak dikenali.');
    }

    final bookingId = jsonInt(bookingRaw['id']);
    if (bookingId == null) {
      throw const FormatException(
        'ID pesanan tidak ditemukan dari respons server.',
      );
    }

    return bookingId;
  }

  @override
  Future<List<ClientBookingSummary>> fetchClientBookings() async {
    final raw = await _api.get('/client/bookings');
    final items = raw is Map<String, dynamic> && raw['data'] is List
        ? raw['data'] as List
        : raw is List
            ? raw
            : const [];
    return [
      for (final item in items)
        if (item is Map)
          ClientBookingSummary.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  @override
  Future<MidtransSnapSession> initiateMidtrans(
    OrderSubmission submission,
  ) async {
    final bookingId = await _ensureBookingId(submission);
    final schemeKey =
        submission.scheme == PaymentScheme.downPayment ? 'dp' : 'full';
    return initiateMidtransForBooking(
      bookingId: bookingId,
      scheme: schemeKey,
    );
  }

  @override
  Future<MidtransSnapSession> initiateMidtransForBooking({
    required int bookingId,
    required String scheme,
  }) async {
    final raw = await _api.post(
      '/client/bookings/$bookingId/payments/midtrans',
      body: {'scheme': scheme},
    );

    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Respons Midtrans tidak dikenali.');
    }

    final token = jsonString(raw['token']);
    if (token == null || token.isEmpty) {
      throw const FormatException('Token Midtrans tidak ditemukan.');
    }

    final redirectUrl = jsonString(raw['redirect_url']) ??
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/$token';
    final orderId = jsonString(raw['order_id']);

    return MidtransSnapSession(
      bookingId: bookingId,
      snapToken: token,
      redirectUrl: redirectUrl,
      orderId: orderId,
    );
  }

  @override
  Future<void> attachOptionalProof({
    required int bookingId,
    required String scheme,
    required String proofPath,
    required String proofName,
  }) async {
    final paymentForm = FormData()
      ..fields.add(MapEntry('scheme', scheme))
      ..files.add(
        MapEntry(
          'proof',
          await MultipartFile.fromFile(proofPath, filename: proofName),
        ),
      );

    await _api.postForm('/client/bookings/$bookingId/payments', paymentForm);
  }

  @override
  Future<OrderReceipt> submit(OrderSubmission submission) async {
    final details = submission.checkout;
    final schemeKey =
        submission.scheme == PaymentScheme.downPayment ? 'dp' : 'full';

    // 1. Buat / ambil pesanan via POST /client/bookings
    final bookingId = await _ensureBookingId(submission);

    // 2A. Jika tanpa foto bukti (Midtrans-only), sinkronkan langsung status dari server.
    if (submission.proofPath.trim().isEmpty) {
      final raw = await _api.get('/client/bookings/$bookingId/payments');
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Respons status pembayaran tidak dikenali.');
      }

      final bookingData = raw['data'] is Map
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : raw;
      final paymentsList = bookingData['payments'] is List
          ? bookingData['payments'] as List
          : const [];
      final latestPayment = paymentsList.isNotEmpty && paymentsList.first is Map
          ? Map<String, dynamic>.from(paymentsList.first as Map)
          : const <String, dynamic>{};

      final invoice = jsonString(bookingData['invoice_number']) ??
          'MD-${DateTime.now().millisecondsSinceEpoch}';
      final title = submission.itemTitle.isNotEmpty
          ? submission.itemTitle
          : (jsonNameOf(bookingData['package']) ?? 'Pesanan Pernikahan');
      final submittedAt =
          DateTime.tryParse('${latestPayment['created_at'] ?? ''}') ??
              DateTime.now();

      return OrderReceipt(
        invoiceNumber: invoice,
        title: title,
        eventDate: details.eventDate,
        scheme: submission.scheme,
        payAmount: jsonInt(latestPayment['amount']) ?? submission.payAmount,
        totalAmount:
            jsonInt(bookingData['total_price']) ?? submission.totalAmount,
        bankName: jsonString(latestPayment['bank_info']) ??
            'Midtrans Payment Gateway',
        submittedAt: submittedAt,
        bookingStatus: _status(bookingData['status'] ?? 'pending'),
        paymentStatus: _status(
          latestPayment['status'] ?? bookingData['payment_status'] ?? 'pending',
        ),
      );
    }

    // 2B. Jika pengguna melampirkan foto bukti (opsional), unggah ke server.
    final paymentForm = FormData()
      ..fields.add(MapEntry('scheme', schemeKey))
      ..files.add(
        MapEntry(
          'proof',
          await MultipartFile.fromFile(
            submission.proofPath,
            filename: submission.proofName,
          ),
        ),
      );

    final paymentRaw = await _api.postForm(
      '/client/bookings/$bookingId/payments',
      paymentForm,
    );
    if (paymentRaw is! Map<String, dynamic>) {
      throw const FormatException('Respons pembayaran tidak dikenali.');
    }

    final bookingData = paymentRaw['booking'] is Map
        ? Map<String, dynamic>.from(paymentRaw['booking'] as Map)
        : paymentRaw;
    final paymentData = paymentRaw['payment'] is Map
        ? Map<String, dynamic>.from(paymentRaw['payment'] as Map)
        : paymentRaw;

    final invoice = jsonString(bookingData['invoice_number']) ??
        'MD-${DateTime.now().millisecondsSinceEpoch}';
    final title = submission.itemTitle.isNotEmpty
        ? submission.itemTitle
        : (jsonNameOf(bookingData['package']) ?? 'Pesanan Pernikahan');
    final submittedAt =
        DateTime.tryParse('${paymentData['created_at'] ?? ''}') ??
            DateTime.now();
    final bankInfo =
        jsonString(paymentData['bank_info']) ?? 'Midtrans Payment Gateway';

    return OrderReceipt(
      invoiceNumber: invoice,
      title: title,
      eventDate: details.eventDate,
      scheme: submission.scheme,
      payAmount: jsonInt(paymentData['amount']) ?? submission.payAmount,
      totalAmount: jsonInt(bookingData['total_price']) ?? submission.totalAmount,
      bankName: bankInfo,
      submittedAt: submittedAt,
      bookingStatus: _status(bookingData['status'] ?? 'pending'),
      paymentStatus: _status(paymentData['status'] ?? 'pending'),
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static ReviewStatus _status(Object? value) => switch (value) {
        'pending' || 'unpaid' || 'awaiting_verification' => ReviewStatus.pending,
        'approved' || 'verified' || 'confirmed' || 'paid' || 'dp_paid' || 'completed' => ReviewStatus.approved,
        'rejected' || 'cancelled' => ReviewStatus.rejected,
        _ => ReviewStatus.pending,
      };
}
