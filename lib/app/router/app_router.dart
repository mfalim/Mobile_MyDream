import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/inspirations/presentation/pages/inspirations_page.dart';
import '../../features/my_wedding/presentation/pages/profile_page.dart';
import '../../features/vendors/presentation/pages/vendor_page.dart';
import '../../features/vendors/presentation/pages/vendor_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import 'app_shell.dart';
import 'route_names.dart';
import 'auth_redirect.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Memberi tahu router agar mengevaluasi ulang redirect saat status login berubah.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      loggedIn: ref.read(authProvider) != null,
      uri: state.uri,
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.vendors,
              builder: (context, state) => const VendorPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.inspirations,
              builder: (context, state) => const InspirationsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.myWedding,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: AppRoutes.vendorDetail,
        builder: (context, state) =>
            VendorDetailPage(vendorId: state.pathParameters['id']!),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
