import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/payment/data/datasources/payments_mock_datasource.dart';
import 'package:w51/features/payment/data/repositories/payments_repository_impl.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/repositories/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepositoryImpl(PaymentsMockDatasource()),
);

final bankAccountsProvider = FutureProvider<List<BankAccount>>(
  (ref) => ref.watch(paymentsRepositoryProvider).loadBankAccounts(),
);

/// Pesanan yang baru dikirim, untuk layar "Pesanan Terkirim".
final receiptProvider = NotifierProvider<ReceiptController, OrderReceipt?>(
  ReceiptController.new,
);

class ReceiptController extends Notifier<OrderReceipt?> {
  @override
  OrderReceipt? build() => null;

  void save(OrderReceipt receipt) => state = receipt;

  void clear() => state = null;
}
