import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';

abstract interface class PaymentsRepository {
  Future<List<BankAccount>> loadBankAccounts();

  /// Mengirim pesanan beserta bukti transfer. Melempar
  /// `ValidationException` bila ditolak server.
  Future<OrderReceipt> submit(OrderSubmission submission);
}
