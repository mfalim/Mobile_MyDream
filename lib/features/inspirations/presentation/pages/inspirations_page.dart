import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/presentation/providers/inspirations_provider.dart';
import 'package:w51/features/inspirations/presentation/widgets/inspiration_tabs.dart';
import 'package:w51/features/inspirations/presentation/widgets/more_stories_list.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_view.dart';

class InspirationsPage extends ConsumerStatefulWidget {
  const InspirationsPage({super.key});

  @override
  ConsumerState<InspirationsPage> createState() => _InspirationsPageState();
}

class _InspirationsPageState extends ConsumerState<InspirationsPage> {
  // Status ini hanya di memori (prototype).
  int _tab = 1; // 0 = Inspirasi & Tips, 1 = Real Weddings (sesuai Figma)
  String? _category;

  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature segera hadir.')));
  }

  Future<void> _pickCategory(List<String> categories) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Kategori Cerita', style: AppTypography.heading(20)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ['', ...categories])
                    ChoiceChip(
                      label: Text(c.isEmpty ? 'Semua' : c),
                      selected: (_category ?? '') == c,
                      onSelected: (_) => Navigator.of(ctx).pop(c),
                      selectedColor: AppColors.coral.withValues(alpha: 0.3),
                      backgroundColor: AppColors.surfaceTint,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _category = result.isEmpty ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(inspirationsDataProvider);
    return SafeArea(
      bottom: false,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorState(
          message: 'Cerita gagal dimuat.',
          onRetry: () => ref.invalidate(inspirationsDataProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(InspirationsData d) {
    const gap = SizedBox(height: AppSpacing.lg);
    final more = _category == null
        ? d.more
        : d.more.where((s) => s.category == _category).toList();
    final story = d.story;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            96,
          ),
          children: [
            InspirationTabs(
              labels: const ['Inspirasi & Tips', 'Real Weddings'],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_tab == 0)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: EmptyState(
                  message: 'Inspirasi & Tips segera hadir.',
                  icon: Icons.auto_awesome_outlined,
                ),
              )
            else ...[
              if (story != null)
                StoryView(
                  key: ValueKey(story.id),
                  story: story,
                  onPortfolio: (v) => _soon('Portofolio ${v.name}'),
                  onShare: () => _soon('Bagikan cerita'),
                  onRelatedPackage: (id) =>
                      context.push(AppRoutes.packageDetailPath(id)),
                )
              else
                const EmptyState(
                  message: 'Belum ada cerita.',
                  icon: Icons.menu_book_outlined,
                ),
              gap,
              const Divider(color: AppColors.outline),
              gap,
              MoreStoriesList(
                stories: more,
                onOpen: (s) => context.push(AppRoutes.storyPath(s.id)),
                onSeeAll: () => setState(() => _category = null),
              ),
            ],
          ],
        ),
        if (_tab == 1 && d.categories.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _pickCategory(d.categories),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(
                  _category == null
                      ? 'Filter Kategori Cerita'
                      : 'Kategori: $_category',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  elevation: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
