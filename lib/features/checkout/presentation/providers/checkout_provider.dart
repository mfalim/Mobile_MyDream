import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';

/// Data hasil isian checkout. `null` berarti belum diisi.
final checkoutProvider = NotifierProvider<CheckoutController, CheckoutDetails?>(
  CheckoutController.new,
);

class CheckoutController extends Notifier<CheckoutDetails?> {
  @override
  CheckoutDetails? build() => null;

  void save(CheckoutDetails details) => state = details;

  void clear() => state = null;
}
