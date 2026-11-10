import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/core/utils/date_helpers.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/auth/domain/entities/app_user.dart';
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
    final user = ref.watch(authProvider);
    final isGuest = user == null;
    final isMember = user?.role == 'member';

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
        if (isMember)
          _MemberWorkspaceCtaCard(user: user!)
        else if (couple != null)
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
            onOpen: (a) => context.push(AppRoutes.storyPath(a.id)),
          ),
        ],
      ],
    );
  }
}

class _MemberWorkspaceCtaCard extends StatelessWidget {
  const _MemberWorkspaceCtaCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_rounded, size: 14, color: AppColors.onGold),
                    const SizedBox(width: 5),
                    Text(
                      user.callSign != null ? 'Call Sign: ${user.callSign}' : 'Kru WO',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onGold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Mode Operasional',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Halo, ${user.name}',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda sedang login sebagai Kru Lapangan. Pantau tugas checklist rundown dan koordinasi tim.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(AppRoutes.memberDashboard),
              icon: const Icon(Icons.checklist_rtl_rounded, size: 18),
              label: const Text('Buka Workspace Kru WO'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.onGold,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

