# Kontrak API MyDream (Aplikasi Mobile)

Status: **draf 0.2**. Disusun dari aplikasi Flutter dan struktur database `wedding_organizer`.

Tujuan dokumen ini: menyepakati bentuk data antara aplikasi dan API Laravel **sebelum** keduanya disambungkan. Contoh JSON di bawah sama dengan data contoh yang dipakai aplikasi sekarang. Jika API mengikutinya, aplikasi cukup mengganti sumber datanya tanpa mengubah tampilan.

Ruang lingkup: sisi **pengguna** (aplikasi mobile). Persetujuan pesanan, verifikasi pembayaran, dan status pesanan ada di dashboard dan tidak dibahas di sini.

Perubahan dari 0.1: bagian 2 (foto profil dan data tambahan profil), bagian 5.1 (artikel: `vendor_id` pada vendor cerita, suka dan dibaca hanya ditampilkan), bagian 9 (data yang sengaja hanya di perangkat), dan dua pertanyaan baru (no. 15 dan 16).

---

## 1. Aturan umum

| Hal | Aturan |
|---|---|
| Base URL | `{BASE_URL}/api` (belum ditentukan; aplikasi membacanya dari `API_BASE_URL`) |
| Format | JSON, UTF-8, kunci `snake_case` |
| Otentikasi | Laravel Sanctum. Header `Authorization: Bearer {token}` pada endpoint bertanda **(auth)** |
| Objek tunggal | `{ "data": { ... } }` |
| Daftar | `{ "data": [ ... ], "meta": { "current_page": 1, "last_page": 3, "per_page": 20, "total": 51 } }` |
| Uang | Bilangan bulat rupiah. String desimal seperti `"95000000.00"` (keluaran kolom `decimal`) juga diterima |
| Tanggal / jam | `YYYY-MM-DD` / `HH:mm`. Waktu lengkap memakai ISO 8601 dengan zona waktu |
| Boolean | `true`/`false` atau `1`/`0` |
| Id | Angka atau string (aplikasi menyimpannya sebagai teks) |
| Gambar | **URL absolut**. Kolom `photo` di database berisi path, jadi API perlu mengubahnya menjadi URL penuh |
| Field opsional | Boleh `null`, string kosong, atau tidak dikirim. Aplikasi menyembunyikan bagian layar yang datanya tidak ada (tidak error) |
| HTTPS | Wajib untuk server sungguhan (build rilis menolak HTTP biasa) |

### Error

| Status | Isi | Catatan |
|---|---|---|
| 401 | `{ "message": "Unauthenticated." }` | Token tidak ada atau kedaluwarsa. Aplikasi mengeluarkan pengguna dan mengarahkan ke Login |
| 403 | `{ "message": "..." }` | |
| 404 | `{ "message": "..." }` | Data tidak ditemukan |
| 422 | `{ "message": "...", "errors": { "field": ["pesan"] } }` | Pesan pertama ditampilkan ke pengguna. **Mohon berbahasa Indonesia** |
| 429 | `{ "message": "..." }` | Terlalu banyak permintaan |
| 5xx | | Aplikasi menampilkan pesan umum dan tombol coba lagi. Pesan teknis server tidak ditampilkan |

---

## 2. Akun dan autentikasi

Tabel terkait: `users` (`google_id`, `name`, `email`, `avatar`, `role`, `status`, `password`).

| Method | Path | Keterangan |
|---|---|---|
| POST | `/auth/google` | Masuk dengan Google |
| POST | `/auth/register` | Daftar dengan email |
| POST | `/auth/login` | Masuk dengan email |
| POST | `/auth/logout` **(auth)** | Mencabut token |
| GET | `/me` **(auth)** | Profil |
| PATCH | `/me` **(auth)** | Ubah nama |
| PUT | `/me/password` **(auth)** | Ubah kata sandi (hanya akun yang punya kata sandi) |
| POST | `/me/avatar` **(auth)** | Unggah foto profil |
| DELETE | `/me/avatar` **(auth)** | Hapus foto profil |

`POST /auth/google` - aplikasi mengirim ID token Google (dari paket `google_sign_in`), API memverifikasinya ke Google lalu membuat atau mengambil akun berdasarkan `google_id`:

