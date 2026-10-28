import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/home/presentation/providers/home_provider.dart';
import 'package:w51/features/home/presentation/widgets/aura_pay_banner.dart';
import 'package:w51/features/home/presentation/widgets/couple_cta_card.dart';
import 'package:w51/features/home/presentation/widgets/curated_vendors_section.dart';
import 'package:w51/features/home/presentation/widgets/deals_section.dart';
import 'package:w51/features/home/presentation/widgets/inspirations_section.dart';
import 'package:w51/features/home/presentation/widgets/service_grid.dart';
import 'package:w51/features/home/presentation/widgets/wedding_countdown_card.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/vendors/presentation/providers/vendor_filter_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeDataProvider);
    return SafeArea(
      bottom: false,
      child: home.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Beranda gagal dimuat.',
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
        data: (data) => _HomeContent(data: data),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gap = SizedBox(height: AppSpacing.lg);
    final couple = ref.watch(coupleProvider);
    final isGuest = ref.watch(authProvider) == null;

    void goVendors() {
      ref.read(vendorFilterProvider.notifier).reset();
      context.go(AppRoutes.vendors);
    }

    void openCategory(ServiceCategory service) {
      final route = service.route;
      if (route != null) {
        context.push(route);
        return;
      }
      final filter = ref.read(vendorFilterProvider.notifier)..reset();
      filter.setCategory(service.vendorCategory);
      context.go(AppRoutes.vendors);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        if (couple != null)
          WeddingCountdownCard(
            countdown: data.countdown,
            coupleNames: couple.shortNames,
            dateLabel: formatDateId(couple.weddingDate),
            daysLeft: math.max(0, daysUntil(couple.weddingDate)),
            onDetail: () => context.go(AppRoutes.myWedding),
          )
        else
          CoupleCtaCard(
            isGuest: isGuest,
            onStart: () => context.push(AppRoutes.coupleSetup),
          ),
        gap,
        ServiceGrid(services: data.services, onSelected: openCategory),
        if (data.deals.isNotEmpty) ...[
          gap,
          DealsSection(
            deals: data.deals,
            onSeeAll: () => context.push(AppRoutes.packages),
            onOpen: (deal) =>
                context.push(AppRoutes.packageDetailPath(deal.id)),
            onAction: (deal) {
              final code = deal.voucherCode;
              // Voucher = aksi yang butuh login: router mengarahkan tamu ke Login.
              context.push(
                code == null
                    ? AppRoutes.packageDetailPath(deal.id)
                    : AppRoutes.cartWithVoucher(code),
              );
            },
          ),
        ],
        gap,
        const AuraPayBanner(),
        if (data.vendors.isNotEmpty) ...[
          gap,
          CuratedVendorsSection(
            categories: data.vendorCategories,
            vendors: data.vendors,
            onSeeAll: goVendors,
            onOpen: (v) => context.push(AppRoutes.vendorDetailPath(v.id)),
            onAsk: (v) => contactVendor(context, ref, v.id),
          ),
        ],
        if (data.articles.isNotEmpty) ...[
          gap,
          InspirationsSection(
            articles: data.articles,
            onSeeAll: () => context.go(AppRoutes.inspirations),
          ),
        ],
      ],
    );
  }
}
