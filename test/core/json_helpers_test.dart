import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/utils/json_helpers.dart';

void main() {
  test('jsonInt: angka, teks decimal, dan nilai yang tidak bisa dibaca', () {
    expect(jsonInt(5), 5);
    expect(jsonInt(5.6), 6);
    expect(jsonInt('100000.00'), 100000);
    expect(jsonInt(' 42 '), 42);
    expect(jsonInt('abc'), isNull);
    expect(jsonInt(null), isNull);
    expect(jsonInt(true), isNull);
  });

  test('jsonDouble', () {
    expect(jsonDouble(2), 2.0);
    expect(jsonDouble('8.50'), 8.5);
    expect(jsonDouble('x'), isNull);
    expect(jsonDouble(null), isNull);
  });

  test('jsonBool: true/false, 1/0, teks, dan nilai bawaan', () {
    expect(jsonBool(true), isTrue);
    expect(jsonBool(false), isFalse);
    expect(jsonBool(1), isTrue);
    expect(jsonBool(0), isFalse);
    expect(jsonBool('1'), isTrue);
    expect(jsonBool('true'), isTrue);
    expect(jsonBool('false'), isFalse);
    expect(jsonBool(null), isFalse);
    expect(jsonBool(null, fallback: true), isTrue);
  });

  test('jsonString: dirapikan, kosong menjadi null, angka menjadi teks', () {
    expect(jsonString(' a '), 'a');
    expect(jsonString('   '), isNull);
    expect(jsonString(''), isNull);
    expect(jsonString(7), '7');
    expect(jsonString(null), isNull);
    expect(jsonString(['x']), isNull);
  });

  test('jsonNameOf: teks atau objek dengan name', () {
    expect(jsonNameOf('Venue'), 'Venue');
    expect(jsonNameOf({'id': 1, 'name': 'MUA'}), 'MUA');
    expect(jsonNameOf({'id': 1}), isNull);
    expect(jsonNameOf(null), isNull);
  });
}
