import 'dart:math' as math;
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/my_wedding/presentation/providers/wedding_date_provider.dart';
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
    final weddingDate = ref.watch(weddingDateProvider);
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
        WeddingCountdownCard(
          countdown: data.countdown,
          dateLabel: formatDateId(weddingDate),
          daysLeft: math.max(0, daysUntil(weddingDate)),
          onDetail: () => context.go(AppRoutes.myWedding),
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
