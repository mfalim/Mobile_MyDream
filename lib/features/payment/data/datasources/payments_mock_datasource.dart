import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/payment/domain/entities/bank_account.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';

/// MOCK: meniru server. Nomor rekening di bawah adalah contoh, BUKAN rekening
/// asli. Daftar rekening dan nomor invoice nanti dari server.
class PaymentsMockDatasource {
  PaymentsMockDatasource({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  static int _sequence = 1000;

  Future<List<BankAccount>> fetchBankAccounts() async => const [
        BankAccount(
          id: 'bca',
          bankName: 'BCA',
          accountNumber: '1234567890',
          accountHolder: 'PT Aura Wedding (contoh)',
        ),
        BankAccount(
          id: 'mandiri',
          bankName: 'Mandiri',
          accountNumber: '1234567890123',
          accountHolder: 'PT Aura Wedding (contoh)',
        ),
      ];

  Future<OrderReceipt> submit(OrderSubmission s) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Meniru validasi server (respons 422).
    if (s.proofPath.trim().isEmpty) {
      throw const ValidationException('Bukti transfer wajib diunggah.');
    }
    if (s.payAmount <= 0) {
      throw const ValidationException('Jumlah pembayaran tidak valid.');
    }
    final accounts = await fetchBankAccounts();
    final bank = accounts.where((a) => a.id == s.bankAccountId).firstOrNull;
    if (bank == null) {
      throw const ValidationException('Rekening tujuan tidak valid.');
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
      bankName: bank.bankName,
      submittedAt: now,
    );
  }
}
