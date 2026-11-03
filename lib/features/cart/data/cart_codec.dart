import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/core/utils/json_helpers.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/cart/domain/entities/voucher.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';

/// Menyimpan dan memulihkan keranjang. Item atau voucher yang rusak dilewati,
/// tidak membuat seluruh keranjang gagal dipulihkan.
abstract final class CartCodec {
  static Map<String, dynamic> encode(CartState state) {
    final voucher = state.voucher;
    return {
      'v': kStorageVersion,
      'items': [for (final i in state.items) _encodeItem(i)],
      'custom_vendors': [for (final v in state.customVendors) _encodeVendor(v)],
      'voucher': voucher == null ? null : _encodeVoucher(voucher),
    };
  }

  static CartState decode(Map<String, dynamic>? json) {
    if (json == null || json['v'] != kStorageVersion) return const CartState();
    return CartState(
      items:
          _maps(json['items']).map(_decodeItem).whereType<CartItem>().toList(),
      customVendors: _maps(
        json['custom_vendors'],
      ).map(_decodeVendor).whereType<CustomVendorItem>().toList(),
      voucher: _decodeVoucher(json['voucher']),
    );
  }

  static List<Map<String, dynamic>> _maps(Object? raw) => raw is List
      ? [for (final e in raw.whereType<Map>()) Map<String, dynamic>.from(e)]
      : const [];

  // ---- Item paket / custom ----
  static Map<String, dynamic> _encodeItem(CartItem i) => {
        'vendor_id': i.vendorId,
        'kind': i.kind.name,
        'provider_name': i.providerName,
        'provider_subtitle': i.providerSubtitle,
        'location': i.location,
        'package_title': i.packageTitle,
        'pax_included': i.paxIncluded,
        'price': i.price,
        'original_price': i.originalPrice,
        'savings_badge': i.savingsBadge,
        'inclusion_summary': i.inclusionSummary,
        'cashback_points': i.cashbackPoints,
        'cashback_percent': i.cashbackPercent,
        'installment_months': i.installmentMonths,
        'guest_capacity': i.guestCapacity,
        'selected': i.selected,
      };

  static CartItem? _decodeItem(Map<String, dynamic> m) {
    final id = jsonString(m['vendor_id']);
    final title = jsonString(m['package_title']);
    final price = jsonInt(m['price']);
    if (id == null || title == null || price == null) return null;
    final kind = CartItemKind.values
        .where((k) => k.name == jsonString(m['kind']))
        .firstOrNull;
    return CartItem(
      vendorId: id,
      kind: kind ?? CartItemKind.package,
      providerName: jsonString(m['provider_name']) ?? '',
      providerSubtitle: jsonString(m['provider_subtitle']) ?? '',
      location: jsonString(m['location']) ?? '',
      packageTitle: title,
      paxIncluded: jsonInt(m['pax_included']) ?? 0,
      price: price,
      originalPrice: jsonInt(m['original_price']) ?? price,
      savingsBadge: jsonString(m['savings_badge']) ?? '',
      inclusionSummary: jsonString(m['inclusion_summary']) ?? '',
      cashbackPoints: jsonInt(m['cashback_points']) ?? 0,
      cashbackPercent: jsonDouble(m['cashback_percent']) ?? 0,
      installmentMonths: jsonInt(m['installment_months']) ?? 0,
      guestCapacity: jsonInt(m['guest_capacity']),
      selected: jsonBool(m['selected'], fallback: true),
    );
  }

  // ---- Vendor Custom Order ----
  static Map<String, dynamic> _encodeVendor(CustomVendorItem v) => {
        'vendor_id': v.vendorId,
        'name': v.name,
        'category': v.category,
        'location': v.location,
        'price': v.price,
      };

  static CustomVendorItem? _decodeVendor(Map<String, dynamic> m) {
    final id = jsonString(m['vendor_id']);
    final name = jsonString(m['name']);
    final price = jsonInt(m['price']);
    if (id == null || name == null || price == null) return null;
    return CustomVendorItem(
      vendorId: id,
      name: name,
      category: jsonString(m['category']) ?? '',
      location: jsonString(m['location']) ?? '',
      price: price,
    );
  }

  // ---- Voucher ----
  static Map<String, dynamic> _encodeVoucher(Voucher v) => {
        'code': v.code,
        'title': v.title,
        'description': v.description,
        'type': v.type.name,
        'value': v.value,
        'min_spend': v.minSpend,
        'max_discount': v.maxDiscount,
        'valid_until_label': v.validUntilLabel,
      };

  static Voucher? _decodeVoucher(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final code = jsonString(m['code']);
    final title = jsonString(m['title']);
    final value = jsonInt(m['value']);
    if (code == null || title == null || value == null) return null;
    final type = VoucherType.values
        .where((t) => t.name == jsonString(m['type']))
        .firstOrNull;
    if (type == null) return null;
    return Voucher(
      code: code,
      title: title,
      description: jsonString(m['description']) ?? '',
      type: type,
      value: value,
      minSpend: jsonInt(m['min_spend']) ?? 0,
      maxDiscount: jsonInt(m['max_discount']),
      validUntilLabel: jsonString(m['valid_until_label']) ?? '',
    );
  }
}
