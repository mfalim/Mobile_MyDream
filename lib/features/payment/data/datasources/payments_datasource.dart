import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';

abstract interface class PaymentsDatasource {
  Future<List<BankAccount>> fetchBankAccounts();
  Future<OrderReceipt> submit(OrderSubmission submission);
}
