import 'package:w51/features/payment/data/datasources/payments_datasource.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl(this._datasource);

  final PaymentsDatasource _datasource;

  @override
  Future<List<BankAccount>> loadBankAccounts() =>
      _datasource.fetchBankAccounts();

  @override
  Future<MidtransSnapSession> initiateMidtrans(OrderSubmission submission) =>
      _datasource.initiateMidtrans(submission);

  @override
  Future<OrderReceipt> submit(OrderSubmission submission) =>
      _datasource.submit(submission);

  @override
  Future<List<ClientBookingSummary>> fetchClientBookings() =>
      _datasource.fetchClientBookings();

  @override
  Future<MidtransSnapSession> initiateMidtransForBooking({
    required int bookingId,
    required String scheme,
  }) =>
      _datasource.initiateMidtransForBooking(
        bookingId: bookingId,
        scheme: scheme,
      );

  @override
  Future<void> attachOptionalProof({
    required int bookingId,
    required String scheme,
    required String proofPath,
    required String proofName,
  }) =>
      _datasource.attachOptionalProof(
        bookingId: bookingId,
        scheme: scheme,
        proofPath: proofPath,
        proofName: proofName,
      );
}
