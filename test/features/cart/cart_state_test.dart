import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';

CartItem _item(String id, int price) => CartItem(
      vendorId: id,
      providerName: 'Provider',
      providerSubtitle: 'Official Partner',
      location: 'Bali',
      packageTitle: 'Paket $id',
      paxIncluded: 100,
      price: price,
      originalPrice: price + 1000000,
      savingsBadge: 'Hemat',
      inclusionSummary: 'Ringkasan',
      cashbackPoints: 100,
      cashbackPercent: 2.5,
      installmentMonths: 24,
    );

const _fixed = Voucher(
  code: 'FIX',
  title: 'Potongan Rp 5 Juta',
  description: '',
  type: VoucherType.fixed,
  value: 5000000,
  minSpend: 50000000,
  validUntilLabel: '-',
);

const _bigPercent = Voucher(
  code: 'BIG',
  title: 'Diskon 10%',
  description: '',
  type: VoucherType.percent,
  value: 10,
  maxDiscount: 15000000,
  minSpend: 300000000,
  validUntilLabel: '-',
);

CustomVendorItem _vendor(String id, int price) => CustomVendorItem(
      vendorId: id,
      name: 'Vendor $id',
      category: 'Venue',
      location: 'Bali',
      price: price,
    );

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  CartController controller() => container.read(cartProvider.notifier);
  CartState state() => container.read(cartProvider);

  test('keranjang kosong: total 0, tanpa voucher dan tanpa potongan', () {
    expect(state().items, isEmpty);
    expect(state().voucher, isNull);
    expect(state().subtotal, 0);
    expect(state().discount, 0);
    expect(state().total, 0);
  });

  test('satu item tanpa voucher: total = harga', () {
    controller().add(_item('a', 247459800));
    expect(state().subtotal, 247459800);
    expect(state().discount, 0);
    expect(state().total, 247459800);
  });

  test('voucher nominal tetap mengurangi total', () {
    controller().add(_item('a', 247459800));
    controller().selectVoucher(_fixed);
    expect(state().discount, 5000000);
    expect(state().total, 242459800);
    expect(state().voucherNotEligible, isFalse);
  });

  test('voucher belum berlaku bila belanja di bawah minimum', () {
    controller().add(_item('a', 247459800));
    controller().selectVoucher(_bigPercent);
    expect(state().discount, 0);
    expect(state().voucherNotEligible, isTrue);
    expect(state().total, 247459800);

    // Belanja bertambah sehingga memenuhi minimum (494.919.600 >= 300 jt).
    controller().add(_item('b', 247459800));
    expect(state().voucherNotEligible, isFalse);
    expect(state().discount, 15000000); // 10% dibatasi maksimal 15 jt
  });

  test('melepas voucher mengembalikan total penuh', () {
    controller().add(_item('a', 100000000));
    controller().selectVoucher(_fixed);
    expect(state().discount, 5000000);
    controller().selectVoucher(null);
    expect(state().voucher, isNull);
    expect(state().discount, 0);
  });

  test('paket yang sama tidak ditambahkan dua kali', () {
    controller().add(_item('a', 100));
    controller().add(_item('a', 100));
    expect(state().items.length, 1);
  });

  test('item yang tidak dicentang tidak dihitung', () {
    controller().add(_item('a', 10000000));
    controller().add(_item('b', 20000000));
    expect(state().subtotal, 30000000);

    controller().toggle('a');
    expect(state().selected.length, 1);
    expect(state().subtotal, 20000000);

    controller().toggle('b');
    expect(state().selected, isEmpty);
    expect(state().total, 0);
  });

  test(
      'tanpa item terpilih voucher tidak memberi potongan dan tanpa peringatan',
      () {
    controller().add(_item('a', 100000000));
    controller().selectVoucher(_fixed);
    controller().toggle('a');
    expect(state().discount, 0);
    expect(state().voucherNotEligible, isFalse);
  });

  test('remove menghapus item, clear menghapus item dan voucher', () {
    controller().add(_item('a', 100));
    controller().add(_item('b', 200));
    controller().remove('a');
    expect(state().items.map((i) => i.vendorId), ['b']);

    controller().selectVoucher(_fixed);
    controller().clear();
    expect(state().items, isEmpty);
    expect(state().voucher, isNull);
  });

  group('custom order', () {
    test('baru siap setelah $kMinCustomVendors vendor', () {
      controller().addCustomVendor(_vendor('a', 10000000));
      controller().addCustomVendor(_vendor('b', 20000000));
      expect(state().customReady, isFalse);
      expect(state().customOrderItem, isNull);

      controller().addCustomVendor(_vendor('c', 30000000));
      expect(state().customReady, isTrue);
      final item = state().customOrderItem!;
      expect(item.isCustom, isTrue);
      expect(item.vendorId, kCustomOrderId);
      expect(item.price, 60000000);
      expect(state().customSubtotal, 60000000);
    });

    test('vendor yang sama tidak ditambahkan dua kali', () {
      controller().addCustomVendor(_vendor('a', 100));
      controller().addCustomVendor(_vendor('a', 100));
      expect(state().customVendors.length, 1);
    });

    test('menghapus vendor menurunkan syarat minimal', () {
      for (final id in ['a', 'b', 'c']) {
        controller().addCustomVendor(_vendor(id, 1000000));
      }
      expect(state().customReady, isTrue);
      controller().removeCustomVendor('b');
      expect(state().customReady, isFalse);
      expect(state().customVendors.map((v) => v.vendorId), ['a', 'c']);
    });

    test('voucher dihitung dari jumlah vendor, dengan syarat minimum', () {
      for (final id in ['a', 'b', 'c']) {
        controller().addCustomVendor(_vendor(id, 20000000)); // 60 jt
      }
      controller().selectVoucher(_fixed); // minimal 50 jt
      expect(state().customDiscount, 5000000);
      expect(state().customTotal, 55000000);
      expect(state().customVoucherNotEligible, isFalse);

      controller().removeCustomVendor('c'); // 40 jt < 50 jt
      expect(state().customDiscount, 0);
      expect(state().customVoucherNotEligible, isTrue);
    });

    test('orderItemFor: paket dan custom dibedakan lewat id', () {
      controller().add(_item('paket-1', 90000000));
      for (final id in ['a', 'b', 'c']) {
        controller().addCustomVendor(_vendor(id, 1000000));
      }
      expect(state().orderItemFor('paket-1')?.price, 90000000);
      expect(state().orderItemFor(kCustomOrderId)?.price, 3000000);
      expect(state().orderItemFor('tidak-ada'), isNull);
    });

    test('remove(kCustomOrderId) mengosongkan custom, paket tidak ikut', () {
      controller().add(_item('paket-1', 90000000));
      controller().addCustomVendor(_vendor('a', 1000000));
      expect(state().orderCount, 2);

      controller().remove(kCustomOrderId);
      expect(state().customVendors, isEmpty);
      expect(state().items.length, 1);
      expect(state().orderCount, 1);
    });

    test('clear mengosongkan paket, custom, dan voucher', () {
      controller().add(_item('paket-1', 100));
      controller().addCustomVendor(_vendor('a', 100));
      controller().selectVoucher(_fixed);
      controller().clear();
      expect(state().items, isEmpty);
      expect(state().customVendors, isEmpty);
      expect(state().voucher, isNull);
    });
  });
}
