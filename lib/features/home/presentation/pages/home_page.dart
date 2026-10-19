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

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg);
    void goVendors() => context.go(AppRoutes.vendors);

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
          onDetail: () => context.go(AppRoutes.myWedding),
        ),
        gap,
        ServiceGrid(services: data.services, onSelected: (_) => goVendors()),
        gap,
        DealsSection(
          deals: data.deals,
          onSeeAll: goVendors,
          // Klaim voucher = aksi yang butuh login: router mengarahkan tamu ke Login.
          onClaim: (_) => context.push(AppRoutes.cart),
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
