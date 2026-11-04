import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';
import 'package:w51/features/vendors/presentation/providers/saved_vendors_provider.dart';
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';
import 'package:w51/features/vendors/presentation/widgets/featured_vendor_card.dart';

class SavedVendorsPage extends ConsumerWidget {
  const SavedVendorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedVendorsProvider);
    final data = ref.watch(vendorsDataProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.myWedding);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Vendor Tersimpan', style: AppTypography.heading(20)),
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: userMessage(e, fallback: 'Daftar vendor gagal dimuat.'),
          onRetry: () => ref.invalidate(vendorsDataProvider),
        ),
        data: (d) {
          final vendors =
              d.featured.where((v) => saved.contains(v.id)).toList();
          if (vendors.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmptyState(
                    message:
                        'Belum ada vendor tersimpan.\nKetuk ikon simpan di '
                        'kartu vendor untuk menyimpannya di sini.',
                    icon: Icons.bookmark_border,
                  ),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.vendors),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(220, 48),
                    ),
                    child: const Text('Jelajahi Vendor'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            children: [
              Text(
                '${vendors.length} vendor tersimpan',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              FeaturedVendorGrid(
                vendors: vendors,
                onOpen: (v) => context.push(AppRoutes.vendorDetailPath(v.id)),
                onChat: (v) => contactVendor(context, ref, v.id),
              ),
            ],
          );
        },
      ),
    );
  }
}
