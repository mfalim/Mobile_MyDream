import 'package:w51/features/payment/domain/entities/payment_options.dart';

class PaymentSummary {
  const PaymentSummary({
    required this.packagePrice,
    required this.originalPrice,
    required this.couponDiscount,
    required this.deposit,
  });

  final int packagePrice;
  final int originalPrice;
  final int couponDiscount;
  final int deposit;

  int get contractTotal => packagePrice - couponDiscount;
  int get remainingAfterDeposit => contractTotal - deposit;
  int get fullPaymentTotal => contractTotal - kFullPaymentDiscount;

  int dueNow(PaymentScheme scheme) =>
      scheme == PaymentScheme.downPayment ? deposit : fullPaymentTotal;
}