```jsonc
// request
{ "id_token": "eyJhbGciOi..." }

// response 200
{
  "data": {
    "token": "1|abcdef...",
    "user": {
      "id": 12,
      "name": "Dewi Mayangsari",
      "email": "dewi@mail.com",
      "avatar": "https://.../a.jpg",   // opsional
      "has_password": false             // true bila users.password tidak kosong
    }
  }
}
```

`POST /auth/register`:

```jsonc
{ "name": "Dewi", "email": "dewi@mail.com", "password": "abcd1234", "password_confirmation": "abcd1234" }
// response sama dengan /auth/google. Aturan kata sandi: minimal 8 karakter, kombinasi huruf dan angka.
```

`POST /auth/login`: body `{ "email", "password" }`, response sama. Gagal login: 401 dengan `message`, atau 422 dengan `errors.email`.

`PATCH /me`: body `{ "name": "Dewi Putri" }`. Response `{ "data": { ...user } }`.

`PUT /me/password`: body `{ "current_password", "password", "password_confirmation" }`. Response 204 atau `{ "message": "..." }`.

`POST /me/avatar`: `multipart/form-data` dengan satu berkas `photo` (JPG, PNG, atau WEBP, maksimal 2 MB; aplikasi sudah memperkecil gambar sebelum mengirim). Response: `{ "data": { "avatar": "https://.../a.jpg" } }`. `DELETE /me/avatar` mengosongkan `avatar`.

### 2.1 Data tambahan Profil (opsional)

Statistik ("Inspirasi Board", "Vendor Dihubungi"), Papan Visi, dan status akun terverifikasi belum punya tabel. Aplikasi menyembunyikan bagian itu bila tidak ada datanya, jadi API tidak wajib mengirimnya. `GET /me` cukup mengirim `id`, `name`, `email`, `avatar` (opsional), dan `has_password`. Bila ingin menampilkan lencana "Akun Terverifikasi", kirim `email_verified: true`.

---

## 3. Data pasangan

Dipakai di Home (hitung mundur), Profil, Keranjang, dan Checkout (nama dan tanggal terisi otomatis).

| Method | Path |
|---|---|
| GET | `/me/couple` **(auth)** |
| PUT | `/me/couple` **(auth)** |

```jsonc
// GET -> { "data": { ... } } atau { "data": null } bila belum diisi
{
  "data": {
    "bride_name": "Clarissa Wijaya",
    "groom_name": "Adrian Pratama",
    "wedding_date": "2026-10-24"
  }
}
// PUT: body sama, response sama. wedding_date tidak boleh di masa lalu.
```

Tabel `clients` sudah punya `bride_name` dan `groom_name`, tetapi **tidak ada kolom tanggal pernikahan** (lihat bagian 11).

---

## 4. Katalog

### 4.1 Kategori

`GET /categories`. Tabel `categories` (`id`, `name`).

```jsonc
{
  "data": [
    {
      "id": 1,
      "name": "MUA",
      "subtitle": "Bridal MUA Pro",   // opsional
      "icon": "brush"                  // opsional, lihat daftar kunci ikon di bawah
    }
  ]
}
```

Daftar kategori di filter, grid, dan chip aplikasi **datang dari endpoint ini**, bukan ditulis tetap di aplikasi. Kunci ikon yang dikenal aplikasi: `groups`, `sun`, `ceremony`, `restaurant`, `bed`, `flower`, `sparkle`, `camera`, `video`, `brush`, `verified`, `event`, `drone`, `dress`, `check`, `palette`, `music`. Kunci tak dikenal memakai ikon bintang.

### 4.2 Daftar vendor

`GET /vendors`. Tabel `vendors`.

Query (semua opsional): `category_id`, `city`, `q` (cari di nama, deskripsi, kategori), `min_price`, `max_price`, `page`, `per_page`.

```jsonc
{
  "data": [
    {
      "id": 4,
      "name": "Sora Visual Stories",
      "slug": "sora-visual-stories",
      "category": { "id": 3, "name": "Photography" },   // atau string "Photography"
      "city": "Bali",                                    // atau "cities": ["Bali", "Jakarta"]
      "price": 18500000,
      "phone": "081234567890",
      "photo": "https://.../cover.jpg",                  // foto sampul

      // Opsional (tidak ada di database saat ini; bagian layarnya disembunyikan bila kosong)
      "original_price": 22000000,
      "description": "Photography & Videography",
      "rating": 4.9,
      "review_count": 142,
      "badge": "Top 1%",
      "promo_badge": "Fast RSVP",
      "price_label": "Paket D-Day Photo & Video",
      "price_note": null
    }
  ],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 20, "total": 1 }
}
```

