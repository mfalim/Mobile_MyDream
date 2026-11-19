import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/app/providers/api_providers.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/payment/data/datasources/payments_mock_datasource.dart';
import 'package:w51/features/payment/data/datasources/payments_remote_datasource.dart';
import 'package:w51/features/payment/data/repositories/payments_repository_impl.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/repositories/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepositoryImpl(
    AppConfig.useMockData
        ? PaymentsMockDatasource()
        : PaymentsRemoteDatasource(ref.watch(apiClientProvider)),
  ),
);

final bankAccountsProvider = FutureProvider<List<BankAccount>>(
  (ref) => ref.watch(paymentsRepositoryProvider).loadBankAccounts(),
);

/// Daftar booking aktif klien beserta status DP, sisa tagihan, dan tenggat waktu.
final clientBookingsProvider = FutureProvider<List<ClientBookingSummary>>(
  (ref) async {
    final user = ref.watch(authProvider);
    if (user == null || user.role == 'member') {
      return const [];
    }
    try {
      return await ref.watch(paymentsRepositoryProvider).fetchClientBookings();
    } catch (_) {
      return const [];
    }
  },
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
