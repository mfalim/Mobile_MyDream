import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/cart/data/datasources/voucher_mock_datasource.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';

void main() {
  const fixed = Voucher(
    code: 'FIX',
    title: 'Potongan',
    description: '',
    type: VoucherType.fixed,
    value: 5000000,
    minSpend: 50000000,
    validUntilLabel: '-',
  );
  const percent = Voucher(
    code: 'PCT',
    title: 'Diskon',
    description: '',
    type: VoucherType.percent,
    value: 10,
    maxDiscount: 15000000,
    minSpend: 100000000,
    validUntilLabel: '-',
  );

  test('voucher nominal tetap, dan tidak melebihi total belanja', () {
    expect(fixed.discountFor(60000000), 5000000);
    expect(fixed.discountFor(3000000), 3000000);
  });

  test('voucher persen dengan batas maksimal', () {
    expect(percent.discountFor(100000000), 10000000);
    expect(percent.discountFor(247459800), 15000000);
  });

  test('voucher persen tanpa batas maksimal', () {
    const noCap = Voucher(
      code: 'NC',
      title: '',
      description: '',
      type: VoucherType.percent,
      value: 3,
      minSpend: 0,
      validUntilLabel: '-',
    );
    expect(noCap.discountFor(100000000), 3000000);
  });

  test('syarat belanja minimal: batas bawah termasuk', () {
    expect(fixed.isEligible(49999999), isFalse);
    expect(fixed.isEligible(50000000), isTrue);
  });

  test('data contoh: kode unik dan tidak kosong', () async {
    final list = await VoucherMockDatasource().fetch();
    expect(list, isNotEmpty);
    expect(list.map((v) => v.code).toSet().length, list.length);
  });
}
