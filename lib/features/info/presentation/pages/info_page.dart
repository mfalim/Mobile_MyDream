import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/info/domain/entities/info_document.dart';
import 'package:w51/features/info/presentation/providers/info_provider.dart';

class InfoPage extends ConsumerWidget {
  const InfoPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(infoDocumentProvider(slug));

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
        title: Text(
          doc.value?.title ?? 'Informasi',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.heading(18),
        ),
      ),
      body: doc.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: e is NotFoundException
              ? 'Halaman tidak ditemukan.'
              : 'Halaman gagal dimuat.',
          onRetry: e is NotFoundException
              ? null
              : () => ref.invalidate(infoDocumentProvider(slug)),
        ),
        data: (d) => _Content(doc: d),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.doc});

  final InfoDocument doc;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.6),
            borderRadius: AppRadius.card,
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.onGold),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Teks contoh untuk prototype. Ketentuan resmi akan diisi '
                  'oleh tim Aura.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Terakhir diperbarui: ${doc.updatedLabel}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final s in doc.sections) ...[
          Text(s.heading, style: AppTypography.heading(18)),
          const SizedBox(height: 6),
          Text(s.body, style: const TextStyle(fontSize: 14, height: 1.6)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
