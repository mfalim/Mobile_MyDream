import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/storage/local_storage.dart';
import 'package:w51/core/storage/storage_keys.dart';
import 'package:w51/features/auth/data/user_codec.dart';
import 'package:w51/features/auth/domain/entities/app_user.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/data/cart_codec.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/my_wedding/data/couple_codec.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';
import 'package:w51/features/vendors/presentation/providers/saved_vendors_provider.dart';
import 'package:w51/features/my_wedding/presentation/providers/avatar_provider.dart';

/// Dipantau terus oleh MyApp. Tugasnya:
/// 1. menyimpan sesi, data pasangan, dan keranjang setiap kali berubah;
/// 2. membersihkan data milik pengguna begitu ia keluar, dari mana pun
///    asalnya (tombol keluar, atau server menolak token).
final appStateSyncProvider = Provider<void>((ref) {
  final storage = ref.read(localStorageProvider);

  ref.listen<AppUser?>(authProvider, (previous, next) {
    if (next == null) {
      storage.remove(kStorageUser);
    } else if (AppConfig.useMockData) {
      storage.setJson(kStorageUser, UserCodec.encode(next));
    }
    if (previous != null && next == null) {
      ref.read(cartProvider.notifier).clear();
      ref.read(coupleProvider.notifier).clear();
      ref.read(checkoutProvider.notifier).clear();
      ref.read(receiptProvider.notifier).clear();
      ref.read(savedVendorsProvider.notifier).clear();
      ref.read(avatarPathProvider.notifier).remove().ignore();
    }
  });

  ref.listen<CoupleProfile?>(coupleProvider, (previous, next) {
    if (next == null) {
      storage.remove(kStorageCouple);
    } else if (AppConfig.useMockData) {
      storage.setJson(kStorageCouple, CoupleCodec.encode(next));
    }
  });

  ref.listen<CartState>(cartProvider, (previous, next) {
    if (next.isEmpty) {
      storage.remove(kStorageCart);
    } else {
      storage.setJson(kStorageCart, CartCodec.encode(next));
    }
  });
});
