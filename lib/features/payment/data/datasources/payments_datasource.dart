import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';

abstract interface class PaymentsDatasource {
  Future<List<BankAccount>> fetchBankAccounts();
  Future<MidtransSnapSession> initiateMidtrans(OrderSubmission submission);
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