Minimal yang wajib: `id`, `name`, `category`, `price`.

### 4.3 Detail vendor

`GET /vendors/{id}`. Tabel `vendors` dan `vendor_photos`.

```jsonc
{
  "data": {
    // Dari database
    "id": 4,
    "name": "Sora Visual Stories",
    "slug": "sora-visual-stories",
    "category": { "id": 3, "name": "Photography" },
    "price": 18500000,
    "phone": "081234567890",
    "city": "Bali",
    "address": "Jl. ...",
    "description": "Tim dokumentasi pernikahan ...",
    "instagram": "@sora.visual",
    "photos": [
      { "url": "https://.../1.jpg", "is_cover": true, "sort_order": 0 },
      { "url": "https://.../2.jpg", "is_cover": false, "sort_order": 1 }
    ],

    // Opsional (bagian layar yang bersangkutan disembunyikan bila tidak ada)
    "location": "Uluwatu, Badung - Bali",   // teks lokasi; bila kosong dipakai city lalu address
    "original_price": 22000000,              // harga coret; "Hemat" dihitung aplikasi
    "package_label": "Paket D-Day Photo & Video",
    "valid_until": "2026-12-31",             // ditampilkan "Valid s/d 31 Des 2026"
    "facts": [ { "icon": "camera", "text": "8 Jam Coverage" } ],
    "provider": { "name": "Sora Visual Stories", "tagline": "Photography Specialist", "rating": 4.9, "review_count": 142 },
    "sections": [
      { "title": "Coverage Hari-H", "subtitle": "Persiapan, akad & resepsi", "icon": "camera",
        "inclusions": ["Liputan 8 jam ...", "2 fotografer ..."] }
    ]
  }
}
```

Minimal yang wajib: `id`, `name`, `category`, `price`. Bila `price` kosong atau 0, aplikasi menampilkan "Harga menyusul" dan vendor tidak bisa ditambahkan ke pesanan.

Catatan: kolom `cashback_*`, `installment_*`, dan `guarantee` dari versi 0.1 **tidak perlu dikirim**. Fitur poin, cicilan, dan jaminan sedang disembunyikan di aplikasi sampai owner memutuskan. Bila nanti dinyalakan, bentuknya tetap sama seperti di versi 0.1 dan dibahas ulang.

### 4.4 Paket

`GET /packages` (paket `is_featured` diurutkan di atas oleh aplikasi) dan `GET /packages/{id}`. Tabel `packages` dan `package_vendor`.

```jsonc
{
  "data": {
    "id": 1,
    "slug": "paket-intimate-bali",
    "name": "Paket Intimate Bali",
    "description": "Pernikahan intimate ...",
    "availability_date": "2027-03-31",
    "duration": 8.0,
    "event_period": "Akad & Resepsi",
    "guest_capacity": 100,
    "is_featured": true,
    "photo": "https://.../paket.jpg",
    "price": 95000000,            // lihat pertanyaan terbuka no. 1
    "vendors": [                  // hanya vendor dengan package_vendor.status = active
      { "id": 6, "name": "Mattana Wedding Planner", "category": "Wedding Planner", "city": "Bali", "price": 45000000 }
    ]
  }
}
```

Aplikasi menghitung "Hemat" sebagai jumlah `vendors[].price` dikurangi `price` paket (hanya bila semua vendor punya harga dan hasilnya positif). Kolom opsional yang kosong disembunyikan. Paket dengan `price` kosong atau 0 tidak bisa dipesan. Home dirakit di aplikasi dari paket (deals), vendor (pilihan), dan artikel, jadi **tidak ada endpoint Home**.

---

## 5. Konten

### 5.1 Artikel (Inspirations)

`GET /articles` dan `GET /articles/{id}`. Tabel `articles`. Aplikasi menampilkan artikel pertama sebagai cerita utama dan sisanya sebagai daftar. Setiap artikel bisa dibuka di halaman cerita.

