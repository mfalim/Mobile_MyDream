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
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/my_wedding/presentation/pages/couple_setup_page.dart';
import '../../features/my_wedding/presentation/providers/couple_provider.dart';
import '../../features/info/presentation/pages/info_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/packages/presentation/pages/package_detail_page.dart';
import '../../features/packages/presentation/pages/packages_page.dart';
import '../../features/payment/presentation/pages/order_submitted_page.dart';
import '../../features/account/presentation/pages/account_settings_page.dart';
import '../../features/support/presentation/pages/report_issue_page.dart';
import '../../features/inspirations/presentation/pages/story_page.dart';
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
      needsCoupleSetup: ref.read(coupleProvider) == null,
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
        builder: (context, state) =>
            LoginPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            RegisterPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.coupleSetup,
        builder: (context, state) =>
            CoupleSetupPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => CartPage(
          claimCode: state.uri.queryParameters['claim'],
          initialTab: state.uri.queryParameters['tab'] == 'custom' ? 1 : 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => CheckoutPage(
            isCustom: state.uri.queryParameters['type'] == 'custom'),
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
      GoRoute(
        path: AppRoutes.orderSubmitted,
        builder: (context, state) => const OrderSubmittedPage(),
      ),
      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) => const AccountSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.reportIssue,
        builder: (context, state) => const ReportIssuePage(),
      ),
      GoRoute(
        path: AppRoutes.packages,
        builder: (context, state) => const PackagesPage(),
      ),
      GoRoute(
        path: AppRoutes.packageDetail,
        builder: (context, state) =>
            PackageDetailPage(packageId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.story,
        builder: (context, state) =>
            StoryPage(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.info,
        builder: (context, state) =>
            InfoPage(slug: state.pathParameters['slug']!),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
