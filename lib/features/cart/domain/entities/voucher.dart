enum VoucherType { fixed, percent }

class Voucher {
  const Voucher({
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.minSpend,
    required this.validUntilLabel,
    this.maxDiscount,
  });

  final String code;
  final String title;
  final String description;
  final VoucherType type;

  /// Rupiah untuk [VoucherType.fixed], persen (mis. 10) untuk [VoucherType.percent].
  final int value;
  final int minSpend;
  final int? maxDiscount;
  final String validUntilLabel;

  bool isEligible(int amount) => amount >= minSpend;

  /// Besar potongan untuk [amount]. Tidak memeriksa syarat belanja minimal.
  int discountFor(int amount) {
    var result = type == VoucherType.fixed ? value : amount * value ~/ 100;
    final cap = maxDiscount;
    if (cap != null && result > cap) result = cap;
    if (result > amount) result = amount;
    return result;
  }
}
