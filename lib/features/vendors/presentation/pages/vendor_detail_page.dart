import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';
import 'package:w51/features/vendors/presentation/widgets/deposit_guarantee_card.dart';
import 'package:w51/features/vendors/presentation/widgets/package_accordion.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_benefit_tile.dart';
import 'package:w51/core/widgets/booking_bar.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_gallery_header.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_price_card.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_provider_card.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_info_sheets.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';

class VendorDetailPage extends ConsumerStatefulWidget {
  const VendorDetailPage({required this.vendorId, super.key});

  final String vendorId;

  @override
  ConsumerState<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends ConsumerState<VendorDetailPage> {
  bool _saved = false;

  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.vendors);
    }
  }

  void _addToCustom(VendorDetail d) {
    final already =
        ref.read(cartProvider).customVendors.any((v) => v.vendorId == d.id);
    if (!already) {
      ref
          .read(cartProvider.notifier)
          .addCustomVendor(CustomVendorItem.fromVendorDetail(d));
    }

    // Memesan butuh login: tamu langsung diarahkan (router meminta login).
    if (ref.read(authProvider) == null) {
      context.push(AppRoutes.cartCustomPath);
      return;
    }

    final count = ref.read(cartProvider).customVendors.length;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            already
                ? 'Vendor sudah ada di Custom Order '
                    '($count dari minimal $kMinCustomVendors).'
                : 'Ditambahkan ke Custom Order '
                    '($count dari minimal $kMinCustomVendors).',
          ),
          action: SnackBarAction(
            label: 'Lihat',
            onPressed: () => context.push(AppRoutes.cartCustomPath),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(vendorDetailProvider(widget.vendorId));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Vendor Details', style: AppTypography.heading(20)),
        actions: [
          IconButton(
            tooltip: _saved ? 'Hapus dari simpanan' : 'Simpan vendor',
            onPressed: () => setState(() => _saved = !_saved),
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceTint,
              child: Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: e is NotFoundException
              ? 'Vendor tidak ditemukan.'
              : 'Detail vendor gagal dimuat.',
          onRetry: e is NotFoundException
              ? null
              : () => ref.invalidate(vendorDetailProvider(widget.vendorId)),
        ),
        data: _buildContent,
      ),
      bottomNavigationBar: detail.when<Widget?>(
        loading: () => null,
        error: (e, s) => null,
        data: (d) => BookingBar(
          totalPrice: d.price,
          caption: 'Harga vendor',
          actionLabel: 'Tambah',
          actionIcon: Icons.add,
          onChat: () => contactVendor(context, ref, d.id),
          onBook: () => _addToCustom(d),
        ),
      ),
    );
  }

  Widget _buildContent(VendorDetail d) {
    const gap = SizedBox(height: AppSpacing.md);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        VendorGalleryHeader(
          photoCount: d.photoCount,
          onVirtualTour: () => _soon('Virtual tour'),
        ),
        gap,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const BadgePill('Best Price Guarantee', icon: Icons.verified),
            BadgePill(
              d.savingsBadge,
              background: AppColors.error,
              foreground: Colors.white,
            ),
            BadgePill(
              d.validUntil,
              icon: Icons.schedule,
              background: AppColors.surfaceTint,
              foreground: AppColors.textSecondary,
            ),
          ],
        ),
        gap,
        Text(d.name, style: AppTypography.heading(28)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.place_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                d.location,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        gap,
        VendorPriceCard(detail: d),
        gap,
        VendorBenefitTile(
          icon: Icons.savings_outlined,
          iconBackground: AppColors.gold,
          title: 'Earn ${formatNumber(d.cashbackPoints)} Points',
          badge: '${d.cashbackPercent}% Cashback',
          subtitle: d.cashbackNote,
          onTap: () => showPointsSheet(
            context,
            price: d.price,
            percent: d.cashbackPercent,
            points: d.cashbackPoints,
          ),
        ),
        const SizedBox(height: 10),
        VendorBenefitTile(
          icon: Icons.credit_card,
          iconBackground: AppColors.coral.withValues(alpha: 0.25),
          title: 'Cicilan 0% ${d.installmentMonths} Bulan',
          subtitle:
              'Mulai ${formatRupiah(d.installmentPerMonth)} / bulan via Bridestory Pay',
          onTap: () => showInstallmentSheet(
            context,
            price: d.price,
            maxMonths: d.installmentMonths,
          ),
        ),
        gap,
        VendorProviderCard(
          provider: d.provider,
          onVisit: () => _soon('Profil vendor'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text('Package Details', style: AppTypography.heading(22)),
            ),
            TextButton(
              onPressed: () =>
                  showAllInclusionsSheet(context, sections: d.sections),
              child: const Text('All Inclusions'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < d.sections.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PackageAccordion(
              section: d.sections[i],
              initiallyExpanded: i == 0,
            ),
          ),
        const SizedBox(height: 4),
        DepositGuaranteeCard(title: d.guaranteeTitle, note: d.guaranteeNote),
      ],
    );
  }
}
