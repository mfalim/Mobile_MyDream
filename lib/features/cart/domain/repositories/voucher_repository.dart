import 'package:w51/features/cart/domain/entities/voucher.dart';

abstract interface class VoucherRepository {
  Future<List<Voucher>> load();
}
