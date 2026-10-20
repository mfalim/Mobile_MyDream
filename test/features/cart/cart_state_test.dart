import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';

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

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  CartController controller() => container.read(cartProvider.notifier);
  CartState state() => container.read(cartProvider);

  test('keranjang kosong: total 0 dan tanpa potongan kupon', () {
    expect(state().items, isEmpty);
    expect(state().subtotal, 0);
    expect(state().discount, 0);
    expect(state().total, 0);
  });

  test('satu item: total = harga dikurangi kupon', () {
    controller().add(_item('a', 247459800));
    expect(state().subtotal, 247459800);
    expect(state().discount, 5000000);
    expect(state().total, 242459800);
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

  test('remove dan clear', () {
    controller().add(_item('a', 100));
    controller().add(_item('b', 200));
    controller().remove('a');
    expect(state().items.map((i) => i.vendorId), ['b']);

    controller().clear();
    expect(state().items, isEmpty);
  });
}