```jsonc
{
  "data": {
    // Dari database
    "id": 1,
    "slug": "pernikahan-intimate-uluwatu",
    "title": "Pernikahan Intimate Outdoor di Tebing Uluwatu",
    "category": "Real Weddings",
    "excerpt": "Balutan rona senja ...",
    "content": "Paragraf satu.\n\nParagraf dua.",   // teks biasa dengan baris kosong antar paragraf; HTML sederhana (<p>, <br>) juga dibersihkan
    "photo": "https://.../a.jpg",
    "author": "Dewi Mayangsari",
    "published_at": "2026-10-18",
    "package_id": 3,                                  // opsional: paket terkait, tampil sebagai kartu "Paket terkait"

    // Opsional (tidak ada di database; bagian layarnya disembunyikan bila kosong)
    "tag": "REAL LOVE STORY",
    "location": "Uluwatu, Bali",
    "read_minutes": 6,                                // bila kosong dihitung dari jumlah kata
    "reads": 1842,                                    // hanya ditampilkan sebagai angka
    "likes": 384,                                     // hanya ditampilkan sebagai angka
    "hero_caption": "Sora Visual Stories • Cliffside Edge Uluwatu",
    "stats": [ { "label": "Tamu", "value": "45 Undangan" } ],
    "quote": "Sinar matahari terbenam ...",
    "gallery": [ { "url": "https://.../1.jpg", "caption": "Gaun custom" } ],
    "vendors_title": "Vendor Pilihan Dewi & Dimas",
    "vendors": [
      { "vendor_id": 6, "name": "Mattana Wedding Planner", "role": "Wedding Organizer", "rating": 4.9, "review_count": 128, "kind": "planner" }
    ],
    "tips_title": "Tips Khusus Menikah di Cuaca Tebing Pantai",
    "tips": ["Pilih waktu akad ...", "Sediakan ..."]
  }
}
```

Hanya `id` dan `title` yang wajib. `vendors[].vendor_id` adalah id vendor di direktori (`GET /vendors`); bila ada, tombol "Lihat Vendor" membuka detail vendornya, bila tidak ada tombolnya tidak tampil. `kind` vendor: `planner`, `decor`, `photographer` (lainnya memakai ikon umum). Untuk daftar (`GET /articles`) cukup `id`, `title`, `category`, `photo`, `published_at`, dan `reads` (opsional).

### 5.2 Halaman informasi

`GET /pages/{slug}`, dengan `slug` = `terms`, `guarantee`, atau `privacy`. Teks resmi diisi tim, bukan aplikasi. Halaman `guarantee` hanya dipakai bila owner menyalakan klaim jaminan; sementara aplikasi hanya membuka `terms` dan `privacy`.

```jsonc
{
  "data": {
    "slug": "terms",
    "title": "Syarat & Ketentuan Layanan",
    "updated_at": "2026-10-01",
    "sections": [ { "heading": "Penggunaan layanan", "body": "..." } ]
  }
}
```

---

## 6. Pemesanan

Aturan dari owner WO: **pesanan selalu gabungan**. Dua jenis: (a) `package` (paket yang sudah berisi vendor) atau (b) `custom` (pengguna memilih vendor sendiri, **minimal 3 vendor**). Keranjang ada di aplikasi (tersimpan di perangkat), bukan di server; server baru tahu saat pesanan dikirim.

### 6.1 Rekening tujuan

`GET /bank-accounts`

```jsonc
{ "data": [ { "id": 1, "bank_name": "BCA", "account_number": "1234567890", "account_holder": "MyDream" } ] }
```

### 6.2 Voucher

Voucher belum ada di database. Usulan:

| Method | Path | Keterangan |
|---|---|---|
| GET | `/vouchers` **(auth)** | Voucher yang tersedia untuk pengguna |
| POST | `/vouchers/validate` **(auth)** | Body `{ "code": "DREAMWEDDING", "subtotal": 60000000 }`, response `{ "data": { "code", "discount": 5000000 } }` atau 422 |

Voucher memiliki: `code`, `title`, `description`, `type` (`fixed`/`percent`), `value`, `max_discount` (opsional), `min_spend`, `valid_until`. **Server yang menghitung potongan.** Angka di aplikasi hanya untuk tampilan.

### 6.3 Kirim pesanan

`POST /bookings` **(auth)**, `multipart/form-data` (karena memuat bukti transfer).

