# MyDream Mobile: Panduan Setup

Aplikasi Flutter untuk sisi **pengguna** MyDream Wedding Organizer: menjelajah vendor dan paket, menyusun pesanan (paket atau Custom Order), mengisi detail acara, membayar lewat transfer bank, dan mengunggah bukti transfer. Persetujuan pesanan dan verifikasi pembayaran dikerjakan di dashboard (di luar aplikasi ini).

Dokumen terkait: [`docs/api-contract.md`](api-contract.md) (kontrak API untuk backend).

## Kebutuhan

- Flutter **3.47.6** (stable), Dart 3.13.x
- JDK **17 atau lebih baru**
- Android SDK. Gradle 9.3.1, Android Gradle Plugin 9.1.0, dan Kotlin 2.4.0 sudah diatur di folder `android/`
- Perangkat Android dengan Debugging USB, atau emulator

## Menjalankan

```bash
flutter pub get
flutter run -d <id-perangkat>        # data contoh (bawaan), tidak butuh server
```

Daftar perangkat: `flutter devices`. Untuk perangkat Android lewat USB, pastikan `adb devices -l` menampilkan perangkat berstatus `device`.

## Pengaturan (`--dart-define`)

Semua pengaturan ada di `lib/core/config/app_config.dart`.

| Nama | Bawaan | Fungsi |
|---|---|---|
| `USE_MOCK` | `true` | `true` memakai data contoh. `false` memakai API untuk fitur yang sudah punya versi API |
| `API_BASE_URL` | kosong | Alamat dasar API, mis. `https://example.com/api` |
| `ADMIN_WA` | `628000000000` (contoh) | Nomor WhatsApp admin, format internasional tanpa `+` |
| `APP_VERSION` | `1.0.0` | Nomor versi yang tampil di Profil |

Contoh:

```bash
flutter run -d <id> --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://example.com/api
```

Fitur yang **belum** punya versi API tetap memakai data contoh meskipun `USE_MOCK=false`. Saat ini hanya **Paket** yang sudah punya versi API.

### Server palsu untuk uji lokal

`tool/fake_api.py` menyajikan `GET /api/packages` dan `GET /api/packages/{id}`:

```bash
python3 tool/fake_api.py                       # terminal 1
adb reverse tcp:8000 tcp:8000                  # terminal 2 (perangkat USB)
flutter run -d <id> \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api   # terminal 3
```

HTTP biasa hanya diizinkan di build **debug** (`android/app/src/debug/AndroidManifest.xml`). Build rilis mewajibkan HTTPS.

## Tes

```bash
flutter analyze
flutter test
```

Tes widget memakai font bawaan tes (`useTestFonts()` di `test/helpers/test_app.dart`) supaya Google Fonts tidak diunduh.

## Struktur

```text
lib/
  app/        router, tema, provider tingkat aplikasi (api_providers.dart)
  core/       konfigurasi, jaringan (ApiClient), penyimpanan token, util, widget bersama
  features/<fitur>/
    data/          model JSON, datasource (mock dan remote), implementasi repository
    domain/        entity dan kontrak repository
    presentation/  halaman, widget, provider
test/         tes unit dan widget (mencerminkan struktur lib/)
tool/         alat bantu pengembangan (server palsu)
docs/         dokumen
```

Fitur: `home`, `vendors`, `packages`, `inspirations`, `cart`, `checkout`, `payment`, `my_wedding`, `notifications`, `account`, `support`, `contact`, `info`, `auth`.

## Pola setiap fitur

`provider -> repository (antarmuka) -> datasource`

- Layar hanya bicara dengan provider dan repository, tidak tahu data datang dari mana.
- Data contoh ada di `*_mock_datasource.dart` dan diberi label MOCK.
- Model membaca JSON berkunci `snake_case` sesuai `docs/api-contract.md`, dan **tahan data kosong**: hanya kolom yang ada di database yang wajib, sisanya opsional dan bagian layarnya disembunyikan bila kosong.
- Uang disimpan sebagai bilangan bulat rupiah.

### Menyambungkan satu fitur ke API

1. Buat `<fitur>_datasource.dart` (antarmuka) dan buat datasource mock mengimplementasikannya.
2. Buat `<fitur>_remote_datasource.dart` memakai `ApiClient` (contoh: `lib/features/packages/data/datasources/packages_remote_datasource.dart`).
3. Di provider repository fitur itu, pilih datasource berdasarkan `AppConfig.useMockData` (contoh: `packages_provider.dart`).
4. Tambahkan tes dengan `FakeAdapter` (`test/helpers/fake_api.dart`) memakai contoh JSON dari kontrak.

Layar, router, dan state tidak berubah.

## Penanganan kegagalan jaringan

`ApiClient` mengubah kegagalan menjadi pengecualian aplikasi (`lib/core/errors/app_exceptions.dart`): `NotFoundException` (404), `ValidationException` (422, berisi pesan per kolom), `UnauthorizedException` (401), `NetworkException` (tidak ada koneksi atau timeout), dan `ServerException` (5xx dan lainnya). Token yang ditolak server (401) membuat pengguna otomatis keluar. Token disimpan di Keystore/Keychain lewat `flutter_secure_storage`.

## Alur kerja git

- Cabang kerja: `balle`. Cabang `main` tidak diubah langsung; perubahan masuk lewat Pull Request.
- Tambahkan file dengan `git add lib test docs ...`, bukan `git add .`, karena Flutter menghasilkan file registrasi plugin untuk platform desktop yang tidak ikut di-commit.
- Kunci penandatanganan Android (`android/key.properties`, `*.jks`, `*.keystore`) **tidak boleh** di-commit.

## Yang belum ada

Menunggu API: data asli, login Google sungguhan, pengiriman pesanan dan unggah bukti transfer. Menunggu desain: tab Inspirasi & Tips, Papan Visi, ganti foto profil, profil vendor dan portofolio, virtual tour. Menunggu keputusan owner: escrow, cicilan, poin dan cashback, MyDream Pay, QR tamu, ulasan di toko aplikasi, dan teks resmi Syarat & Ketentuan serta Kebijakan Privasi.
