import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';

abstract interface class PaymentsRepository {
  Future<List<BankAccount>> loadBankAccounts();

  /// Membuat booking (jika belum ada) dan mengambil token/URL pembayaran Midtrans Snap.
  Future<MidtransSnapSession> initiateMidtrans(OrderSubmission submission);

  /// Mengonfirmasi pembayaran Midtrans (dengan foto bukti opsional).
  Future<OrderReceipt> submit(OrderSubmission submission);

  Future<List<ClientBookingSummary>> fetchClientBookings();

  Future<MidtransSnapSession> initiateMidtransForBooking({
    required int bookingId,
    required String scheme,
  });

  Future<void> attachOptionalProof({
    required int bookingId,
    required String scheme,
    required String proofPath,
    required String proofName,
  });
}
