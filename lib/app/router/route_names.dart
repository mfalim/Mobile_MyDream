abstract final class AppRoutes {
  // Publik
  static const home = '/home';
  static const vendors = '/vendors';
  static const inspirations = '/inspirations';
  static const login = '/login';

  // Wajib login
  static const myWedding = '/my-wedding';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const payment = '/payment';

  static const protectedPaths = [myWedding, cart, checkout, payment];
}
