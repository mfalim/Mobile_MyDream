abstract final class AppRoutes {
  // Publik
  static const home = '/home';
  static const vendors = '/vendors';
  static const inspirations = '/inspirations';
  static const vendorDetail = '/vendor/:id';
  static String vendorDetailPath(String id) => '/vendor/$id';
  static const login = '/login';

  // Wajib login
  static const myWedding = '/my-wedding';
  static const cart = '/cart';

  /// Keranjang dengan voucher yang langsung dipasang (tombol "Klaim Voucher").
  static String cartWithVoucher(String code) =>
      Uri(path: cart, queryParameters: {'claim': code}).toString();
  static const checkout = '/checkout';
  static const payment = '/payment';

  static const protectedPaths = [
    myWedding,
    cart,
    checkout,
    payment,
    coupleSetup
  ];
  static const register = '/register';
  static const coupleSetup = '/couple-setup';
  static String coupleSetupPath({String? from}) => _authPath(coupleSetup, from);
  static const authPaths = [login, register];

  /// Alamat Login/Register; `from` adalah tujuan setelah berhasil masuk.
  static String loginPath({String? from}) => _authPath(login, from);
  static String registerPath({String? from}) => _authPath(register, from);

  static String _authPath(String path, String? from) => Uri(
        path: path,
        queryParameters: from == null ? null : {'from': from},
      ).toString();
}
