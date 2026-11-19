import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/payment/data/datasources/payments_datasource.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';

/// MOCK: meniru server. Nomor rekening di bawah adalah contoh, BUKAN rekening
/// asli. Daftar rekening dan nomor invoice nanti dari server.
class PaymentsMockDatasource implements PaymentsDatasource {
  PaymentsMockDatasource({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  static int _sequence = 1000;

  @override
  Future<List<BankAccount>> fetchBankAccounts() async => const [
        BankAccount(
          id: 'bca',
          bankName: 'BCA',
          accountNumber: '1234567890',
          accountHolder: 'MyDream (contoh)',
        ),
        BankAccount(
          id: 'mandiri',
          bankName: 'Mandiri',
          accountNumber: '1234567890123',
          accountHolder: 'MyDream (contoh)',
        ),
      ];

  @override
  Future<MidtransSnapSession> initiateMidtrans(OrderSubmission s) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final bookingId = s.bookingId ?? (++_sequence);
    const snapToken = 'mock-snap-token';
    return MidtransSnapSession(
      bookingId: bookingId,
      snapToken: snapToken,
      redirectUrl: 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken',
      orderId: 'MID-$bookingId-mock',
    );
  }

  @override
  Future<List<ClientBookingSummary>> fetchClientBookings() async => const [];

  @override
  Future<MidtransSnapSession> initiateMidtransForBooking({
    required int bookingId,
    required String scheme,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    const snapToken = 'mock-snap-token';
    return MidtransSnapSession(
      bookingId: bookingId,
      snapToken: snapToken,
      redirectUrl: 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken',
      orderId: 'MID-$bookingId-mock',
    );
  }

  @override
  Future<void> attachOptionalProof({
    required int bookingId,
    required String scheme,
    required String proofPath,
    required String proofName,
  }) async {}

  @override
  Future<OrderReceipt> submit(OrderSubmission s) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Untuk Midtrans, bukti pembayaran bersifat opsional.
    if (s.bankAccountId != 'midtrans' && s.proofPath.trim().isEmpty) {
      throw const ValidationException('Bukti transfer wajib diunggah.');
    }
    if (s.payAmount <= 0) {
      throw const ValidationException('Jumlah pembayaran tidak valid.');
    }
    final String bankName;
    if (s.bankAccountId == 'midtrans') {
      bankName = 'Midtrans Payment Gateway';
    } else {
      final accounts = await fetchBankAccounts();
      final bank = accounts.where((a) => a.id == s.bankAccountId).firstOrNull;
      if (bank == null) {
        throw const ValidationException('Rekening tujuan tidak valid.');
      }
      bankName = bank.bankName;
    }

    final now = _clock();
    _sequence++;
    String two(int n) => n.toString().padLeft(2, '0');
    return OrderReceipt(
      invoiceNumber:
          'INV-${now.year}${two(now.month)}${two(now.day)}-$_sequence',
      title: s.itemTitle,
      eventDate: s.checkout.eventDate,
      scheme: s.scheme,
      payAmount: s.payAmount,
      totalAmount: s.totalAmount,
      bankName: bankName,
      submittedAt: now,
    );
  }
}
