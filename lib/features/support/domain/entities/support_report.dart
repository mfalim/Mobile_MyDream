const kReportCategories = [
  'Pembayaran',
  'Pesanan',
  'Tampilan atau bug',
  'Lainnya',
];

class SupportReport {
  const SupportReport({required this.category, required this.message});

  final String category;
  final String message;
}
