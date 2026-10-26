import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/constants/indonesia_provinces.dart';
import 'package:w51/core/utils/validators.dart';

void main() {
  test('validateRequired: kosong dan terlalu pendek', () {
    expect(validateRequired(null, 'Nama venue'), 'Nama venue wajib diisi');
    expect(validateRequired('   ', 'Nama venue'), 'Nama venue wajib diisi');
    expect(validateRequired('ab', 'Nama venue', minLength: 3), isNotNull);
    expect(validateRequired(' abc ', 'Nama venue', minLength: 3), isNull);
  });

  test('validateIdMobile', () {
    expect(validateIdMobile(''), 'Nomor WhatsApp wajib diisi');
    expect(validateIdMobile('0812345678'), contains('tanpa angka 0'));
    expect(validateIdMobile('8abc12345'), 'Hanya boleh angka');
    expect(validateIdMobile('712345678'), contains('diawali angka 8'));
    expect(validateIdMobile('81234567'), 'Nomor harus 9–12 digit');
    expect(validateIdMobile('8123456789012'), 'Nomor harus 9–12 digit');
    expect(validateIdMobile('812345678'), isNull); // 9 digit
    expect(validateIdMobile('81298743210'), isNull);
    expect(validateIdMobile('812987432101'), isNull); // 12 digit
  });

  test('validateOptionalUrl', () {
    expect(validateOptionalUrl(''), isNull);
    expect(validateOptionalUrl(null), isNull);
    expect(validateOptionalUrl('abc'), isNotNull);
    expect(validateOptionalUrl('ftp://maps.example.com'), isNotNull);
    expect(validateOptionalUrl('http://localhost'), isNotNull);
    expect(validateOptionalUrl('https://maps.app.goo.gl/abc123'), isNull);
    expect(validateOptionalUrl('http://maps.example.com/x'), isNull);
  });

  test('validateGuestCount', () {
    expect(validateGuestCount(''), 'Jumlah tamu wajib diisi');
    expect(validateGuestCount('abc'), 'Masukkan angka');
    expect(validateGuestCount('0'), 'Minimal 1 tamu');
    expect(validateGuestCount('-5'), 'Minimal 1 tamu');
    expect(validateGuestCount('1'), isNull);
    expect(validateGuestCount('10000'), isNull);
    expect(validateGuestCount('10001'), 'Maksimal 10.000 tamu');
  });

  test('validateGuestCount dibatasi kapasitas paket', () {
    expect(validateGuestCount('100', capacity: 100), isNull);
    expect(
      validateGuestCount('101', capacity: 100),
      'Maksimal 100 tamu untuk paket ini',
    );
  });

  test('daftar provinsi: 38 dan unik', () {
    expect(kIndonesianProvinces.length, 38);
    expect(kIndonesianProvinces.toSet().length, 38);
    expect(kIndonesianProvinces, containsAll(['Bali', 'DKI Jakarta']));
  });
}
