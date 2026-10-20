import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/payment/domain/entities/payment_summary.dart';

void main() {
  const summary = PaymentSummary(
    packagePrice: 247459800,
    originalPrice: 260484000,
    couponDiscount: 5000000,
    deposit: 1000000,
  );

  test('total kontrak dikurangi kupon', () {
    expect(summary.contractTotal, 242459800);
  });

  test('sisa pelunasan setelah DP', () {
    expect(summary.remainingAfterDeposit, 241459800);
  });

  test('pelunasan penuh mendapat potongan tambahan', () {
    expect(summary.fullPaymentTotal, 242459800 - kFullPaymentDiscount);
    expect(summary.fullPaymentTotal, 239959800);
  });

  test('jumlah yang dibayar sekarang mengikuti skema', () {
    expect(summary.dueNow(PaymentScheme.downPayment), 1000000);
    expect(summary.dueNow(PaymentScheme.fullPayment), 239959800);
  });
}
