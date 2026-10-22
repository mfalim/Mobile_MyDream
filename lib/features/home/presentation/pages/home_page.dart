import 'dart:math' as math;
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';
import 'package:w51/features/home/presentation/providers/home_provider.dart';
import 'package:w51/features/home/presentation/widgets/aura_pay_banner.dart';
import 'package:w51/features/home/presentation/widgets/curated_vendors_section.dart';
import 'package:w51/features/home/presentation/widgets/deals_section.dart';
import 'package:w51/features/home/presentation/widgets/inspirations_section.dart';
import 'package:w51/features/home/presentation/widgets/service_grid.dart';
import 'package:w51/features/home/presentation/widgets/wedding_countdown_card.dart';
import 'package:w51/features/vendors/presentation/providers/vendor_filter_provider.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/home/presentation/widgets/couple_cta_card.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

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
    final couple = ref.watch(coupleProvider);
    final isGuest = ref.watch(authProvider) == null;
    const gap = SizedBox(height: AppSpacing.lg);
    void goVendors() {
      ref.read(vendorFilterProvider.notifier).reset();
      context.go(AppRoutes.vendors);
    }

    void openCategory(ServiceCategory service) {
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
        gap,
        DealsSection(
          deals: data.deals,
          onSeeAll: goVendors,
          // Klaim voucher = aksi yang butuh login: router mengarahkan tamu ke Login.
          onClaim: (deal) =>
              context.push(AppRoutes.cartWithVoucher(deal.voucherCode)),
          onOpen: (deal) => context.push(AppRoutes.vendorDetailPath(deal.id)),
        ),
        gap,
        const AuraPayBanner(),
        gap,
        CuratedVendorsSection(
          categories: data.vendorCategories,
          vendors: data.vendors,
          onSeeAll: goVendors,
          onAsk: (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur chat vendor segera hadir.')),
          ),
          onOpen: (v) => context.push(AppRoutes.vendorDetailPath(v.id)),
        ),
        gap,
        InspirationsSection(
          articles: data.articles,
          onSeeAll: () => context.go(AppRoutes.inspirations),
        ),
      ],
    );
  }
}
