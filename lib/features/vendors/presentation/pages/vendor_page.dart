import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/core/widgets/section_header.dart';
import 'package:w51/features/vendors/domain/entities/vendor_entities.dart';
import 'package:w51/features/vendors/domain/entities/vendor_filter.dart';
import 'package:w51/features/vendors/presentation/providers/vendor_filter_provider.dart';
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';
import 'package:w51/features/vendors/presentation/widgets/category_grid.dart';
import 'package:w51/features/vendors/presentation/widgets/featured_vendor_card.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_filter_sheet.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_help_banner.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_promo_banner.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_search_section.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_top_bar.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';

class VendorPage extends ConsumerStatefulWidget {
  const VendorPage({super.key});

  @override
  ConsumerState<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends ConsumerState<VendorPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // void _soon(String feature) {
  //   ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
  // }

  List<FeaturedVendor> _filter(List<FeaturedVendor> all, VendorFilter filter) {
    final q = _search.text.trim().toLowerCase();
    return all.where((v) {
      if (!filter.matches(v)) return false;
      if (q.isEmpty) return true;
      return v.name.toLowerCase().contains(q) ||
          v.categoryLabel.toLowerCase().contains(q) ||
          (v.description ?? '').toLowerCase().contains(q);
    }).toList();
  }

  List<String> _allCategories(VendorsData data) => [
        for (final c in data.categories) c.label,
        for (final q in data.quickCategories) q.label,
      ];

  Future<void> _openFilter(VendorsData data) async {
    final result = await showVendorFilterSheet(
      context,
      initial: ref.read(vendorFilterProvider),
      categories: _allCategories(data),
    );
    if (result == null || !mounted) return;
    ref.read(vendorFilterProvider.notifier).apply(result);
  }

  void _clearAll() {
    _search.clear();
    ref.read(vendorFilterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(vendorsDataProvider);
    final filter = ref.watch(vendorFilterProvider);
    return SafeArea(
      bottom: false,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: 'Daftar vendor gagal dimuat.',
          onRetry: () => ref.invalidate(vendorsDataProvider),
        ),
        data: (d) => _buildContent(d, filter),
      ),
    );
  }

  Widget _buildContent(VendorsData data, VendorFilter filter) {
    const gap = SizedBox(height: AppSpacing.lg);
    final featured = _filter(data.featured, filter);
    final isFiltering = _search.text.trim().isNotEmpty || filter.isActive;
    final controller = ref.read(vendorFilterProvider.notifier);
    final loggedIn = ref.watch(authProvider) != null;
    final unread = loggedIn ? ref.watch(unreadCountProvider) : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        VendorsTopBar(
          unreadCount: unread,
          onNotifications: () => context.push(AppRoutes.notifications),
          onChat: () => contactAdmin(context, ref),
          onProfile: () => context.go(AppRoutes.myWedding),
        ),
        const SizedBox(height: AppSpacing.md),
        VendorsSearchSection(
          controller: _search,
          popular: data.popularSearches,
          filter: filter,
          onOpenFilter: () => _openFilter(data),
          onResetFilter: controller.reset,
        ),
        gap,
        // Kategori hanya tampil di keadaan awal (belum mencari / menyaring).
        if (!isFiltering) ...[
          SectionHeader(
            eyebrow: 'Kurasi Spesialis',
            eyebrowColor: AppColors.primary,
            title: 'Eksplorasi Kategori',
            trailing: Text(
              '${data.categories.length + data.quickCategories.length} Layanan',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CategoryGrid(
            categories: data.categories,
            onSelected: (c) => controller.setCategory(c.label),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final q in data.quickCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(q.icon, size: 18, color: AppColors.primary),
                      label: Text(q.label),
                      onPressed: () => controller.setCategory(q.label),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.outline),
                      shape: const StadiumBorder(),
                    ),
                  ),
              ],
            ),
          ),
          gap,
        ],
        // Klaim voucher = aksi yang butuh login: router mengarahkan tamu ke Login.
        VendorsPromoBanner(
          onClaim: () => context.push(AppRoutes.cartWithVoucher('BRIDALEXPO')),
        ),
        gap,
        SectionHeader(
          eyebrow: isFiltering ? 'Hasil Pencarian' : 'Pilihan Editor',
          eyebrowColor: AppColors.primary,
          title: isFiltering
              ? '${featured.length} Vendor Ditemukan'
              : 'Featured Vendors of the Month',
          actionLabel: isFiltering ? 'Hapus' : null,
          onAction: _clearAll,
        ),
        const SizedBox(height: 12),
        if (featured.isEmpty)
          const EmptyState(
            message: 'Vendor yang kamu cari belum ditemukan.',
            icon: Icons.search_off,
          )
        else
          FeaturedVendorGrid(
            vendors: featured,
            onOpen: (v) => context.push(AppRoutes.vendorDetailPath(v.id)),
            onChat: (v) => contactVendor(context, ref, v.id),
          ),
        gap,
        VendorsHelpBanner(
          onAsk: () =>
              contactAdmin(context, ref, topic: 'konsultasi memilih vendor'),
        ),
      ],
    );
  }
}
