/// Fitur yang belum diputuskan owner, belum ada desainnya, atau menunggu API.
/// `false` = disembunyikan dari layar. Ubah menjadi `true` begitu siap.
abstract final class AppFeatures {
  /// MyDream Pay dan cicilan 0% (banner Home, baris Profil). Menunggu keputusan owner.
  static const payAndInstallments = false;

  /// Poin cashback dan cicilan di detail vendor. Menunggu keputusan owner.
  static const vendorRewards = false;

  /// QR code tamu dan e-undangan (baris Profil). Menunggu keputusan owner.
  static const guestQr = false;

  /// Ajakan memberi ulasan di toko aplikasi (baris Profil). Butuh tautan toko.
  static const storeReview = false;

  /// Pilihan bahasa (baris Profil). Aplikasi baru berbahasa Indonesia.
  static const languageSwitch = false;

  /// Papan Visi Pernikahan di Profil. Menunggu desain dan data.
  static const visionBoard = false;

  /// "Lupa kata sandi?" di Login. Butuh API.
  static const passwordRecovery = false;

  /// Klaim escrow/rekening bersama, "dana cair setelah H+1", biaya escrow
  /// GRATIS, "pajak & asuransi venue", asistensi 24/7, dan jaminan deposit di
  /// Keranjang, Checkout, dan detail vendor. Menunggu keputusan owner. Bila
  /// false, layar memakai teks apa adanya (transfer bank, diverifikasi admin).
  static const escrowClaims = false;
}
