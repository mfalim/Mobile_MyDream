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
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';
import 'package:w51/features/vendors/presentation/widgets/category_grid.dart';
import 'package:w51/features/vendors/presentation/widgets/featured_vendor_card.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_help_banner.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_promo_banner.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_search_section.dart';
import 'package:w51/features/vendors/presentation/widgets/vendors_top_bar.dart';

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

  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
  }

  List<FeaturedVendor> _filter(List<FeaturedVendor> all) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (v) =>
              v.name.toLowerCase().contains(q) ||
              v.categoryLabel.toLowerCase().contains(q) ||
              v.description.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(vendorsDataProvider);
    return SafeArea(
      bottom: false,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: 'Daftar vendor gagal dimuat.',
          onRetry: () => ref.invalidate(vendorsDataProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(VendorsData data) {
    const gap = SizedBox(height: AppSpacing.lg);
    final featured = _filter(data.featured);
    final isSearching = _search.text.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        VendorsTopBar(
          onNotifications: () => _soon('Notifikasi'),
          onChat: () => _soon('Pesan'),
        ),
        const SizedBox(height: AppSpacing.md),
        VendorsSearchSection(
          controller: _search,
          popular: data.popularSearches,
          filters: data.filters,
          onFilterTap: _soon,
        ),
        gap,
        // Kategori hanya tampil di keadaan awal (belum mencari).
        if (!isSearching) ...[
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
            onSelected: (c) => _search.text = c.label,
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
                      onPressed: () => _search.text = q.label,
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
        VendorsPromoBanner(onClaim: () => context.push(AppRoutes.cart)),
        gap,
        SectionHeader(
          eyebrow: isSearching ? 'Hasil Pencarian' : 'Pilihan Editor',
          eyebrowColor: AppColors.primary,
          title: isSearching
              ? '${featured.length} Vendor Ditemukan'
              : 'Featured Vendors of the Month',
          actionLabel: isSearching ? 'Hapus' : 'Lihat Semua',
          onAction: _search.clear,
        ),
        const SizedBox(height: 12),
        if (featured.isEmpty)
          const EmptyState(
            message: 'Vendor yang kamu cari belum ditemukan.',
            icon: Icons.search_off,
          )
        else
          for (final vendor in featured)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FeaturedVendorCard(
                vendor: vendor,
                onChat: () => _soon('Chat vendor'),
                // Layar Vendor Details dibuat di langkah berikutnya.
                onPricelist: () => _soon('Detail vendor'),
              ),
            ),
        gap,
        VendorsHelpBanner(onAsk: () => _soon('Konsultasi ahli')),
      ],
    );
  }
}
