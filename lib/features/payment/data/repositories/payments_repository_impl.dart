import 'package:w51/features/payment/data/datasources/payments_mock_datasource.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl(this._datasource);

  final PaymentsMockDatasource _datasource;

  @override
  Future<List<BankAccount>> loadBankAccounts() =>
      _datasource.fetchBankAccounts();

  @override
  Future<OrderReceipt> submit(OrderSubmission submission) =>
      _datasource.submit(submission);
}
