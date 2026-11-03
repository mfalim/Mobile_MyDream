import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/storage/token_storage.dart';

import '../helpers/fake_api.dart';

void main() {
  group('permintaan', () {
    test('alamat = base URL + path + query, tanpa garis miring ganda',
        () async {
      final adapter = FakeAdapter((o) => jsonResponse({'data': []}));
      final api = fakeApiClient(
        adapter,
        baseUrl: 'https://api.example.com/api/',
      );

      await api.get('/packages', query: {'page': 2, 'q': 'bali'});

      expect(
        adapter.requests.single.uri.toString(),
        'https://api.example.com/api/packages?page=2&q=bali',
      );
      expect(adapter.requests.single.headers['Accept'], 'application/json');
    });

    test('token dikirim bila ada, dan dibaca ulang di tiap permintaan',
        () async {
      final tokens = MemoryTokenStorage();
      final adapter = FakeAdapter((o) => jsonResponse({'data': {}}));
      final api = fakeApiClient(adapter, tokens: tokens);

      await api.get('/me');
      expect(
          adapter.requests.last.headers.containsKey('Authorization'), isFalse);

      await tokens.write('abc123');
      await api.get('/me');
      expect(adapter.requests.last.headers['Authorization'], 'Bearer abc123');

      await tokens.clear();
      await api.get('/me');
      expect(
          adapter.requests.last.headers.containsKey('Authorization'), isFalse);
    });

    test('metode dan isi permintaan JSON', () async {
      final adapter = FakeAdapter((o) => jsonResponse({'data': {}}));
      final api = fakeApiClient(adapter);

      await api.put('/me/couple', body: {'bride_name': 'Dewi'});
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.data, {'bride_name': 'Dewi'});

      await api.patch('/me', body: {'name': 'Dewi'});
      expect(adapter.requests.last.method, 'PATCH');

      await api.post('/auth/logout');
      expect(adapter.requests.last.method, 'POST');

      await api.delete('/notifications/1');
      expect(adapter.requests.last.method, 'DELETE');
    });

    test('unggah berkas memakai FormData dan batas waktu kirim lebih lama',
        () async {
      final adapter = FakeAdapter((o) => jsonResponse({'data': {}}));
      final api = fakeApiClient(adapter);

      await api.postForm('/bookings', FormData.fromMap({'type': 'package'}));

      final request = adapter.requests.single;
      expect(request.data, isA<FormData>());
      final field = (request.data as FormData).fields.single;
      expect(field.key, 'type');
      expect(field.value, 'package');
      expect(request.sendTimeout, const Duration(seconds: 60));
    });
  });

  group('amplop respons', () {
    test('{"data": ...} dibuka; tanpa amplop dikembalikan apa adanya',
        () async {
      var wrapped = true;
      final adapter = FakeAdapter(
        (o) => jsonResponse(wrapped
            ? {
                'data': {'id': 1}
              }
            : {'id': 1}),
      );
      final api = fakeApiClient(adapter);

      expect(await api.getObject('/x'), {'id': 1});
      wrapped = false;
      expect(await api.getObject('/x'), {'id': 1});
    });

    test('getList membuka daftar dan mengabaikan meta', () async {
      final adapter = FakeAdapter(
        (o) => jsonResponse({
          'data': [
            {'id': 1},
            {'id': 2},
          ],
          'meta': {
            'current_page': 1,
            'last_page': 1,
            'per_page': 20,
            'total': 2
          },
        }),
      );
      final list = await fakeApiClient(adapter).getList('/x');
      expect(list.map((e) => e['id']), [1, 2]);
    });

    test('bentuk yang tidak sesuai menjadi ServerException', () async {
      final api = fakeApiClient(FakeAdapter((o) => jsonResponse({'data': []})));
      await expectLater(api.getObject('/x'), throwsA(isA<ServerException>()));

      final api2 = fakeApiClient(
        FakeAdapter((o) => jsonResponse({
              'data': {'id': 1}
            })),
      );
      await expectLater(api2.getList('/x'), throwsA(isA<ServerException>()));
    });
  });

  group('kegagalan', () {
    test('404 menjadi NotFoundException dengan path-nya', () async {
      final api = fakeApiClient(
        FakeAdapter(
            (o) => jsonResponse({'message': 'No query results'}, status: 404)),
      );
      await expectLater(
        api.get('/packages/9'),
        throwsA(
          isA<NotFoundException>().having((e) => e.what, 'what', '/packages/9'),
        ),
      );
    });

    test('422: pesan pertama dan daftar error per kolom', () async {
      final api = fakeApiClient(
        FakeAdapter(
          (o) => jsonResponse({
            'message': 'The given data was invalid.',
            'errors': {
              'email': ['Email sudah dipakai.', 'Format email salah.'],
              'password': ['Terlalu pendek.'],
            },
          }, status: 422),
        ),
      );
      await expectLater(
        api.post('/auth/register', body: {}),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.message, 'message', 'Email sudah dipakai.')
              .having((e) => e.firstError('password'), 'password',
                  'Terlalu pendek.')
              .having((e) => e.fieldErrors['email']?.length, 'email', 2)
              .having((e) => e.firstError('nama'), 'kolom lain', isNull),
        ),
      );
    });

    test('422 tanpa daftar error memakai pesan server', () async {
      final api = fakeApiClient(
        FakeAdapter(
            (o) => jsonResponse({'message': 'Data tidak valid.'}, status: 422)),
      );
      await expectLater(
        api.post('/x', body: {}),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Data tidak valid.',
          ),
        ),
      );
    });

    test('401 dengan token: sesi berakhir, callback dipanggil', () async {
      var called = 0;
      final api = fakeApiClient(
        FakeAdapter(
            (o) => jsonResponse({'message': 'Unauthenticated.'}, status: 401)),
        tokens: MemoryTokenStorage('abc'),
        onUnauthorized: () async => called++,
      );
      await expectLater(
        api.get('/me'),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Sesi berakhir. Silakan masuk kembali.',
          ),
        ),
      );
      expect(called, 1);
    });

    test(
        '401 tanpa token (gagal login): pesan server, callback tidak dipanggil',
        () async {
      var called = 0;
      final api = fakeApiClient(
        FakeAdapter(
          (o) => jsonResponse({'message': 'Email atau kata sandi salah.'},
              status: 401),
        ),
        onUnauthorized: () async => called++,
      );
      await expectLater(
        api.post('/auth/login', body: {}),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Email atau kata sandi salah.',
          ),
        ),
      );
      expect(called, 0);
    });

    test('callback yang gagal tidak menutupi UnauthorizedException', () async {
      final api = fakeApiClient(
        FakeAdapter((o) => jsonResponse({}, status: 401)),
        tokens: MemoryTokenStorage('abc'),
        onUnauthorized: () async => throw Exception('gagal'),
      );
      await expectLater(api.get('/me'), throwsA(isA<UnauthorizedException>()));
    });

    test('5xx, 429, 403, dan respons non-JSON menjadi ServerException',
        () async {
      Future<void> expectServer(
        FakeAdapter adapter, {
        required int status,
        String? message,
      }) async {
        await expectLater(
          fakeApiClient(adapter).get('/x'),
          throwsA(
            isA<ServerException>()
                .having((e) => e.statusCode, 'statusCode', status)
                .having(
                  (e) => message == null || e.message.contains(message),
                  'pesan',
                  isTrue,
                ),
          ),
        );
      }

      await expectServer(
        FakeAdapter(
            (o) => jsonResponse({'message': 'SQLSTATE[HY000]'}, status: 500)),
        status: 500,
        message: 'Server sedang bermasalah',
      );
      await expectServer(
        FakeAdapter(
            (o) => htmlResponse('<html>Bad Gateway</html>', status: 502)),
        status: 502,
        message: 'Server sedang bermasalah',
      );
      await expectServer(
        FakeAdapter((o) => jsonResponse({}, status: 429)),
        status: 429,
        message: 'Terlalu banyak permintaan',
      );
      await expectServer(
        FakeAdapter(
            (o) => jsonResponse({'message': 'Tidak diizinkan.'}, status: 403)),
        status: 403,
        message: 'Tidak diizinkan.',
      );
    });

    test('pesan server di 5xx tidak bocor ke pengguna', () async {
      final api = fakeApiClient(
        FakeAdapter(
            (o) => jsonResponse({'message': 'SQLSTATE[HY000]'}, status: 500)),
      );
      await expectLater(
        api.get('/x'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message.contains('SQLSTATE'),
            'bocor',
            isFalse,
          ),
        ),
      );
    });

    test('timeout dan tidak ada koneksi menjadi NetworkException', () async {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        final api = fakeApiClient(
          FakeAdapter((o) => throw DioException(requestOptions: o, type: type)),
        );
        await expectLater(
          api.get('/x'),
          throwsA(isA<NetworkException>()),
          reason: '$type',
        );
      }

      final socket = fakeApiClient(
        FakeAdapter(
          (o) => throw DioException(
            requestOptions: o,
            error: const SocketException('Connection refused'),
          ),
        ),
      );
      await expectLater(socket.get('/x'), throwsA(isA<NetworkException>()));
    });

    test('kesalahan tak dikenal menjadi ServerException', () async {
      final api = fakeApiClient(
        FakeAdapter(
          (o) => throw DioException(requestOptions: o, error: StateError('x')),
        ),
      );
      await expectLater(api.get('/x'), throwsA(isA<ServerException>()));
    });
  });

  group('pesan untuk pengguna', () {
    test('kegagalan jaringan dan server punya pesan sendiri', () {
      expect(
        userMessage(const NetworkException(), fallback: 'x'),
        contains('terhubung ke server'),
      );
      expect(
        userMessage(const ServerException('Server bermasalah'), fallback: 'x'),
        'Server bermasalah',
      );
      expect(
        userMessage(const UnauthorizedException(), fallback: 'x'),
        contains('Sesi berakhir'),
      );
    });

    test('selain itu memakai pesan cadangan', () {
      expect(userMessage(Exception('boom'), fallback: 'Gagal memuat.'),
          'Gagal memuat.');
      expect(userMessage(const NotFoundException('x'), fallback: 'cadangan'),
          'cadangan');
    });
  });

  test('MemoryTokenStorage: tulis, baca, hapus', () async {
    final tokens = MemoryTokenStorage();
    expect(await tokens.read(), isNull);
    await tokens.write('t');
    expect(await tokens.read(), 't');
    await tokens.clear();
    expect(await tokens.read(), isNull);
  });
}
