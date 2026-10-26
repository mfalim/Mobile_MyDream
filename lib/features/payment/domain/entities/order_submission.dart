import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';

/// Status persetujuan, sama dengan nilai `status` di database
/// (pending / approved / rejected).
enum ReviewStatus { pending, approved, rejected }

String reviewStatusLabel(ReviewStatus status, {required bool payment}) =>
    switch (status) {
      ReviewStatus.pending =>
        payment ? 'Menunggu verifikasi' : 'Menunggu persetujuan',
      ReviewStatus.approved => payment ? 'Terverifikasi' : 'Disetujui',
      ReviewStatus.rejected => 'Ditolak',
    };

/// Yang dikirim ke server saat pesanan dikirim. Total dan potongan harga
/// hanya untuk ditampilkan; server menghitung ulang sendiri.
class OrderSubmission {
  const OrderSubmission({
    required this.itemId,
    required this.itemTitle,
    required this.isCustom,
    required this.totalAmount,
    required this.scheme,
    required this.payAmount,
    required this.bankAccountId,
    required this.proofName,
    required this.proofPath,
    required this.checkout,
    this.voucherCode,
  });

  final String itemId;
  final String itemTitle;
  final bool isCustom;
  final int totalAmount;
  final PaymentScheme scheme;
  final int payAmount;
  final String bankAccountId;
  final String proofName;
  final String proofPath;
  final String? voucherCode;
  final CheckoutDetails checkout;
}

/// Hasil pengiriman pesanan, untuk layar "Pesanan Terkirim".
class OrderReceipt {
  const OrderReceipt({
    required this.invoiceNumber,
    required this.title,
    required this.eventDate,
    required this.scheme,
    required this.payAmount,
    required this.totalAmount,
    required this.bankName,
    required this.submittedAt,
    this.bookingStatus = ReviewStatus.pending,
    this.paymentStatus = ReviewStatus.pending,
  });

  final String invoiceNumber;
  final String title;
  final DateTime eventDate;
  final PaymentScheme scheme;
  final int payAmount;
  final int totalAmount;
  final String bankName;
  final DateTime submittedAt;
  final ReviewStatus bookingStatus;
  final ReviewStatus paymentStatus;
}
