/// Pengaturan terpusat. Nilainya diisi lewat:
///   flutter run --dart-define-from-file=dart-defines.json
abstract final class AppConfig {
  /// false = memakai API sungguhan (Laravel + MySQL).
  /// true  = memakai data dummy/prototype (tidak perlu server).
  static const useMockData = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  /// URL dasar API Laravel. Tambahkan prefix `/api` di sini, bukan di path
  /// endpoint tiap fitur.
  /// - Untuk HP fisik via USB (dengan `adb reverse tcp:8000 tcp:8000`): "http://127.0.0.1:8000/api"
  /// - Untuk Emulator Android: "http://10.0.2.2:8000/api"
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  /// Web Client ID dari Google Cloud Console (OAuth 2.0 → "Web application").
  /// Harus sama dengan nilai GOOGLE_CLIENT_ID di file .env Laravel.
  /// Tanpa nilai ini, Google Sign-In tidak dapat menghasilkan ID token yang valid.
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '948802797315-o7b3p6fjeje28kf7vqr3mppoq59kf3df.apps.googleusercontent.com',
  );

  /// Nomor WhatsApp admin, format internasional tanpa "+". Nomor bawaan di
  /// bawah hanya contoh, BUKAN nomor asli.
  static const adminWhatsApp = String.fromEnvironment(
    'ADMIN_WA',
    defaultValue: '628000000000',
  );

  /// Nomor versi yang ditampilkan di Profil.
  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
}
