/// Pengaturan terpusat. Nilainya bisa diubah saat menjalankan app, mis.:
/// flutter run --dart-define=ADMIN_WA=62812xxxxxxx
abstract final class AppConfig {
  /// true = memakai data contoh (dummy). Setelah API siap, tiap fitur memilih
  /// datasource sungguhan di providernya.
  static const useMockData = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// Alamat dasar API Laravel (belum tersedia).
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Nomor WhatsApp admin, format internasional tanpa "+". Nomor bawaan di
  /// bawah hanya contoh, BUKAN nomor asli.
  static const adminWhatsApp = String.fromEnvironment(
    'ADMIN_WA',
    defaultValue: '628000000000',
  );
}
