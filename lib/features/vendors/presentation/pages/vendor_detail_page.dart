import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/links.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/booking_bar.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/cart/domain/entities/custom_vendor_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';
import 'package:w51/features/vendors/presentation/widgets/deposit_guarantee_card.dart';
import 'package:w51/features/vendors/presentation/widgets/package_accordion.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_benefit_tile.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_gallery_header.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_info_sheets.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_price_card.dart';
import 'package:w51/features/vendors/presentation/widgets/vendor_provider_card.dart';

class VendorDetailPage extends ConsumerStatefulWidget {
  const VendorDetailPage({required this.vendorId, super.key});

  final String vendorId;

  @override
  ConsumerState<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends ConsumerState<VendorDetailPage> {
  bool _saved = false;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _soon(String feature) => _snack('$feature segera hadir.');

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.vendors);
    }
  }

  Future<void> _openInstagram(String raw) async {
    final uri = instagramUri(raw);
    if (uri == null) {
      _snack('Tautan Instagram tidak valid.');
      return;
    }
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) _snack('Instagram tidak bisa dibuka.');
  }

  void _addToCustom(VendorDetail d) {
    if (d.price <= 0) {
      _snack('Harga vendor belum ditetapkan.');
      return;
    }
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
    final badge = d.savingsBadge;
    final validUntil = d.validUntil;
    final description = d.description;
    final instagram = d.instagram;
    final cashback = d.cashback;
    final installment = d.installment;
    final provider = d.provider;
    final guarantee = d.guarantee;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        VendorGalleryHeader(photoUrls: d.photoUrls, photoCount: d.photoCount),
        gap,
        if (badge != null || validUntil != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (badge != null) ...[
                const BadgePill('Best Price Guarantee', icon: Icons.verified),
                BadgePill(
                  badge,
                  background: AppColors.error,
                  foreground: Colors.white,
                ),
              ],
              if (validUntil != null)
                BadgePill(
                  validUntil,
                  icon: Icons.schedule,
                  background: AppColors.surfaceTint,
                  foreground: AppColors.textSecondary,
                ),
            ],
          ),
          gap,
        ],
        Text(d.name, style: AppTypography.heading(28)),
        if (d.location.isNotEmpty) ...[
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
        ],
        gap,
        VendorPriceCard(detail: d),
        if (description != null) ...[
          gap,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: AppRadius.card,
            ),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
        ],
        if (cashback != null) ...[
          gap,
          VendorBenefitTile(
            icon: Icons.savings_outlined,
            iconBackground: AppColors.gold,
            title: 'Earn ${formatNumber(cashback.points)} Points',
            badge: '${cashback.percent}% Cashback',
            subtitle:
                cashback.note ?? 'Tukarkan poin untuk keperluan pernikahanmu',
            onTap: () => showPointsSheet(
              context,
              price: d.price,
              percent: cashback.percent,
              points: cashback.points,
            ),
          ),
        ],
        if (installment != null) ...[
          const SizedBox(height: 10),
          VendorBenefitTile(
            icon: Icons.credit_card,
            iconBackground: AppColors.coral.withValues(alpha: 0.25),
            title: 'Cicilan 0% ${installment.months} Bulan',
            subtitle: 'Mulai ${formatRupiah(installment.perMonth)} / bulan via '
                'Bridestory Pay',
            onTap: () => showInstallmentSheet(
              context,
              price: d.price,
              maxMonths: installment.months,
            ),
          ),
        ],
        if (instagram != null) ...[
          const SizedBox(height: 10),
          VendorBenefitTile(
            icon: Icons.alternate_email,
            iconBackground: AppColors.surfaceTint,
            title: instagram.startsWith('@') ? instagram : '@$instagram',
            subtitle: 'Lihat portofolio di Instagram',
            onTap: () => _openInstagram(instagram),
          ),
        ],
        if (provider != null) ...[
          gap,
          VendorProviderCard(
            provider: provider,
            onVisit: () => _soon('Profil vendor'),
          ),
        ],
        if (d.sections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Package Details',
                  style: AppTypography.heading(22),
                ),
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
        ],
        if (guarantee != null) ...[
          const SizedBox(height: 4),
          DepositGuaranteeCard(title: guarantee.title, note: guarantee.note),
        ],
      ],
    );
  }
}
