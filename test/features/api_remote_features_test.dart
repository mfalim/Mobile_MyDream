import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/cart/data/datasources/voucher_remote_datasource.dart';
import 'package:w51/features/info/data/datasources/info_remote_datasource.dart';
import 'package:w51/features/inspirations/data/datasources/inspirations_remote_datasource.dart';
import 'package:w51/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:w51/features/payment/data/datasources/payments_remote_datasource.dart';
import 'package:w51/features/payment/domain/entities/order_submission.dart';
import 'package:w51/features/payment/domain/entities/payment_options.dart';
import 'package:w51/features/support/data/datasources/support_remote_datasource.dart';
import 'package:w51/features/support/domain/entities/support_report.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/vendors/data/datasources/vendor_detail_remote_datasource.dart';
import 'package:w51/features/vendors/data/datasources/vendors_remote_datasource.dart';

import '../helpers/fake_api.dart';

void main() {
  test('katalog vendor memuat kategori dan vendor dari API', () async {
    final adapter = FakeAdapter((request) {
      if (request.uri.path == '/api/categories') {
        return jsonResponse({
          'data': [
            {'id': 1, 'name': 'Photography', 'icon': 'camera'},
          ],
        });
      }
      return jsonResponse({
        'data': [
          {
            'id': 4,
            'name': 'Sora Visual Stories',
            'category': {'id': 3, 'name': 'Photography'},
            'city': 'Bali',
            'price': '18500000.00',
          },
        ],
      });
    });
    final api = fakeApiClient(adapter);
    addTearDown(api.close);

    final data = await VendorsRemoteDatasource(api).fetch();

    expect(data.categories.single.label, 'Photography');
    expect(data.categories.single.icon.codePoint, isNotNull);
    expect(data.featured.single.id, '4');
    expect(data.featured.single.price, 18500000);
    expect(
      adapter.requests.map((request) => request.uri.path).toSet(),
      {'/api/categories', '/api/vendors'},
    );
  });

  test('detail vendor membaca id sebagai segmen URL', () async {
    final adapter = FakeAdapter((request) => jsonResponse({
          'data': {
            'id': 4,
            'name': 'Sora Visual Stories',
            'category': 'Photography',
            'price': 18500000,
            'photos': [
              {'url': 'https://example.com/photo.jpg'},
            ],
          },
        }));
    final api = fakeApiClient(adapter);
    addTearDown(api.close);

    final vendor = await VendorDetailRemoteDatasource(api).fetch('id/empat');

    expect(adapter.requests.single.uri.path, '/api/vendors/id%2Fempat');
    expect(vendor.name, 'Sora Visual Stories');
    expect(vendor.photoUrls.single, 'https://example.com/photo.jpg');
  });

  test('artikel dimuat untuk Home dan halaman detail', () async {
    final adapter = FakeAdapter((request) => jsonResponse({
          'data': request.uri.path == '/api/articles'
              ? [
                  {
                    'id': 7,
                    'title': 'Kisah Pernikahan',
                    'category': 'Real Weddings',
                    'content': 'Cerita dari server.',
                  },
                ]
              : {
                  'id': 7,
                  'title': 'Kisah Pernikahan',
                  'category': 'Real Weddings',
                  'content': 'Cerita lengkap dari server.',
                },
        }));
    final api = fakeApiClient(adapter);
    addTearDown(api.close);
    final datasource = InspirationsRemoteDatasource(api);

    final list = await datasource.fetch();
    final detail = await datasource.fetchStory('7');

    expect(list.story?.title, 'Kisah Pernikahan');
    expect(detail.paragraphs, ['Cerita lengkap dari server.']);
    expect(adapter.requests.last.uri.path, '/api/articles/7');
  });

  test('halaman informasi dan nomor tiket berasal dari API', () async {
    final adapter = FakeAdapter((request) => jsonResponse({
          'data': request.uri.path == '/api/pages/privacy'
              ? {
                  'slug': 'privacy',
                  'title': 'Kebijakan Privasi',
                  'updated_at': '2026-10-01',
                  'sections': [
                    {'heading': 'Data', 'body': 'Informasi resmi.'},
                  ],
                }
              : {
                  'ticket': 'LPR-1001',
                },
        }));
    final api = fakeApiClient(adapter);
    addTearDown(api.close);

    final page = await InfoRemoteDatasource(api).fetch('privacy');
    final ticket = await SupportRemoteDatasource(api).submit(
      const SupportReport(
          category: 'Tampilan atau bug', message: 'Aplikasi macet.'),
    );

    expect(page.sections.single.body, 'Informasi resmi.');
    expect(ticket, 'LPR-1001');
    expect(adapter.requests.last.uri.path, '/api/support/reports');
  });

  test('voucher, rekening, dan notifikasi dipetakan dari respons server',
      () async {
    final adapter = FakeAdapter((request) {
      switch (request.uri.path) {
        case '/api/vouchers':
          return jsonResponse({
            'data': [
              {
                'code': 'DREAM',
                'title': 'Potongan',
                'type': 'fixed',
                'value': 5000000,
                'min_spend': 50000000,
                'valid_until': '2026-12-31',
              },
            ],
          });
        case '/api/bank-accounts':
          return jsonResponse({
            'data': [
              {
                'id': 1,
                'bank_name': 'BCA',
                'account_number': '123',
                'account_holder': 'MyDream',
              },
            ],
          });
        default:
          return jsonResponse({
            'data': [
              {
                'id': 'n1',
                'kind': 'payment',
                'title': 'Pembayaran diterima',
                'body': 'Detail pembayaran.',
                'created_at': '2026-10-27T08:00:00+07:00',
                'read_at': null,
              },
            ],
          });
      }
    });
    final api = fakeApiClient(adapter);
    addTearDown(api.close);

    final vouchers = await VoucherRemoteDatasource(api).fetch();
    final accounts = await PaymentsRemoteDatasource(api).fetchBankAccounts();
    final notifications = await NotificationsRemoteDatasource(api).fetch();

    expect(vouchers.single.discountFor(60000000), 5000000);
    expect(accounts.single.id, '1');
    expect(notifications.single.kind.name, 'payment');
    expect(notifications.single.read, isFalse);
  });

  test('pesanan dan bukti transfer dikirim sebagai multipart ke server',
      () async {
    final directory = await Directory.systemTemp.createTemp('mydream-proof');
    addTearDown(() => directory.delete(recursive: true));
    final proof = File('${directory.path}\\proof.jpg');
    await proof.writeAsBytes([1, 2, 3]);
    FormData? sentForm;
    final adapter = FakeAdapter((request) {
      sentForm = request.data as FormData;
      return jsonResponse({
        'data': {
          'invoice_number': 'INV-20261112-1001',
          'title': 'Custom Order',
          'event_date': '2026-12-01',
          'status': 'pending',
          'payment_status': 'pending',
          'total_price': 60000000,
          'payment': {
            'type': 'dp',
            'amount': 1000000,
            'bank_name': 'BCA',
            'status': 'pending',
          },
          'created_at': '2026-11-12T10:00:00+07:00',
        },
      });
    });
    final api = fakeApiClient(adapter);
    addTearDown(api.close);

    final receipt = await PaymentsRemoteDatasource(api).submit(
      OrderSubmission(
        itemId: 'custom-order',
        itemTitle: 'Custom Order',
        isCustom: true,
        totalAmount: 60000000,
        scheme: PaymentScheme.downPayment,
        payAmount: 1000000,
        bankAccountId: '1',
        proofName: 'proof.jpg',
        proofPath: proof.path,
        vendorIds: const ['4', '5', '6'],
        checkout: CheckoutDetails(
          vendorId: 'custom-order',
          brideName: 'Ayu',
          groomName: 'Bima',
          eventDate: DateTime(2026, 12, 1),
          ceremonyMinutes: 480,
          receptionMinutes: 600,
          venueName: 'Gedung',
          venueAddress: 'Jalan Mawar',
          venueCity: 'Jember',
          venueProvince: 'Jawa Timur',
          guestCount: 100,
          concept: '',
          picName: 'Ayu',
          whatsapp: '+628123456789',
          notes: '',
        ),
      ),
    );

    expect(adapter.requests.single.uri.path, '/api/bookings');
    expect(
      sentForm!.fields.any(
        (field) => field.key == 'event_date' && field.value == '2026-12-01',
      ),
      isTrue,
    );
    expect(
      sentForm!.fields.any(
        (field) => field.key == 'payment_type' && field.value == 'dp',
      ),
      isTrue,
    );
    expect(
      sentForm!.fields
          .where((field) => field.key == 'vendor_ids[]')
          .map((field) => field.value),
      ['4', '5', '6'],
    );
    expect(sentForm!.files.single.key, 'proof');
    expect(receipt.invoiceNumber, 'INV-20261112-1001');
    expect(receipt.totalAmount, 60000000);
    expect(receipt.payAmount, 1000000);
  });
}