| Field | Wajib | Keterangan |
|---|---|---|
| `type` | ya | `package` atau `custom` |
| `package_id` | bila `package` | |
| `vendor_ids[]` | bila `custom` | Minimal 3 id vendor berbeda |
| `event_date` | ya | `YYYY-MM-DD`, tidak di masa lalu |
| `ceremony_time`, `reception_time` | ya | `HH:mm`; resepsi harus setelah akad |
| `venue_name` | ya | `bookings.venue_name` |
| `venue_address` | ya | `bookings.venue_address` |
| `venue_city` | ya | `bookings.venue_city` |
| `venue_province` | ya | `bookings.venue_province` (nama provinsi) |
| `venue_maps` | tidak | Tautan http(s) |
| `guest_count` | ya | 1 sampai 10000; tidak boleh melebihi `packages.guest_capacity` untuk paket |
| `bride_name`, `groom_name` | ya | |
| `concept` | tidak | Belum ada kolomnya |
| `pic_name`, `pic_phone` | ya | `pic_phone` format `+62...` |
| `notes` | tidak | `bookings.notes` |
| `voucher_code` | tidak | |
| `payment_type` | ya | `dp` atau `full` |
| `bank_account_id` | ya | |
| `proof` | ya | File JPG/PNG/WEBP, maksimal 2 MB |

Server **menghitung sendiri** `total_price`, potongan, dan nominal yang harus dibayar. Aplikasi tidak mengirim harga.

```jsonc
// response 201
{
  "data": {
    "id": 31,
    "invoice_number": "INV-20261027-1001",
    "title": "Paket Intimate Bali",          // atau "Custom Order (3 vendor)"
    "event_date": "2026-10-24",
    "status": "pending",                      // bookings.status
    "payment_status": "pending",
    "total_price": 90000000,
    "discount": 5000000,
    "payment": {
      "id": 55,
      "type": "dp",
      "amount": 1000000,
      "method": "bank_transfer",
      "bank_name": "BCA",
      "status": "pending"                     // payments.status
    },
    "created_at": "2026-10-27T10:15:00+07:00"
  }
}
```

Kegagalan validasi: 422 (misalnya `errors.proof`, `errors.guest_count`, `errors.vendor_ids`).

---

## 7. Notifikasi

Tabel yang disarankan: `notifications` bawaan Laravel.

| Method | Path |
|---|---|
| GET | `/notifications` **(auth)** |
| POST | `/notifications/{id}/read` **(auth)** |
| POST | `/notifications/read-all` **(auth)** |
| GET | `/me/notification-preferences` **(auth)** |
| PUT | `/me/notification-preferences` **(auth)** |

```jsonc
{
  "data": [
    {
      "id": "9b7c...",
      "kind": "booking",            // booking | payment | reminder | promo
      "title": "Pesanan dikonfirmasi",
      "body": "Vendor menerima pemesananmu ...",
      "created_at": "2026-10-27T08:00:00+07:00",
      "read_at": null,
      "route": "/cart?claim=BRIDALEXPO"   // opsional, alamat tujuan di dalam aplikasi (diawali "/")
    }
  ]
}
// preferences: { "data": { "orders": true, "reminders": true, "promos": false } }
```

Notifikasi tanpa `route` hanya ditandai dibaca saat diketuk.

---

## 8. Dukungan dan konfigurasi

| Method | Path | Keterangan |
|---|---|---|
| POST | `/support/reports` **(auth)** | Body `{ "category": "Pembayaran", "message": "..." }` (kategori: Pembayaran, Pesanan, Tampilan atau bug, Lainnya; pesan 10 sampai 1000 karakter). Response `{ "data": { "ticket": "LPR-1001" } }` |
| GET | `/config` | Pengaturan yang tidak boleh ditulis tetap di aplikasi |

```jsonc
{
  "data": {
    "admin_whatsapp": "6281200000000",   // format internasional tanpa +
    "min_custom_vendors": 3,
    "down_payment": 1000000,             // atau aturan persentase, lihat pertanyaan terbuka
    "proof_max_kb": 2048
  }
}
```

Chat vendor memakai WhatsApp dan nomor dari `vendors.phone` (format `08...` atau `+62...` diterima, aplikasi menormalkannya). Tidak ada sistem chat sendiri.

---

## 9. Yang sengaja hanya di perangkat (tidak butuh API)

