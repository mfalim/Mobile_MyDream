import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/inspirations/presentation/providers/inspirations_provider.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_view.dart';

class StoryPage extends ConsumerWidget {
  const StoryPage({required this.storyId, super.key});

  final String storyId;

  void _soon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(storyProvider(storyId));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.inspirations);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Cerita', style: AppTypography.heading(20)),
      ),
      body: story.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: e is NotFoundException
              ? 'Cerita tidak ditemukan.'
              : 'Cerita gagal dimuat.',
          onRetry: e is NotFoundException
              ? null
              : () => ref.invalidate(storyProvider(storyId)),
        ),
        data: (s) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.xl,
          ),
          child: StoryView(
            key: ValueKey(s.id),
            story: s,
            onPortfolio: (v) => _soon(context, 'Portofolio ${v.name}'),
            onShare: () => _soon(context, 'Bagikan cerita'),
            onRelatedPackage: (id) =>
                context.push(AppRoutes.packageDetailPath(id)),
          ),
        ),
      ),
    );
  }
}
