/// Pengaturan terpusat. Nilainya bisa diubah saat menjalankan app, mis.:
/// flutter run --dart-define=ADMIN_WA=62812xxxxxxx
abstract final class AppConfig {
  /// true = memakai data contoh (dummy). Setelah API siap, tiap fitur memilih
  /// datasource sungguhan di providernya.
  static const useMockData = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// URL dasar API Laravel. Tambahkan prefix `/api` di sini, bukan di path
  /// endpoint tiap fitur. Override untuk environment lain lewat dart-define.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  /// Nomor WhatsApp admin, format internasional tanpa "+". Nomor bawaan di
  /// bawah hanya contoh, BUKAN nomor asli.
  static const adminWhatsApp = String.fromEnvironment(
    'ADMIN_WA',
    defaultValue: '628000000000',
  );

  /// Nomor versi yang ditampilkan di Profil. Isi lewat
  /// --dart-define=APP_VERSION=1.0.0 saat membuat build rilis.
  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
}
