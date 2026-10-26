import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/packages/presentation/providers/packages_provider.dart';
import 'package:w51/features/packages/presentation/widgets/package_card.dart';

class PackagesPage extends ConsumerWidget {
  const PackagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(packagesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Paket Pernikahan', style: AppTypography.heading(20)),
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: 'Daftar paket gagal dimuat.',
          onRetry: () => ref.invalidate(packagesProvider),
        ),
        data: (packages) => packages.isEmpty
            ? const EmptyState(
                message: 'Belum ada paket tersedia.',
                icon: Icons.card_giftcard_outlined,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                children: [
                  const Text(
                    'Paket lengkap berisi beberapa vendor sekaligus. Atau '
                    'susun sendiri lewat Custom Order.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final p in packages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PackageCard(
                        package: p,
                        onOpen: () =>
                            context.push(AppRoutes.packageDetailPath(p.id)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