Disimpan di HP pengguna dan dihapus saat keluar akun. Dicatat di sini supaya tidak dibuatkan endpoint yang tidak perlu:

- **Keranjang** (paket, Custom Order, voucher yang dipilih) dan isian checkout.
- **Vendor tersimpan** (bookmark). Belum ada tabelnya; bila nanti ingin disinkronkan antar perangkat, usulan `GET/PUT /me/saved-vendors` berisi daftar `vendor_id`.
- Token masuk (penyimpanan aman: Keystore/Keychain).

---

## 10. Pemetaan ke tabel database

| Data aplikasi | Tabel / kolom | Keterangan |
|---|---|---|
| Akun | `users` | `google_id`, `name`, `email`, `avatar`, `password` |
| Nama pengantin | `clients.bride_name`, `groom_name` | Tanggal pernikahan belum punya kolom |
| Vendor | `vendors` + `categories` + `vendor_photos` | Rating, ulasan, promo, harga coret, isi layanan tidak ada |
| Paket | `packages` + `package_vendor` | Harga tidak ada |
| Pesanan | `bookings` | `package_id`, `venue_*`, `guest_count`, `total_price`, `notes`, `status`, `payment_status`, `invoice_number` |
| Jadwal acara | `events` | `event_date`, `start_time`, `end_time`, `guest_count` (hanya satu pasang jam) |
| Pembayaran | `payments` | `booking_id`, `type`, `amount`, `method`, `bank_info`, `proof_path`, `status`, `verified_at` |
| Artikel | `articles` | Vendor cerita tidak punya relasi ke `vendors` |

---

## 11. Pertanyaan terbuka untuk backend

1. **Harga paket.** `packages` tidak punya kolom harga. Dijumlah dari vendor di dalamnya, atau ditambah kolom `price`? Aplikasi membaca `price` dari response.
2. **Pesanan custom.** `bookings` hanya punya `package_id`. Apakah pesanan custom disimpan sebagai paket baru yang dibuat otomatis dari vendor terpilih (lalu `package_vendor` terisi)? Bagaimana menandainya (mis. `is_custom`)?
3. **Dua jam acara.** `events` hanya punya `start_time` dan `end_time`. Akad dan resepsi dibuat dua event, atau satu event dari akad sampai resepsi selesai?
4. **Tanggal pernikahan**, **konsep nuansa**, serta **nama dan WhatsApp PIC** belum punya kolom. Disimpan di mana?
5. **`packages.duration`** satuannya jam atau hari? **`availability_date`** artinya mulai atau sampai kapan tersedia?
6. **`payments.type`** nilainya apa saja (`dp`, `full`, `installment`)? **`bank_info`** berisi bank tujuan, bank pengirim, atau nama pemilik rekening?
7. **Aturan DP:** nominal tetap atau persentase dari total? Apakah ada pembayaran kedua (pelunasan) lewat aplikasi, atau lewat dashboard?
8. **Artikel Real Weddings** (statistik, kutipan, galeri, vendor pilihan, tips): disimpan sebagai kolom terstruktur, JSON di `articles`, atau cukup `content` teks?
9. **Rating dan ulasan vendor:** tabel `reviews` akan dibuat? Sampai ada, rating disembunyikan di aplikasi.
10. **Kota vendor:** `vendors.city` kosong di data uji, dan satu vendor bisa melayani beberapa kota. Cukup satu kota, atau perlu daftar kota?
11. **Voucher, poin, cashback, cicilan, escrow:** dipertahankan di versi pertama atau tidak? (Keputusan owner; aplikasi sudah menyembunyikannya.)
12. **Token:** Sanctum tanpa kedaluwarsa, atau ada masa berlaku dan refresh? Tabel `personal_access_tokens` belum ada di database.
13. **Bukti transfer dan foto profil:** format dan batas ukuran final (sementara JPG/PNG/WEBP, 2 MB), dan apakah PDF boleh.
14. **URL gambar:** domain penyimpanan (mis. `storage/`), dan apakah perlu ukuran thumbnail.
15. **Foto profil:** disimpan di `users.avatar` sebagai path yang diubah jadi URL penuh? Apakah foto lama dihapus saat diganti?
16. **Vendor di cerita:** bagaimana artikel menautkan vendor (tabel pivot `article_vendor`, atau JSON di artikel)? Aplikasi hanya butuh `vendor_id` per vendor.