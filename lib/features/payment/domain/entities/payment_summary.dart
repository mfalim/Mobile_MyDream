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

  /// Nominal DP yang berlaku (MOCK; aturan DP nanti dari server).
  final int deposit;

  int get contractTotal => packagePrice - couponDiscount;

  /// DP tidak pernah melebihi total kontrak.
  int get effectiveDeposit => deposit < contractTotal ? deposit : contractTotal;

  int get remainingAfterDeposit => contractTotal - effectiveDeposit;

  int dueNow(PaymentScheme scheme) =>
      scheme == PaymentScheme.downPayment ? effectiveDeposit : contractTotal;
}
