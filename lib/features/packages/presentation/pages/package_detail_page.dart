import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/booking_bar.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/core/widgets/image_placeholder.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/packages/domain/entities/wedding_package.dart';
import 'package:w51/features/packages/presentation/providers/packages_provider.dart';
import 'package:w51/features/packages/presentation/widgets/package_card.dart';
import 'package:w51/features/packages/presentation/widgets/package_vendor_tile.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';

class PackageDetailPage extends ConsumerWidget {
  const PackageDetailPage({required this.packageId, super.key});

  final String packageId;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _book(BuildContext context, WidgetRef ref, WeddingPackage p) {
    if (p.price <= 0) {
      _snack(context, 'Harga paket belum ditetapkan.');
      return;
    }
    ref.read(cartProvider.notifier).add(CartItem.fromPackage(p));
    // Keranjang butuh login: router mengarahkan tamu ke Login dulu.
    context.push(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(packageDetailProvider(packageId));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.packages);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Detail Paket', style: AppTypography.heading(20)),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: e is NotFoundException
              ? 'Paket tidak ditemukan.'
              : 'Detail paket gagal dimuat.',
          onRetry: e is NotFoundException
              ? null
              : () => ref.invalidate(packageDetailProvider(packageId)),
        ),
        data: (p) => _Content(package: p),
      ),
      bottomNavigationBar: detail.when<Widget?>(
        loading: () => null,
        error: (e, s) => null,
        data: (p) => BookingBar(
          totalPrice: p.price,
          caption: 'Harga paket',
          actionLabel: 'Pesan',
          onChat: () => contactAdmin(context, ref, topic: p.name),
          onBook: () => _book(context, ref, p),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.package});

  final WeddingPackage package;

  // Satuan `duration` di database belum dipastikan (diasumsikan jam).
  String _duration(double h) => h == h.roundToDouble()
      ? '${h.round()} jam'
      : '${h.toStringAsFixed(1)} jam';

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    final capacity = package.guestCapacity;
    final period = package.eventPeriod;
    final duration = package.durationHours;
    final available = package.availabilityDate;
    final description = package.description;
    final total = package.vendorsTotal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        ClipRRect(
          borderRadius: AppRadius.card,
          child: SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ImagePlaceholder(icon: Icons.photo_outlined),
                if (package.isFeatured)
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: BadgePill('Pilihan Editor', icon: Icons.star),
                  ),
              ],
            ),
          ),
        ),
        gap,
        Text(package.name, style: AppTypography.heading(28)),
        gap,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HARGA PAKET',
                style: AppTypography.eyebrow.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              if (package.price > 0) ...[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatRupiah(package.price),
                    style: AppTypography.heading(28),
                  ),
                ),
                if (total != null && package.savings > 0) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Beli terpisah ${formatRupiah(total)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      BadgePill(
                        'Hemat ${formatRupiah(package.savings, prefix: 'Rp')}',
                      ),
                    ],
                  ),
                ],
              ] else
                const Text(
                  'Harga menyusul',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Divider(height: 28, color: AppColors.outline),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  if (capacity != null)
                    PackageFact(
                      icon: Icons.groups_outlined,
                      text: 'Hingga $capacity tamu',
                    ),
                  PackageFact(
                    icon: Icons.storefront_outlined,
                    text: '${package.vendors.length} vendor',
                  ),
                  if (period != null)
                    PackageFact(icon: Icons.celebration_outlined, text: period),
                  if (duration != null)
                    PackageFact(
                      icon: Icons.schedule,
                      text: 'Durasi ${_duration(duration)}',
                    ),
                  if (available != null)
                    PackageFact(
                      icon: Icons.event_available_outlined,
                      text: 'Tersedia ${formatDateShortId(available)}',
                    ),
                ],
              ),
            ],
          ),
        ),
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
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Text('Isi Paket', style: AppTypography.heading(22))),
            Text(
              '${package.vendors.length} vendor',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final v in package.vendors)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PackageVendorTile(
              vendor: v,
              onOpen: () => context.push(AppRoutes.vendorDetailPath(v.id)),
            ),
          ),
      ],
    );
  }
}
