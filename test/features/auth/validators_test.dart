import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/auth/domain/validators.dart';

void main() {
  test('validateName', () {
    expect(validateName(null), isNotNull);
    expect(validateName('  '), isNotNull);
    expect(validateName('A'), isNotNull);
    expect(validateName('Dewi'), isNull);
  });

  test('validateEmail', () {
    expect(validateEmail(''), 'Email wajib diisi');
    for (final bad in ['abc', 'a@b', 'a b@c.com', '@c.com', 'a@c.']) {
      expect(validateEmail(bad), isNotNull, reason: bad);
    }
    expect(validateEmail('nama@email.com'), isNull);
    expect(validateEmail(' nama@email.co.id '), isNull);
  });

  test('validateNewPassword: panjang dan komposisi', () {
    expect(validateNewPassword(''), 'Kata sandi wajib diisi');
    expect(validateNewPassword('abc123'), 'Kata sandi minimal 8 karakter');
    expect(
        validateNewPassword('abcdefgh'), 'Gunakan kombinasi huruf dan angka');
    expect(
        validateNewPassword('12345678'), 'Gunakan kombinasi huruf dan angka');
    expect(validateNewPassword('abcd1234'), isNull);
  });

  test('validateLoginPassword hanya mewajibkan terisi', () {
    expect(validateLoginPassword(''), isNotNull);
    expect(validateLoginPassword('x'), isNull);
  });

  test('validateConfirmPassword', () {
    expect(validateConfirmPassword('', 'abcd1234'), 'Ulangi kata sandi');
    expect(validateConfirmPassword('abcd12345', 'abcd1234'), isNotNull);
    expect(validateConfirmPassword('abcd1234', 'abcd1234'), isNull);
  });
}
