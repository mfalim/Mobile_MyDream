import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/account/data/datasources/account_mock_datasource.dart';

void main() {
  const datasource = AccountMockDatasource(delay: Duration.zero);

  test('updateName merapikan spasi', () async {
    expect(await datasource.updateName('  Dewi  '), 'Dewi');
  });

  test('updateName menolak terlalu pendek dan terlalu panjang', () async {
    await expectLater(
      datasource.updateName('A'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      datasource.updateName('x' * 101),
      throwsA(isA<ValidationException>()),
    );
  });

  test('changePassword: salah, terlalu pendek, atau sama ditolak', () async {
    await expectLater(
      datasource.changePassword(current: 'salah', password: 'baru12345'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      datasource.changePassword(current: 'lama1234', password: 'abc'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      datasource.changePassword(current: 'lama1234', password: 'lama1234'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('changePassword berhasil', () async {
    await datasource.changePassword(current: 'lama1234', password: 'baru12345');
  });
}
