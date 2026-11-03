import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/payment/data/datasources/payments_mock_datasource.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/payment/domain/entities/payment_summary.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

CheckoutDetails _checkout() => CheckoutDetails(
      vendorId: 'pkg-1',
      brideName: 'Dewi',
      groomName: 'Dimas',
      eventDate: DateTime(2027, 3, 1),
      ceremonyMinutes: 930,
      receptionMinutes: 1110,
      venueName: 'Gedung Nusa',
      venueAddress: 'Jalan Raya No. 1',
      venueCity: 'Badung',
      venueProvince: 'Bali',
      guestCount: 100,
      concept: 'Modern Romantic',
      picName: 'Dewi',
      whatsapp: '+6281298743210',
      notes: '',
    );

OrderSubmission _submission({
  String proofPath = '/tmp/bukti.jpg',
  int payAmount = 1000000,
  String bankId = 'bca',
}) =>
    OrderSubmission(
      itemId: 'pkg-1',
      itemTitle: 'Paket Intimate Bali',
      isCustom: false,
      totalAmount: 95000000,
      scheme: PaymentScheme.downPayment,
      payAmount: payAmount,
      bankAccountId: bankId,
      proofName: 'bukti.jpg',
      proofPath: proofPath,
      checkout: _checkout(),
    );

void main() {
  group('PaymentSummary', () {
    const summary = PaymentSummary(
      packagePrice: 95000000,
      originalPrice: 102000000,
      couponDiscount: 5000000,
      deposit: 1000000,
    );

    test('total kontrak, DP, dan sisa pelunasan', () {
      expect(summary.contractTotal, 90000000);
      expect(summary.effectiveDeposit, 1000000);
      expect(summary.remainingAfterDeposit, 89000000);
    });

    test('jumlah yang dibayar sekarang mengikuti skema', () {
      expect(summary.dueNow(PaymentScheme.downPayment), 1000000);
      expect(summary.dueNow(PaymentScheme.fullPayment), 90000000);
    });

    test('DP tidak melebihi total kontrak', () {
      const tiny = PaymentSummary(
        packagePrice: 600000,
        originalPrice: 600000,
        couponDiscount: 0,
        deposit: 1000000,
      );
      expect(tiny.effectiveDeposit, 600000);
      expect(tiny.remainingAfterDeposit, 0);
    });
  });

  group('datasource contoh', () {
    test('rekening tujuan: ada dan id unik', () async {
      final accounts = await PaymentsMockDatasource().fetchBankAccounts();
      expect(accounts, isNotEmpty);
      expect(accounts.map((a) => a.id).toSet().length, accounts.length);
    });

    test('pengiriman berhasil: status menunggu, invoice dan bank terisi',
        () async {
      final now = DateTime(2026, 10, 22, 14, 5);
      final datasource = PaymentsMockDatasource(clock: () => now);
      final receipt = await datasource.submit(_submission());

      expect(receipt.invoiceNumber, startsWith('INV-20261022-'));
      expect(receipt.bookingStatus, ReviewStatus.pending);
      expect(receipt.paymentStatus, ReviewStatus.pending);
      expect(receipt.bankName, 'BCA');
      expect(receipt.payAmount, 1000000);
      expect(receipt.totalAmount, 95000000);
      expect(receipt.title, 'Paket Intimate Bali');
      expect(receipt.eventDate, DateTime(2027, 3, 1));
      expect(receipt.submittedAt, now);
    });

    test('nomor invoice berbeda di setiap pengiriman', () async {
      final datasource =
          PaymentsMockDatasource(clock: () => DateTime(2026, 10, 22));
      final a = await datasource.submit(_submission());
      final b = await datasource.submit(_submission());
      expect(a.invoiceNumber, isNot(b.invoiceNumber));
    });

    test('ditolak tanpa bukti, jumlah tidak valid, atau rekening tak dikenal',
        () {
      final datasource = PaymentsMockDatasource();
      expect(
        datasource.submit(_submission(proofPath: '  ')),
        throwsA(isA<ValidationException>()),
      );
      expect(
        datasource.submit(_submission(payAmount: 0)),
        throwsA(isA<ValidationException>()),
      );
      expect(
        datasource.submit(_submission(bankId: 'tidak-ada')),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  test('receiptProvider: simpan lalu hapus', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(receiptProvider), isNull);

    final receipt = await PaymentsMockDatasource().submit(_submission());
    container.read(receiptProvider.notifier).save(receipt);
    expect(
        container.read(receiptProvider)?.invoiceNumber, receipt.invoiceNumber);

    container.read(receiptProvider.notifier).clear();
    expect(container.read(receiptProvider), isNull);
  });

  test('label status mengikuti nilai di database', () {
    expect(
      reviewStatusLabel(ReviewStatus.pending, payment: false),
      'Menunggu persetujuan',
    );
    expect(
      reviewStatusLabel(ReviewStatus.pending, payment: true),
      'Menunggu verifikasi',
    );
    expect(
        reviewStatusLabel(ReviewStatus.approved, payment: false), 'Disetujui');
    expect(reviewStatusLabel(ReviewStatus.approved, payment: true),
        'Terverifikasi');
    expect(reviewStatusLabel(ReviewStatus.rejected, payment: true), 'Ditolak');
  });
}
