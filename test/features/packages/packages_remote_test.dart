import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/packages/data/datasources/packages_remote_datasource.dart';
import 'package:w51/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:w51/features/packages/domain/repositories/packages_repository.dart';
import 'package:w51/features/packages/presentation/providers/packages_provider.dart';

import '../../helpers/fake_api.dart';

// Contoh dari docs/api-contract.md (angka berbentuk teks, boolean 1/0,
// kategori sebagai objek, kota boleh kosong).
final _package = <String, dynamic>{
  'id': 1,
  'slug': 'paket-intimate-bali',
  'name': 'Paket Intimate Bali',
  'description': 'Pernikahan intimate ...',
  'availability_date': '2027-03-31',
  'duration': '8.00',
  'event_period': 'Akad & Resepsi',
  'guest_capacity': 100,
  'is_featured': 1,
  'photo': 'https://example.com/paket.jpg',
  'price': '95000000.00',
  'vendors': [
    {
      'id': 6,
      'name': 'Mattana Wedding Planner',
      'category': {'id': 1, 'name': 'Wedding Planner'},
      'city': 'Bali',
      'price': '45000000.00',
    },
    {
      'id': 7,
      'name': 'Sora Visual Stories',
      'category': 'Photography',
      'city': null,
      'price': '18500000.00',
    },
  ],
};

PackagesRepository _repo(FakeAdapter adapter) =>
    PackagesRepositoryImpl(PackagesRemoteDatasource(fakeApiClient(adapter)));

void main() {
  test('daftar paket dari API terbaca ke entity', () async {
    final adapter = FakeAdapter(
      (o) => jsonResponse({
        'data': [_package],
        'meta': {'current_page': 1, 'last_page': 1, 'per_page': 20, 'total': 1},
      }),
    );
    final list = await _repo(adapter).loadAll();

    expect(adapter.requests.single.uri.path, '/api/packages');
    final p = list.single;
    expect(p.id, '1');
    expect(p.name, 'Paket Intimate Bali');
    expect(p.price, 95000000);
    expect(p.isFeatured, isTrue);
    expect(p.guestCapacity, 100);
    expect(p.durationHours, 8.0);
    expect(p.availabilityDate, DateTime(2027, 3, 31));
    expect(p.photoUrl, 'https://example.com/paket.jpg');
    expect(
        p.vendors.map((v) => v.category), ['Wedding Planner', 'Photography']);
    expect(p.vendors.last.city, isNull);
    expect(p.vendorsTotal, 63500000);
    expect(p.savings, 0); // 95 jt lebih mahal dari 63,5 jt: tanpa hemat
  });

  test('detail paket: alamat memuat id', () async {
    final adapter = FakeAdapter((o) => jsonResponse({'data': _package}));
    final p = await _repo(adapter).load('1');

    expect(adapter.requests.single.uri.path, '/api/packages/1');
    expect(p.slug, 'paket-intimate-bali');
  });

  test(
      'paket berbentuk database (tanpa harga dan kolom opsional) tidak membuat gagal',
      () async {
    final adapter = FakeAdapter(
      (o) => jsonResponse({
        'data': {'id': 2, 'slug': 'x', 'name': 'Paket X', 'is_featured': 0},
      }),
    );
    final p = await _repo(adapter).load('2');

    expect(p.price, 0);
    expect(p.vendors, isEmpty);
    expect(p.guestCapacity, isNull);
    expect(p.photoUrl, isNull);
  });

  test('404 menjadi NotFoundException', () async {
    final adapter = FakeAdapter(
      (o) => jsonResponse({'message': 'Tidak ada'}, status: 404),
    );
    await expectLater(
        _repo(adapter).load('999'), throwsA(isA<NotFoundException>()));
  });

  test('server mati menjadi NetworkException', () async {
    final adapter = FakeAdapter(
      (o) => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
        error: const SocketException('refused'),
      ),
    );
    await expectLater(
        _repo(adapter).loadAll(), throwsA(isA<NetworkException>()));
  });

  test('bawaan: repository memakai data contoh (USE_MOCK=true)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final list = await container.read(packagesRepositoryProvider).loadAll();
    expect(list, isNotEmpty);
    expect(list.first.id, startsWith('pkg-'));
  });
}
