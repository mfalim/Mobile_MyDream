enum PaymentScheme { downPayment, fullPayment }

/// MOCK: potongan ekstra untuk pelunasan penuh (dari Figma).
const kFullPaymentDiscount = 2500000;

class PaymentMethod {
  const PaymentMethod(this.id, this.label);

  final String id;
  final String label;
}

const kVirtualAccounts = [
  PaymentMethod('va_bca', 'BCA Virtual Account'),
  PaymentMethod('va_mandiri', 'Mandiri VA'),
  PaymentMethod('va_bni', 'BNI Virtual Account'),
  PaymentMethod('va_bri', 'BRI Virtual Account'),
];

const kQrisMethod = PaymentMethod('qris', 'QRIS (GoPay, OVO, ShopeePay, Dana)');
const kCardMethod = PaymentMethod('card', 'Kartu Kredit Cicilan 0%');
