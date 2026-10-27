abstract final class AppRoutes {
  // Publik
  static const home = '/home';
  static const vendors = '/vendors';
  static const inspirations = '/inspirations';
  static const vendorDetail = '/vendor/:id';
  static String vendorDetailPath(String id) => '/vendor/$id';
  static const login = '/login';
  static const orderSubmitted = '/order-submitted';

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
    coupleSetup,
    notifications,
    notificationSettings,
    orderSubmitted,
    account,
    reportIssue
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

  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const info = '/info/:slug';
  static String infoPath(String slug) => '/info/$slug';

  /// Keranjang yang langsung membuka tab Custom Order.
  static const cartCustomPath = '/cart?tab=custom';

  /// Checkout untuk paket, atau untuk Custom Order bila [custom] true.
  static String checkoutPath({bool custom = false}) =>
      custom ? '$checkout?type=custom' : checkout;

  static const packages = '/packages';
  static const packageDetail = '/package/:id';
  static String packageDetailPath(String id) => '/package/$id';

  static const account = '/account';
  static const reportIssue = '/report-issue';
}
